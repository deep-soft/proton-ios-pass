//
// ItemKeyEntity.swift
// Proton Pass - Created on 18/07/2022.
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

import CoreData
import Foundation

@objc(ItemKeyEntity)
public final class ItemKeyEntity: NSManagedObject {}

extension ItemKeyEntity: Identifiable {}

extension ItemKeyEntity {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<ItemKeyEntity> {
        NSFetchRequest<ItemKeyEntity>(entityName: "ItemKeyEntity")
    }

    @NSManaged var createTime: Int64
    @NSManaged var key: String?
    @NSManaged var keyPassphrase: String?
    @NSManaged var keySignature: String?
    @NSManaged var rotationID: String?
    @NSManaged var shareID: String?
    @NSManaged var share: ShareEntity?
}

extension ItemKeyEntity {
    func toItemKey() throws -> ItemKey {
        guard let rotationID else {
            throw PPClientError.coreData(.corrupted(object: self, property: "rotationID"))
        }

        guard let key else {
            throw PPClientError.coreData(.corrupted(object: self, property: "key"))
        }

        guard let keySignature else {
            throw PPClientError.coreData(.corrupted(object: self, property: "keySignature"))
        }

        return .init(rotationID: rotationID,
                     key: key,
                     keyPassphrase: keyPassphrase,
                     keySignature: keySignature,
                     createTime: createTime)
    }

    func hydrate(from itemKey: ItemKey, shareId: String) {
        createTime = itemKey.createTime
        key = itemKey.key
        keyPassphrase = itemKey.keyPassphrase
        keySignature = itemKey.keySignature
        rotationID = itemKey.rotationID
        shareID = shareId
    }
}

extension ItemKeyEntity {
    class func allItemKeysFetchRequest(shareId: String) -> NSFetchRequest<ItemKeyEntity> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = .init(format: "shareID = %s", shareId)
        return fetchRequest
    }
}
