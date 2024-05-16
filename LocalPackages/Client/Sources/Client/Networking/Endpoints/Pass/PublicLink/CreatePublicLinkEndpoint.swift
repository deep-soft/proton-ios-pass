//
// CreatePublicLinkEndpoint.swift
// Proton Pass - Created on 15/05/2024.
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

import Entities
import ProtonCoreNetworking
import ProtonCoreServices

struct CreatePublicLinkResponse: Decodable, Equatable, Sendable {
    let publicLink: SharedPublicLink
}

struct CreatePublicLinkRequest: Encodable, Sendable {
    /// Last revision of the item
    let revision: Int

    /// between 1 hour and 30 days in seconds [ 3600 .. 2592000 ]
    let expirationTime: Int

    /// Maximum amount of times that the item can be read. Unlimited reads if omitted
    let maxReadCount: Int?

    /// Encrypted item key encoded in base64
    let encryptedItemKey: String

    enum CodingKeys: String, CodingKey {
        case revision = "Revision"
        case expirationTime = "ExpirationTime"
        case maxReadCount = "MaxReadCount"
        case encryptedItemKey = "EncryptedItemKey"
    }
}

struct CreatePublicLinkEndpoint: Endpoint {
    typealias Body = CreatePublicLinkRequest
    typealias Response = CreatePublicLinkResponse

    var debugDescription: String
    var path: String
    var method: HTTPMethod
    var body: CreatePublicLinkRequest?

    init(shareId: String, itemId: String, request: CreatePublicLinkRequest) {
        debugDescription = "Create new public link"
        path = "/pass/v1/share/\(shareId)/item/\(itemId)/public_link"
        method = .post
        body = request
    }
}
