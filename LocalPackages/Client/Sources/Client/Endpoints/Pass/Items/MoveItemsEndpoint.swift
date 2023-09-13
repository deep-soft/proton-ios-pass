//
// MoveItemEndpoint.swift
// Proton Pass - Created on 29/03/2023.
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

import ProtonCoreNetworking
import ProtonCoreServices
import CryptoKit
import Foundation

public struct MoveItemsResponse: Decodable {
    let code: Int
    let items: [ItemRevision]
}

public struct MoveItemsEndpoint: Endpoint {
    public typealias Body = MoveItemsRequest
    public typealias Response = MoveItemsResponse

    public var debugDescription: String
    public var path: String
    public var method: HTTPMethod
    public var body: MoveItemRequest?

    public init(request: MoveItemRequest, fromShareId: String) {
        debugDescription = "Move item"
        path = "/pass/v1/share/\(fromShareId)/item/\(itemId)/share"
        method = .put
        body = request
    }
}

public struct MoveItemsRequest: Encodable {
    /// Encrypted ID of the destination share
    public let shareId: String
    public let items: [ItemToBeMoved]
    
    enum CodingKeys: String, CodingKey {
        case shareId = "ShareID"
        case items = "Items"
    }
}

extension MoveItemsRequest {
    init(itemsContent: [ProtobufableItemContentProtocol],
         destinationShareId: String,
         destinationShareKey: DecryptedShareKey) throws {
        let encryptedItems = try itemsContent.map { try Self.createItemRevision(itemContent: $0,
                                                                       destinationShareId: destinationShareId,
                                                                       destinationShareKey: destinationShareKey) }
        self.init(shareId: destinationShareId,
                  items: encryptedItems)
    }
    
    private static func createItemRevision(itemContent: ProtobufableItemContentProtocol,
                                    destinationShareId: String,
                                    destinationShareKey: DecryptedShareKey) throws -> ItemToBeMoved {
        let itemKey = try Data.random()
        let encryptedContent = try AES.GCM.seal(itemContent.data(),
                                                key: itemKey,
                                                associatedData: .itemContent)
        
        guard let content = encryptedContent.combined?.base64EncodedString() else {
            throw PPClientError.crypto(.failedToAESEncrypt)
        }
        
        let encryptedItemKey = try AES.GCM.seal(itemKey,
                                                key: destinationShareKey.keyData,
                                                associatedData: .itemKey)
        let encryptedItemKeyData = encryptedItemKey.combined ?? .init()
        return ItemToBeMoved(keyRotation: destinationShareKey.keyRotation,
                            contentFormatVersion: 1,
                            content: content,
                            itemKey: encryptedItemKeyData.base64EncodedString())
    }
}


public struct MoveItemsEndpoint: Endpoint {
    public typealias Body = MoveItemRequest
    public typealias Response = MoveItemResponse

    public var debugDescription: String
    public var path: String
    public var method: HTTPMethod
    public var body: MoveItemsRequest?

    public init(request: MoveItemsRequest, fromShareId: String) {
        debugDescription = "Move item"
        path = "/pass/v1/share/\(fromShareId)/item/share"
        method = .put
        body = request
    }
}
