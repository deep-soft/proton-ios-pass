//
// SyncProgress.swift
// Proton Pass - Created on 11/09/2023.
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

import Combine

// All the models related to vault sync progress feature
public typealias VaultSyncEventStream = CurrentValueSubject<VaultSyncProgressEvent, Never>

/// Object to track events when fetching items for vaults
public struct GetRemoteItemsProgress {
    /// ID of the vault
    public let shareId: String
    /// Number of total items
    public let total: Int
    /// Number of downloaded items
    public let downloaded: Int

    public init(shareId: String, total: Int, downloaded: Int) {
        self.shareId = shareId
        self.total = total
        self.downloaded = downloaded
    }
}

/// Object to track events when decrypting fetched remote items
public struct DecryptItemsProgress {
    /// ID of the vault
    public let shareId: String
    /// Number of total items
    public let total: Int
    /// Number of decrypted items
    public let decrypted: Int
}

/// Possible events when synching vaults
public enum VaultSyncProgressEvent {
    /// An initial value for the sake of being able to make a `CurrentValueSubject`
    case initialization
    /// The sync progress has started (log in or full sync)
    case started
    /// Remote shares are fetched but not yet decrypted so no info like vault names or icons are known at this
    /// stage
    case downloadedShares([Share])
    /// A share is decrypted so we have the `Vault` object with all its visual info like  name and icon
    case decryptedVault(Vault)
    /// Fetching remote items of a share
    case getRemoteItems(GetRemoteItemsProgress)
    /// Decrypting fetched remote items of a share
    case decryptItems(DecryptItemsProgress)
    /// The sync progress is done
    case done
}

/// The sync progress of a given vault
public struct VaultSyncProgress {
    public enum VaultState {
        case unknown
        case known(Vault)
    }

    public enum ItemsState {
        case loading
        case download(downloaded: Int, total: Int)
        case decrypt(decrypted: Int, total: Int)
    }

    public let shareId: String
    public let vaultState: VaultState
    public let itemsState: ItemsState

    public init(shareId: String, vaultState: VaultState, itemsState: ItemsState) {
        self.shareId = shareId
        self.vaultState = vaultState
        self.itemsState = itemsState
    }

    /// Make a copy of the progress with a new `VaultState`
    public func copy(vaultState: VaultState) -> Self {
        .init(shareId: shareId, vaultState: vaultState, itemsState: itemsState)
    }

    /// Make a copy of the progress with a new `ItemsState`
    public func copy(itemState: ItemsState) -> Self {
        .init(shareId: shareId, vaultState: vaultState, itemsState: itemState)
    }
}

extension VaultSyncProgress: Identifiable {
    public var id: String {
        shareId
    }
}

public extension VaultSyncProgress {
    var vault: Vault? {
        switch vaultState {
        case let .known(vault):
            return vault
        case .unknown:
            return nil
        }
    }

    var isDone: Bool {
        switch itemsState {
        case let .download(_, total):
            return total == 0
        case let .decrypt(decrypted, total):
            return decrypted >= total
        default:
            return false
        }
    }

    var isEmpty: Bool {
        switch itemsState {
        case .loading:
            return false
        case let .download(_, total):
            return total == 0
        case let .decrypt(_, total):
            return total == 0
        }
    }
}
