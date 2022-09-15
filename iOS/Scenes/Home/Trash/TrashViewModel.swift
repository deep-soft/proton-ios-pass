//
// TrashViewModel.swift
// Proton Pass - Created on 09/09/2022.
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
import Core
import ProtonCore_Login
import SwiftUI

final class TrashViewModel: BaseViewModel, DeinitPrintable, ObservableObject {
    @Published private(set) var isFetchingItems = false
    @Published private(set) var trashedItem = [PartialItemContent]()

    private let userData: UserData
    private let shareRepository: ShareRepositoryProtocol
    private let shareKeysRepository: ShareKeysRepositoryProtocol
    private let itemRevisionRepository: ItemRevisionRepositoryProtocol
    private let publicKeyRepository: PublicKeyRepositoryProtocol

    var onToggleSidebar: (() -> Void)?
    var onShowOptions: ((PartialItemContent) -> Void)?
    var onRestoredItem: (() -> Void)?
    var onDeletedItem: (() -> Void)?

    init(userData: UserData,
         shareRepository: ShareRepositoryProtocol,
         shareKeysRepository: ShareKeysRepositoryProtocol,
         itemRevisionRepository: ItemRevisionRepositoryProtocol,
         publicKeyRepository: PublicKeyRepositoryProtocol) {
        self.userData = userData
        self.shareRepository = shareRepository
        self.shareKeysRepository = shareKeysRepository
        self.itemRevisionRepository = itemRevisionRepository
        self.publicKeyRepository = publicKeyRepository
        super.init()
        getAllTrashedItems(forceRefresh: false)
    }

    func getAllTrashedItems(forceRefresh: Bool) {
        Task { @MainActor in
            do {
                isFetchingItems = true

                let shares = try await shareRepository.getShares(forceRefresh: forceRefresh)
                var trashedItems = [PartialItemContent]()

                for share in shares {
                    let (share, shareKeys) = try await getShareAndKeys(shareId: share.shareID,
                                                                       forceRefresh: forceRefresh)
                    let itemRevisions =
                    try await itemRevisionRepository.getItemRevisions(forceRefresh: forceRefresh,
                                                                      shareId: share.shareID,
                                                                      state: .trashed)
                    for itemRevision in itemRevisions {
                        let publicKeys =
                        try await publicKeyRepository.getPublicKeys(email: itemRevision.signatureEmail)
                        let verifyKeys = publicKeys.map { $0.value }
                        let partialItemContent =
                        try itemRevision.getPartialContent(userData: userData,
                                                           share: share,
                                                           vaultKeys: shareKeys.vaultKeys,
                                                           itemKeys: shareKeys.itemKeys,
                                                           verifyKeys: verifyKeys)
                        trashedItems.append(partialItemContent)
                    }
                }

                isFetchingItems = false
                self.trashedItem = trashedItems
            } catch {
                self.error = error
            }
        }
    }

    private func getShareAndKeys(shareId: String,
                                 forceRefresh: Bool) async throws -> (Share, ShareKeys) {
        let share = try await shareRepository.getShare(shareId: shareId)
        let shareKeys = try await shareKeysRepository.getShareKeys(shareId: shareId,
                                                                   page: 0,
                                                                   pageSize: kDefaultPageSize,
                                                                   forceRefresh: forceRefresh)
        return (share, shareKeys)
    }
}

// MARK: - Actions
extension TrashViewModel {
    func toggleSidebar() { onToggleSidebar?() }

    func restoreAllItems() {
        print(#function)
    }

    func emptyTrash() {
        print(#function)
    }

    func showOptions(_ item: PartialItemContent) {
        onShowOptions?(item)
    }

    func restore(_ item: PartialItemContent) {
        Task { @MainActor in
            do {
                guard let itemRevision =
                        try await itemRevisionRepository.getItemRevision(shareId: item.shareId,
                                                                         itemId: item.itemId) else { return }
                isLoading = true
                try await itemRevisionRepository.untrashItemRevisions([itemRevision],
                                                                      shareId: item.shareId)
                isLoading = false
                trashedItem.removeAll(where: { $0.itemId == item.itemId })
                onRestoredItem?()
            } catch {
                self.isLoading = false
                self.error = error
            }
        }
    }

    func deletePermanently(_ item: PartialItemContent) {
        Task { @MainActor in
            do {
                guard let itemRevision =
                        try await itemRevisionRepository.getItemRevision(shareId: item.shareId,
                                                                         itemId: item.itemId) else { return }
                isLoading = true
                try await itemRevisionRepository.deleteItemRevisions([itemRevision],
                                                                     shareId: item.shareId)
                isLoading = false
                trashedItem.removeAll(where: { $0.itemId == item.itemId })
                onDeletedItem?()
            } catch {
                self.isLoading = false
                self.error = error
            }
        }
    }
}