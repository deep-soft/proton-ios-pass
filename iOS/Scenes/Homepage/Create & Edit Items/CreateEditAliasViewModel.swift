//
// CreateEditAliasViewModel.swift
// Proton Pass - Created on 05/08/2022.
// Copyright (c) 2022 Proton Technologies AG
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
import ProtonCoreLogin
import SwiftUI

final class SuffixSelection: ObservableObject, Equatable, Hashable {
    @Published var selectedSuffix: Suffix?
    let suffixes: [Suffix]

    var selectedSuffixString: String { selectedSuffix?.suffix ?? "" }

    init(suffixes: [Suffix]) {
        self.suffixes = suffixes
        selectedSuffix = suffixes.first
    }

    static func == (lhs: SuffixSelection, rhs: SuffixSelection) -> Bool {
        lhs.selectedSuffix == rhs.selectedSuffix && lhs.suffixes == rhs.suffixes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(selectedSuffix)
        hasher.combine(suffixes)
    }
}

final class MailboxSelection: ObservableObject, Equatable, Hashable {
    @Published var selectedMailboxes: [Mailbox]
    let mailboxes: [Mailbox]

    var selectedMailboxesString: String {
        selectedMailboxes.map(\.email).joined(separator: "\n")
    }

    init(mailboxes: [Mailbox]) {
        self.mailboxes = mailboxes
        if let defaultMailbox = mailboxes.first {
            selectedMailboxes = [defaultMailbox]
        } else {
            selectedMailboxes = []
        }
    }

    static func == (lhs: MailboxSelection, rhs: MailboxSelection) -> Bool {
        lhs.selectedMailboxes == rhs.selectedMailboxes && lhs.mailboxes == rhs.mailboxes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(selectedMailboxes)
        hasher.combine(mailboxes)
    }
}

// MARK: - Initialization

final class CreateEditAliasViewModel: BaseCreateEditItemViewModel, DeinitPrintable, ObservableObject {
    deinit { print(deinitMessage) }

    @Published var title = ""
    @Published var prefix = ""
    @Published var prefixManuallyEdited = false
    @Published var note = ""

    var suffix: String { suffixSelection?.selectedSuffixString ?? "" }
    var mailboxes: String { mailboxSelection?.selectedMailboxesString ?? "" }

    @Published private(set) var aliasEmail = ""
    @Published private(set) var state: State = .loading
    @Published private(set) var prefixError: AliasPrefixError?
    @Published private(set) var canCreateAlias = true

    var shouldUpgrade: Bool {
        if case .create = mode {
            return !canCreateAlias
        }
        return false
    }

    enum State {
        case loading
        case loaded
        case error(Error)

        var isLoading: Bool {
            switch self {
            case .loading:
                true
            default:
                false
            }
        }
    }

    private(set) var alias: Alias?
    private(set) var suffixSelection: SuffixSelection?
    private(set) var mailboxSelection: MailboxSelection?
    private let aliasRepository = resolve(\SharedRepositoryContainer.aliasRepository)
    private let router = resolve(\SharedRouterContainer.mainUIKitSwiftUIRouter)

    var isSaveable: Bool {
        switch mode {
        case .create:
            !title.isEmpty && !prefix.isEmpty && !suffix.isEmpty && !mailboxes.isEmpty && prefixError == nil
        case .edit:
            !title.isEmpty && !mailboxes.isEmpty
        }
    }

    override init(mode: ItemMode,
                  upgradeChecker: UpgradeCheckerProtocol,
                  vaults: [Vault]) throws {
        try super.init(mode: mode,
                       upgradeChecker: upgradeChecker,
                       vaults: vaults)

        if case let .edit(itemContent) = mode {
            title = itemContent.name
            note = itemContent.note
        }
        getAliasAndAliasOptions()

        $prefix
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                validatePrefix()
            }
            .store(in: &cancellables)

        $title
            .removeDuplicates()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                guard let self, !self.prefixManuallyEdited else {
                    return
                }
                prefix = PrefixUtils.generatePrefix(fromTitle: title)
            }
            .store(in: &cancellables)

        $selectedVault
            .eraseToAnyPublisher()
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                getAliasAndAliasOptions()
            }
            .store(in: &cancellables)

        Publishers
            .CombineLatest($title, $prefix)
            .combineLatest($note)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                didEditSomething = true
            })
            .store(in: &cancellables)
    }

    override func itemContentType() -> ItemContentType { .alias }

    override func generateItemContent() -> ItemContentProtobuf {
        ItemContentProtobuf(name: title,
                            note: note,
                            itemUuid: UUID().uuidString,
                            data: .alias,
                            customFields: customFieldUiModels.map(\.customField))
    }

    override func generateAliasCreationInfo() -> AliasCreationInfo? {
        guard let selectedSuffix = suffixSelection?.selectedSuffix,
              let selectedMailboxes = mailboxSelection?.selectedMailboxes else { return nil }
        return .init(prefix: prefix,
                     suffix: selectedSuffix,
                     mailboxIds: selectedMailboxes.map(\.ID))
    }

    override func additionalEdit() async throws {
        guard let alias, let mailboxSelection else { return }
        if Set(alias.mailboxes) == Set(mailboxSelection.selectedMailboxes) { return }
        if case let .edit(itemContent) = mode {
            let mailboxIds = mailboxSelection.selectedMailboxes.map(\.ID)
            _ = try await changeMailboxesTask(shareId: itemContent.shareId,
                                              itemId: itemContent.item.itemID,
                                              mailboxIDs: mailboxIds).value
        }
    }

    private func validatePrefix() {
        do {
            try AliasPrefixValidator.validate(prefix: prefix)
            prefixError = nil
        } catch {
            prefixError = error as? AliasPrefixError
        }
    }
}

// MARK: - Public actions

extension CreateEditAliasViewModel {
    func getAliasAndAliasOptions() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                self.state = .loading

                let shareId = self.selectedVault.shareId
                let aliasOptions = try await self.getAliasOptionsTask(shareId: shareId).value
                self.suffixSelection = .init(suffixes: aliasOptions.suffixes)
                self.suffixSelection?.attach(to: self, storeIn: &self.cancellables)
                self.mailboxSelection = .init(mailboxes: aliasOptions.mailboxes)
                self.mailboxSelection?.attach(to: self, storeIn: &self.cancellables)
                self.canCreateAlias = aliasOptions.canCreateAlias

                if case let .edit(itemContent) = mode {
                    let alias =
                        try await self.aliasRepository.getAliasDetailsTask(shareId: shareId,
                                                                           itemId: itemContent.item.itemID).value
                    self.aliasEmail = alias.email
                    self.alias = alias
                    self.mailboxSelection?.selectedMailboxes = alias.mailboxes
                    self.logger.info("Get alias successfully \(itemContent.debugInformation)")
                }

                self.state = .loaded
                self.logger.info("Get alias options successfully")
            } catch {
                self.logger.error(error)
                self.state = .error(error)
            }
        }
    }

    func showMailboxSelection() {
        guard let mailboxSelection else { return }
        router.present(for: .mailboxView(mailboxSelection, mode.isEditMode ? .edit : .create))
    }

    func showSuffixSelection() {
        guard let suffixSelection else { return }
        router.present(for: .suffixView(suffixSelection))
    }
}

// MARK: - Private supporting tasks

private extension CreateEditAliasViewModel {
    func getAliasOptionsTask(shareId: String) -> Task<AliasOptions, Error> {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else {
                throw PPError.deallocatedSelf
            }
            return try await aliasRepository.getAliasOptions(shareId: shareId)
        }
    }

    func changeMailboxesTask(shareId: String,
                             itemId: String,
                             mailboxIDs: [Int]) -> Task<Void, Error> {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else {
                throw PPError.deallocatedSelf
            }
            try await aliasRepository.changeMailboxes(shareId: shareId,
                                                      itemId: itemId,
                                                      mailboxIDs: mailboxIDs)
        }
    }
}
