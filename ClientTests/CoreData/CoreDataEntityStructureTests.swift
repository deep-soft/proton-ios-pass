//
// CoreDataEntityStructureTests.swift
// Proton Pass - Created on 02/08/2022.
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
import CoreData
import XCTest

final class CoreDataEntityStructureTests: XCTestCase {
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = .Builder.build(name: kProtonPassContainerName, inMemory: true)
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    func verifyAttribute(named name: String,
                         on entity: NSEntityDescription,
                         hasType type: NSAttributeDescription.AttributeType) {
        guard !name.isEmpty else {
            XCTFail("Attribute name can not be empty")
            return
        }
        guard let attribute = entity.attributesByName[name] else {
            XCTFail("\(entity.name ?? "") is missing expected attribute \(name)")
            return
        }
        XCTAssertEqual(attribute.type, type)
    }

    func entity(byName name: String) -> NSEntityDescription {
        guard let entity = container.managedObjectModel.entitiesByName[name] else {
            continueAfterFailure = false
            XCTFail("Entity \(name) not found")

            // fatalError() to trick the compiler.
            // Should not be called because stopped by `continueAfterFailure = false` above
            fatalError("👻🐶😜")
        }
        return entity
    }

    func testItemKeyEntity() {
        let sut = entity(byName: "ItemKeyEntity")
        verifyAttribute(named: "createTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "key", on: sut, hasType: .string)
        verifyAttribute(named: "keyPassphrase", on: sut, hasType: .string)
        verifyAttribute(named: "keySignature", on: sut, hasType: .string)
        verifyAttribute(named: "rotationID", on: sut, hasType: .string)
        verifyAttribute(named: "shareID", on: sut, hasType: .string)
    }

    func testShareEntity() {
        let sut = entity(byName: "ShareEntity")
        verifyAttribute(named: "content", on: sut, hasType: .string)
        verifyAttribute(named: "contentFormatVersion", on: sut, hasType: .integer16)
        verifyAttribute(named: "contentKeyRotation", on: sut, hasType: .integer16)
        verifyAttribute(named: "createTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "expireTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "permission", on: sut, hasType: .integer16)
        verifyAttribute(named: "shareID", on: sut, hasType: .string)
        verifyAttribute(named: "targetID", on: sut, hasType: .string)
        verifyAttribute(named: "targetType", on: sut, hasType: .integer16)
        verifyAttribute(named: "vaultID", on: sut, hasType: .string)
        verifyAttribute(named: "addressID", on: sut, hasType: .string)
    }

    func testVaultKeyEntity() {
        let sut = entity(byName: "VaultKeyEntity")
        verifyAttribute(named: "createTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "key", on: sut, hasType: .string)
        verifyAttribute(named: "keyPassphrase", on: sut, hasType: .string)
        verifyAttribute(named: "keySignature", on: sut, hasType: .string)
        verifyAttribute(named: "rotation", on: sut, hasType: .integer64)
        verifyAttribute(named: "rotationID", on: sut, hasType: .string)
        verifyAttribute(named: "shareID", on: sut, hasType: .string)
    }

    func testItemEntity() {
        let sut = entity(byName: "ItemEntity")
        verifyAttribute(named: "aliasEmail", on: sut, hasType: .string)
        verifyAttribute(named: "content", on: sut, hasType: .string)
        verifyAttribute(named: "contentFormatVersion", on: sut, hasType: .integer16)
        verifyAttribute(named: "createTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "itemID", on: sut, hasType: .string)
        verifyAttribute(named: "itemKeySignature", on: sut, hasType: .string)
        verifyAttribute(named: "modifyTime", on: sut, hasType: .integer64)
        verifyAttribute(named: "revision", on: sut, hasType: .integer16)
        verifyAttribute(named: "rotationID", on: sut, hasType: .string)
        verifyAttribute(named: "shareID", on: sut, hasType: .string)
        verifyAttribute(named: "signatureEmail", on: sut, hasType: .string)
        verifyAttribute(named: "state", on: sut, hasType: .integer16)
        verifyAttribute(named: "userSignature", on: sut, hasType: .string)
        verifyAttribute(named: "symmetricallyEncryptedContent", on: sut, hasType: .string)
        verifyAttribute(named: "isLogInItem", on: sut, hasType: .boolean)
        verifyAttribute(named: "lastUseTime", on: sut, hasType: .integer64)
    }

    func testShareEventIDEntity() {
        let sut = entity(byName: "ShareEventIDEntity")
        verifyAttribute(named: "userID", on: sut, hasType: .string)
        verifyAttribute(named: "shareID", on: sut, hasType: .string)
        verifyAttribute(named: "lastEventID", on: sut, hasType: .string)
    }
}
