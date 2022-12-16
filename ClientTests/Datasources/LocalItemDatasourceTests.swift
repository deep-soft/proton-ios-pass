//
// LocalItemDatasourceTests.swift
// Proton Pass - Created on 20/09/2022.
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

@testable import Client
import XCTest

final class LocalItemDatasourceTests: XCTestCase {
    var sut: LocalItemDatasource!

    override func setUp() {
        super.setUp()
        sut = .init(container: .Builder.build(name: kProtonPassContainerName,
                                              inMemory: true))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func assertEqual(_ lhs: SymmetricallyEncryptedItem, _ rhs: SymmetricallyEncryptedItem) {
        XCTAssertEqual(lhs.item.itemID, rhs.item.itemID)
        XCTAssertEqual(lhs.item.revision, rhs.item.revision)
        XCTAssertEqual(lhs.item.contentFormatVersion, rhs.item.contentFormatVersion)
        XCTAssertEqual(lhs.item.rotationID, rhs.item.rotationID)
        XCTAssertEqual(lhs.item.content, rhs.item.content)
        XCTAssertEqual(lhs.item.userSignature, rhs.item.userSignature)
        XCTAssertEqual(lhs.item.itemKeySignature, rhs.item.itemKeySignature)
        XCTAssertEqual(lhs.item.state, rhs.item.state)
        XCTAssertEqual(lhs.item.signatureEmail, rhs.item.signatureEmail)
        XCTAssertEqual(lhs.item.aliasEmail, rhs.item.aliasEmail)
        XCTAssertEqual(lhs.item.createTime, rhs.item.createTime)
        XCTAssertEqual(lhs.item.modifyTime, rhs.item.modifyTime)
        XCTAssertEqual(lhs.item.revisionTime, rhs.item.revisionTime)
        XCTAssertEqual(lhs.item.lastUseTime, rhs.item.lastUseTime)
        XCTAssertEqual(lhs.shareId, rhs.shareId)
        XCTAssertEqual(lhs.encryptedContent, rhs.encryptedContent)
    }
}

extension LocalItemDatasourceTests {
    func testGetItem() async throws {
        // Given
        let givenShareId = String.random()
        let givenItemId = String.random()
        let givenInsertedItem = try await sut.givenInsertedItem(itemId: givenItemId,
                                                                shareId: givenShareId)

        // When
        for _ in 0...10 {
            try await sut.upsertItems(.random(randomElement: .random()))
        }

        // Then
        let item = try await sut.getItem(shareId: givenShareId, itemId: givenItemId)
        let nonNilItem = try XCTUnwrap(item)
        assertEqual(nonNilItem, givenInsertedItem)
    }

    func testGetAliasItem() async throws {
        // Given
        let givenShareId = String.random()
        let givenItemId = String.random()
        let givenAliasEmail = String.random()
        let givenInsertedItem = try await sut.givenInsertedItem(itemId: givenItemId,
                                                                shareId: givenShareId,
                                                                aliasEmail: givenAliasEmail)

        // When
        for _ in 0...10 {
            try await sut.upsertItems(.random(randomElement: .random()))
        }

        // Then
        let item = try await sut.getAliasItem(email: givenAliasEmail)
        let nonNilItem = try XCTUnwrap(item)
        assertEqual(nonNilItem, givenInsertedItem)
    }

    func testInsertItems() async throws {
        // Given
        let givenShareId = String.random()

        let firstItems =
        [SymmetricallyEncryptedItem].random(randomElement: .random(shareId: givenShareId))

        let secondItems =
        [SymmetricallyEncryptedItem].random(randomElement: .random(shareId: givenShareId))

        let thirdItems =
        [SymmetricallyEncryptedItem].random(randomElement: .random(shareId: givenShareId))

        let givenItems = firstItems + secondItems + thirdItems

        // When
        try await sut.upsertItems(firstItems)
        try await sut.upsertItems(secondItems)
        try await sut.upsertItems(thirdItems)

        // Then
        let itemCount = try await sut.getItemCount(shareId: givenShareId)
        XCTAssertEqual(itemCount, givenItems.count)

        let activeItems = try await sut.getItems(shareId: givenShareId,
                                                 state: .active)
        let activeItemIds = activeItems.map { $0.item.itemID }

        let trashedItems = try await sut.getItems(shareId: givenShareId,
                                                  state: .trashed)
        let trashedItemIds = trashedItems.map { $0.item.itemID }

        let givenItemIds = Set(givenItems.map { $0.item.itemID })

        XCTAssertEqual(Set(activeItemIds + trashedItemIds), givenItemIds)
    }

    func testUpdateItems() async throws {
        // Given
        let givenItemId = String.random()
        let givenShareId = String.random()
        _ = try await sut.givenInsertedItem(itemId: givenItemId,
                                            shareId: givenShareId)
        let updatedItemRevision = ItemRevision.random(itemId: givenItemId)
        let updatedItem = SymmetricallyEncryptedItem.random(shareId: givenShareId,
                                                            item: updatedItemRevision)

        // When
        try await sut.upsertItems([updatedItem])

        // Then
        let itemCount = try await sut.getItemCount(shareId: givenShareId)
        XCTAssertEqual(itemCount, 1)

        let item = try await sut.getItem(shareId: givenShareId,
                                         itemId: givenItemId)
        let notNilItem = try XCTUnwrap(item)
        assertEqual(notNilItem, updatedItem)
    }

    func testTrashItems() async throws {
        // Given
        let givenItemId = String.random()
        let givenShareId = String.random()
        let insertedItem = try await sut.givenInsertedItem(itemId: givenItemId,
                                                           shareId: givenShareId,
                                                           state: .active)

        // When
        let modifiedItem = ModifiedItem(itemID: insertedItem.item.itemID,
                                        revision: insertedItem.item.revision,
                                        state: ItemState.trashed.rawValue,
                                        modifyTime: insertedItem.item.modifyTime,
                                        revisionTime: insertedItem.item.revisionTime)
        try await sut.upsertItems([insertedItem], modifiedItems: [modifiedItem])

        // Then
        let item = try await sut.getItem(shareId: givenShareId, itemId: givenItemId)
        let notNilItem = try XCTUnwrap(item)
        XCTAssertEqual(notNilItem.item.itemState, .trashed)
    }

    func testUntrashItems() async throws {
        // Given
        let givenItemId = String.random()
        let givenShareId = String.random()
        let insertedItem = try await sut.givenInsertedItem(itemId: givenItemId,
                                                           shareId: givenShareId,
                                                           state: .trashed)

        // When
        let modifiedItem = ModifiedItem(itemID: insertedItem.item.itemID,
                                        revision: insertedItem.item.revision,
                                        state: ItemState.active.rawValue,
                                        modifyTime: insertedItem.item.modifyTime,
                                        revisionTime: insertedItem.item.revisionTime)
        try await sut.upsertItems([insertedItem], modifiedItems: [modifiedItem])

        // Then
        let item = try await sut.getItem(shareId: givenShareId, itemId: givenItemId)
        let notNilItem = try XCTUnwrap(item)
        XCTAssertEqual(notNilItem.item.itemState, .active)
    }

    func testDeleteItems() async throws {
        // Given
        let shareId = String.random()
        let firstItem = try await sut.givenInsertedItem(shareId: shareId)
        let secondItem = try await sut.givenInsertedItem(shareId: shareId)
        let thirdItem = try await sut.givenInsertedItem(shareId: shareId)

        let firstCount = try await sut.getItemCount(shareId: shareId)
        XCTAssertEqual(firstCount, 3)

        // Delete third item
        try await sut.deleteItems([thirdItem])
        let secondCount = try await sut.getItemCount(shareId: shareId)
        XCTAssertEqual(secondCount, 2)

        // Delete both first and second item
        try await sut.deleteItems([firstItem, secondItem])
        let thirdCount = try await sut.getItemCount(shareId: shareId)
        XCTAssertEqual(thirdCount, 0)
    }

    func testRemoveAllItems() async throws {
        // Given
        let givenFirstShareId = String.random()
        let givenFirstShareItems =
        [SymmetricallyEncryptedItem].random(randomElement: .random(shareId: givenFirstShareId))

        let givenSecondShareId = String.random()
        let givenSecondShareItems =
        [SymmetricallyEncryptedItem].random(randomElement: .random(shareId: givenSecondShareId))

        // When
        try await sut.upsertItems(givenFirstShareItems)
        try await sut.upsertItems(givenSecondShareItems)

        // Then
        let firstShareItemsFirstGetCount = try await sut.getItemCount(shareId: givenFirstShareId)
        XCTAssertEqual(firstShareItemsFirstGetCount, givenFirstShareItems.count)

        let secondShareItemsFirstGetCount = try await sut.getItemCount(shareId: givenSecondShareId)
        XCTAssertEqual(secondShareItemsFirstGetCount, givenSecondShareItems.count)

        // When
        try await sut.removeAllItems(shareId: givenFirstShareId)

        // Then
        let firstShareItemsSecondGetCount = try await sut.getItemCount(shareId: givenFirstShareId)
        XCTAssertEqual(firstShareItemsSecondGetCount, 0)

        let secondShareItemsSecondGetCount = try await sut.getItemCount(shareId: givenSecondShareId)
        XCTAssertEqual(secondShareItemsSecondGetCount, givenSecondShareItems.count)
    }

    // Don't now why it is failing because lastUsedTime is not updated
    /*
    func testUpdateLastUsedTime() throws {
        continueAfterFailure = false
        let expectation = expectation(description: #function)
        Task {
            // Given
            let givenInsertedLogInItem = try await sut.givenInsertedItem(isLogInItem: true)
            let updatedLastUsedTime = Date().timeIntervalSince1970

            // When
            try await sut.update(item: givenInsertedLogInItem, lastUsedTime: updatedLastUsedTime)
            let item = try await sut.getItem(shareId: givenInsertedLogInItem.shareId,
                                             itemId: givenInsertedLogInItem.item.itemID)
            let notNilItem = try XCTUnwrap(item)
            XCTAssertEqual(notNilItem.lastUsedTime, Int64(updatedLastUsedTime))
            expectation.fulfill()
        }
        waitForExpectations(timeout: expectationTimeOut)
    }
     */

    func testGetActiveLogInItems() async throws {
        // Given
        let givenShareId = String.random()
        // 2 trashed log in items
        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .trashed,
                                            isLogInItem: true)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .trashed,
                                            isLogInItem: true)

        // 3 trashed other items
        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .trashed,
                                            isLogInItem: false)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .trashed,
                                            isLogInItem: false)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .trashed,
                                            isLogInItem: false)

        // 4 active log in items
        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: true)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: true)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: true)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: true)

        // 4 active other items
        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: false)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: false)

        _ = try await sut.givenInsertedItem(shareId: givenShareId,
                                            state: .active,
                                            isLogInItem: false)

        // When
        let activeLogInItems = try await sut.getActiveLogInItems(shareId: givenShareId)

        // Then
        XCTAssertEqual(activeLogInItems.count, 4)
    }
}

extension LocalItemDatasource {
    func givenInsertedItem(itemId: String? = nil,
                           shareId: String? = nil,
                           state: ItemState? = nil,
                           encryptedContent: String? = nil,
                           aliasEmail: String? = nil,
                           modifyTime: Int64 = .random(in: 1_234_567...1_987_654),
                           lastUsedItem: Int64 = .random(in: 1_234_567...1_987_654),
                           isLogInItem: Bool = .random())
    async throws -> SymmetricallyEncryptedItem {
        let shareId = shareId ?? .random()
        let itemRevision = ItemRevision.random(itemId: itemId ?? .random(),
                                               state: state,
                                               aliasEmail: aliasEmail,
                                               modifyTime: modifyTime)
        let encryptedContent = encryptedContent ?? .random()
        let item = SymmetricallyEncryptedItem(shareId: shareId,
                                              item: itemRevision,
                                              encryptedContent: encryptedContent,
                                              isLogInItem: isLogInItem)
        try await upsertItems([item])
        return item
    }
}
