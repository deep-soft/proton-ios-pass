//
// AutoFillViewModel.swift
// Proton Pass - Created on 11/09/2024.
// Copyright (c) 2024 Proton Technologies AG
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

@preconcurrency import AuthenticationServices
import Combine
import Core
import Entities
import Factory
import Foundation
import Macro
import Screens

@MainActor
protocol AutoFillViewModelDelegate: AnyObject {
    func autoFillViewModelWantsToCreateNewItem(_ info: LoginCreationInfo)
    func autoFillViewModelWantsToSelectUser(_ users: [UserUiModel])
    func autoFillViewModelWantsToCancel()
    func autoFillViewModelWantsToLogOut()
    func autoFillViewModelWantsToPresentSortTypeList(selectedSortType: SortType,
                                                     delegate: any SortTypeListViewModelDelegate)
}

@MainActor
class AutoFillViewModel<T: AutoFillCredentialsFetchResult>: ObservableObject {
    @Published private(set) var results: [T] = []
    @Published var selectedUser: UserUiModel?
    var cancellables = Set<AnyCancellable>()

    private let shareIdToUserManager: any ShareIdToUserManagerProtocol
    private let userForNewItemSubject: UserForNewItemSubject

    let users: [UserUiModel]

    @LazyInjected(\SharedServiceContainer.eventSynchronizer) private var eventSynchronizer
    @LazyInjected(\SharedToolingContainer.logger) var logger
    @LazyInjected(\SharedRouterContainer.mainUIKitSwiftUIRouter) var router
    @LazyInjected(\SharedUseCasesContainer.canEditItem) var canEditItem
    @LazyInjected(\AutoFillUseCaseContainer.associateUrlAndAutoFill) var associateUrlAndAutoFill

    weak var delegate: (any AutoFillViewModelDelegate)?
    private(set) weak var context: ASCredentialProviderExtensionContext?

    var isFreeUser: Bool {
        selectedUser?.plan.isFreeUser == true
    }

    var searchBarPlaceholder: String {
        if let selectedUser {
            switch selectedUser.plan.planType {
            case .free:
                #localized("Search in oldest 2 vaults")
            default:
                #localized("Search in all vaults")
            }
        } else {
            #localized("Search in %lld accounts", users.count)
        }
    }

    var shouldAskForUserWhenCreatingNewItem: Bool {
        users.count > 1 && selectedUser == nil
    }

    /// Vautls of all users keeping only the first one of the ones sharing the same `VaultID`
    private var uniqueVaults: [Vault] {
        results.flatMap(\.vaults).deduplicated
    }

    init(context: ASCredentialProviderExtensionContext?,
         users: [UserUiModel],
         userForNewItemSubject: UserForNewItemSubject) {
        self.context = context
        self.users = users
        self.userForNewItemSubject = userForNewItemSubject
        shareIdToUserManager = ShareIdToUserManager(users: users)
        if users.count == 1 {
            selectedUser = users.first
        }

        userForNewItemSubject
            .sink { [weak self] user in
                guard let self else { return }
                createNewItem(userId: user.id)
            }
            .store(in: &cancellables)
    }

    // swiftlint:disable unavailable_function
    func getVaults(userId: String) -> [Vault]? {
        fatalError("Must be overridden by subclasses")
    }

    func generateLoginCreationInfo(userId: String, vaults: [Vault]) -> LoginCreationInfo {
        fatalError("Must be overridden by subclasses")
    }

    func isErrorState() -> Bool {
        fatalError("Must be overridden by subclasses")
    }

    func fetchAutoFillCredentials(userId: String) async throws -> T {
        fatalError("Must be overridden by subclasses")
    }

    // swiftlint:enable unavailable_function

    func changeToErrorState(_ error: any Error) {}
    func changeToLoadingState() {}
    func changeToLoadedState() {}
}

// MARK: - Non trivial common operations

extension AutoFillViewModel {
    func sync(ignoreError: Bool) async {
        do {
            var shouldRefreshItems = false
            for user in users {
                let hasNewEvents = try await eventSynchronizer.sync(userId: user.id)
                shouldRefreshItems = shouldRefreshItems || hasNewEvents
            }

            if shouldRefreshItems {
                await fetchItems()
            }
        } catch {
            logger.error(error)
            if !ignoreError {
                changeToErrorState(error)
            }
        }
    }

    func fetchItems() async {
        do {
            if isErrorState() {
                changeToLoadingState()
            }

            var results = [T]()
            for user in users {
                let result = try await fetchAutoFillCredentials(userId: user.id)
                shareIdToUserManager.index(vaults: result.vaults,
                                           userId: result.userId)
                results.append(result)
            }

            self.results = results
            changeToLoadedState()
        } catch {
            logger.error(error)
            changeToErrorState(error)
        }
    }

    func createNewItem(userId: String?) {
        guard let userId = userId ?? selectedUser?.id else {
            assertionFailure("No userID selected to create new item")
            return
        }
        do {
            guard let vaults = getVaults(userId: userId) else {
                throw PassError.vault(.vaultsNotFound(userId: userId))
            }
            let info = generateLoginCreationInfo(userId: userId, vaults: vaults)
            delegate?.autoFillViewModelWantsToCreateNewItem(info)
        } catch {
            handle(error)
        }
    }

    // Show the sheet at the coordinator level instead of a view modifier
    // because SwiftUI's confirmationDialog (action sheet) as well as alerts
    // don't inherit colorScheme from its parent view
    func presentSelectUserActionSheet() {
        delegate?.autoFillViewModelWantsToSelectUser(users)
    }

    /// When getting user for UI display, we only return user when logged in with multiple accounts
    /// and no particular account is selected. This way we only display the user next to the item title when in
    /// "all accounts" view mode.
    /// Otherwise, always return a user for making API requests base on `userID`
    func getUser(for item: any ItemIdentifiable, forUiDisplay: Bool) -> UserUiModel? {
        if forUiDisplay, users.count > 1, selectedUser == nil { return nil }
        do {
            return try shareIdToUserManager.getUser(for: item)
        } catch {
            handle(error)
            return nil
        }
    }

    func getAllObjects<Object: ItemIdentifiable & Hashable>(_ keyPath: KeyPath<T, [Object]>)
        -> [Object] {
        let uniqueShareIds = uniqueVaults.map(\.shareId)
        return results
            .flatMap { $0[keyPath: keyPath] }
            .filter { uniqueShareIds.contains($0.shareId) }
    }
}

// MARK: - Trivial common operations

extension AutoFillViewModel {
    func handleAuthenticationSuccess() {
        logger.info("Local authentication succesful")
    }

    func handleAuthenticationFailure() {
        logger.error("Failed to locally authenticate. Logging out.")
        delegate?.autoFillViewModelWantsToLogOut()
    }

    func handleCancel() {
        delegate?.autoFillViewModelWantsToCancel()
    }

    func upgrade() {
        router.present(for: .upgradeFlow)
    }

    func handle(_ error: any Error) {
        logger.error(error)
        router.display(element: .displayErrorBanner(error))
    }
}
