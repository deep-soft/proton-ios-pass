//
// GetSecureLinkKeys.swift
// Proton Pass - Created on 16/05/2024.
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
//

import Client
import Core
import CryptoKit
import Entities
import Foundation

public protocol GetSecureLinkKeysUseCase: Sendable {
    func execute(item: ItemContent) async throws -> SecureLinkKeys
}

public extension GetSecureLinkKeysUseCase {
    func callAsFunction(item: ItemContent) async throws
        -> SecureLinkKeys {
        try await execute(item: item)
    }
}

public final class GetSecureLinkKeys: GetSecureLinkKeysUseCase {
    private let passKeyManager: any PassKeyManagerProtocol
    private let userManager: any UserManagerProtocol

    public init(passKeyManager: any PassKeyManagerProtocol,
                userManager: any UserManagerProtocol) {
        self.passKeyManager = passKeyManager
        self.userManager = userManager
    }

    /// Generates link and encoded item keys
    /// - Parameter item: Item to be publicly shared
    /// - Returns: A tuple with the link and item encoded keys
    public func execute(item: ItemContent) async throws -> SecureLinkKeys {
        let userId = try await userManager.getActiveUserId()
        let itemKeyInfo = try await passKeyManager.getLatestItemKey(userId: userId, shareId: item.shareId,
                                                                    itemId: item.itemId)

        let shareKeyInfo = try await passKeyManager.getLatestShareKey(userId: userId, shareId: item.shareId)

        let linkKey = try Data.random()

        let encryptedItemKey = try AES.GCM.seal(itemKeyInfo.keyData,
                                                key: linkKey,
                                                associatedData: .itemKey)

        let encryptedLinkKey = try AES.GCM.seal(linkKey,
                                                key: shareKeyInfo.keyData,
                                                associatedData: .linkKey)

        guard let itemKeyEncoded = encryptedItemKey.combined?.base64EncodedString(),
              let linkKeyEncoded = encryptedLinkKey.combined?.base64EncodedString()
        else {
            throw PassError.crypto(.failedToBase64Encode)
        }

        return SecureLinkKeys(linkKey: linkKey.base64URLSafeEncodedString(),
                              itemKeyEncoded: itemKeyEncoded,
                              linkKeyEncoded: linkKeyEncoded,
                              shareKeyRotation: shareKeyInfo.keyRotation)
    }
}
