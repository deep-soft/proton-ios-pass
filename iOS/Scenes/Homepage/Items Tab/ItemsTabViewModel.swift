//
// ItemsTabViewModel.swift
// Proton Pass - Created on 07/03/2023.
// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Pass.
//
// Proton Pass is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Pass is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Pass. If not, see https://www.gnu.org/licenses/.

import Client
import Combine
import Core
import Entities
import Factory
import SwiftUI

protocol ItemsTabViewModelDelegate: AnyObject {
    func itemsTabViewModelWantsToShowSpinner()
    func itemsTabViewModelWantsToHideSpinner()
    func itemsTabViewModelWantsToSearch(vaultSelection: VaultSelection)
    func itemsTabViewModelWantsToCreateNewItem(type: ItemContentType)
    func itemsTabViewModelWantsToPresentVaultList()
    func itemsTabViewModelWantsToPresentSortTypeList(selectedSortType: SortType,
                                                     delegate: SortTypeListViewModelDelegate)
    func itemsTabViewModelWantsToShowTrialDetail()
    func itemsTabViewModelWantsViewDetail(of itemContent: ItemContent)
    func itemsTabViewModelDidEncounter(error: Error)
}

final class ItemsTabViewModel: ObservableObject, PullToRefreshable, DeinitPrintable {
    deinit { print(deinitMessage) }

    @AppStorage(Constants.sortTypeKey, store: kSharedUserDefaults)
    var selectedSortType = SortType.mostRecent

    @Published private(set) var banners: [InfoBanner] = []
    @Published var itemToBePermanentlyDeleted: ItemTypeIdentifiable? {
        didSet {
            if itemToBePermanentlyDeleted != nil {
                showingPermanentDeletionAlert = true
            }
        }
    }

    @Published var showingPermanentDeletionAlert = false

    private let itemRepository = resolve(\SharedRepositoryContainer.itemRepository)
    private let passPlanRepository = resolve(\SharedRepositoryContainer.passPlanRepository)
    private let credentialManager = resolve(\SharedServiceContainer.credentialManager)
    private let logger = resolve(\SharedToolingContainer.logger)
    private let preferences = resolve(\SharedToolingContainer.preferences)
    private let getPendingUserInvitations = resolve(\UseCasesContainer.getPendingUserInvitations)
    let vaultsManager = resolve(\SharedServiceContainer.vaultsManager)
    let itemContextMenuHandler = resolve(\SharedServiceContainer.itemContextMenuHandler)

    private let router = resolve(\RouterContainer.mainUIKitSwiftUIRouter)

    weak var delegate: ItemsTabViewModelDelegate?
    private var inviteRefreshTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    /// `PullToRefreshable` conformance
    var pullToRefreshContinuation: CheckedContinuation<Void, Never>?
    let syncEventLoop = resolve(\SharedServiceContainer.syncEventLoop)

    init() {
        setUp()
    }
}

// MARK: - Private APIs

private extension ItemsTabViewModel {
    func setUp() {
        vaultsManager.attach(to: self, storeIn: &cancellables)
        getPendingUserInvitations()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] invites in
                self?.refreshBanners(invites)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.refreshBanners()
            }
            .store(in: &cancellables)
    }

    func refreshBanners(_ invites: [UserInvite]? = nil) {
        inviteRefreshTask?.cancel()
        inviteRefreshTask = Task { @MainActor [weak self] in
            guard let self else { return }
            if let invites {
                if case .invite = self.banners.first {
                    self.banners.removeFirst()
                }
                self.banners.append(invites.toInfoBanners)
            }
            if banners.isEmpty {
                await fillLocalBanners()
            }
        }
    }

    @MainActor
    func fillLocalBanners() async {
        do {
            for banner in InfoBanner.allCases {
                if preferences.dismissedBannerIds.contains(where: { $0 == banner.id }) {
                    break
                }

                switch banner {
                case .trial:
                    // If not in trial, consider dismissed
                    let plan = try await passPlanRepository.getPlan()
                    switch plan.planType {
                    case .trial:
                        break
                    default:
                        break
                    }

                case .autofill:
                    // We don't show the banner if AutoFill extension is enabled
                    // consider dismissed in this case
                    if await credentialManager.isAutoFillEnabled {
                        // dismissed = true
                        break
                    }

                default:
                    break
                }
                banners.append(banner)
            }
        } catch {
            logger.error(error)
            delegate?.itemsTabViewModelDidEncounter(error: error)
        }
    }
}

// MARK: - Public APIs

extension ItemsTabViewModel {
    func search() {
        delegate?.itemsTabViewModelWantsToSearch(vaultSelection: vaultsManager.vaultSelection)
    }

    func createNewItem(type: ItemContentType) {
        delegate?.itemsTabViewModelWantsToCreateNewItem(type: type)
    }

    func dismiss(banner: InfoBanner) {
        if case .invite = banner {
            return
        }
        banners.removeAll(where: { $0 == banner })
        preferences.dismissedBannerIds.append(banner.id)
    }

    func handleAction(banner: InfoBanner) {
        switch banner {
        case .trial:
            delegate?.itemsTabViewModelWantsToShowTrialDetail()
        case .autofill:
            UIApplication.shared.openPasswordSettings()
        case let .invite(invites: invites):
            if let firstInvite = invites.first {
                router.presentSheet(for: .acceptRejectInvite(firstInvite))
            }
        default:
            break
        }
    }

    func presentVaultList() {
        switch vaultsManager.state {
        case .loaded:
            delegate?.itemsTabViewModelWantsToPresentVaultList()
        default:
            logger.error("Can not present vault list. Vaults are not loaded.")
        }
    }

    func presentSortTypeList() {
        delegate?.itemsTabViewModelWantsToPresentSortTypeList(selectedSortType: selectedSortType,
                                                              delegate: self)
    }

    func viewDetail(of item: ItemUiModel) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                if let itemContent = try await self.itemRepository.getItemContent(shareId: item.shareId,
                                                                                  itemId: item.itemId) {
                    self.delegate?.itemsTabViewModelWantsViewDetail(of: itemContent)
                }
            } catch {
                self.delegate?.itemsTabViewModelDidEncounter(error: error)
            }
        }
    }

    func showFilterOptions() {
        router.presentSheet(for: .filterItems)
    }

    func permanentlyDelete() {
        guard let itemToBePermanentlyDeleted else { return }
        itemContextMenuHandler.deletePermanently(itemToBePermanentlyDeleted)
    }
}

// MARK: - SortTypeListViewModelDelegate

extension ItemsTabViewModel: SortTypeListViewModelDelegate {
    func sortTypeListViewDidSelect(_ sortType: SortType) {
        selectedSortType = sortType
    }
}

// MARK: - SyncEventLoopPullToRefreshDelegate

extension ItemsTabViewModel: SyncEventLoopPullToRefreshDelegate {
    func pullToRefreshShouldStopRefreshing() {
        stopRefreshing()
    }
}

extension [UserInvite] {
    var toInfoBanners: InfoBanner {
        .invite(invites: self)
    }
}
