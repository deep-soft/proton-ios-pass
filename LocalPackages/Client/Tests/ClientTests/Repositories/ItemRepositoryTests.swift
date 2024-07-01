//  
// ItemRepositoryTests.swift
// Proton Pass - Created on 01/12/2023.
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

@testable import Client
import Combine
import ClientMocks
import Core
import CoreMocks
import Entities
import XCTest

final class ItemRepositoryTests: XCTestCase {
    var symmetricKeyProvider: SymmetricKeyProviderMock!
    var userManager: UserManagerProtocolMock!
    var localDatasource: LocalItemDatasourceProtocolMock!
    var remoteDatasource: RemoteItemDatasourceProtocol!
    var shareEventIDRepository: ShareEventIDRepositoryProtocol!
    var passKeyManager: PassKeyManagerProtocol!
    var logManager: LogManagerProtocol!
    var sut: ItemRepositoryProtocol!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        symmetricKeyProvider = SymmetricKeyProviderMock()
         localDatasource = LocalItemDatasourceProtocolMock()
            userManager = UserManagerProtocolMock()
         localDatasource.stubbedGetAllPinnedItemsResult = []
         remoteDatasource = RemoteItemDatasourceProtocolMock()
         shareEventIDRepository = ShareEventIDRepositoryProtocolMock()
         passKeyManager = PassKeyManagerProtocolMock()
         logManager = LogManagerProtocolMock()
        cancellables = []
    }

    override func tearDown() {
        symmetricKeyProvider = nil
        localDatasource = nil
        remoteDatasource = nil
        shareEventIDRepository = nil
        passKeyManager = nil
        logManager = nil
        sut = nil
        super.tearDown()
    }
}

// MARK: - Pinned tests

extension ItemRepositoryTests {
    
    func testGetAllPinnedItem() async throws {
    let currentUserId = "test"

        localDatasource.stubbedGetAllPinnedItemsResult = [SymmetricallyEncryptedItem].random(count: 10, randomElement: .random(userId: currentUserId,
                                                                                                                               item:.random(pinned: true)))
        userManager.stubbedGetActiveUserIdResult = currentUserId

        sut = ItemRepository(symmetricKeyProvider: symmetricKeyProvider, 
                             userManager: userManager,
                             localDatasource: localDatasource,
                             remoteDatasource: remoteDatasource,
                             shareEventIDRepository: shareEventIDRepository,
                             passKeyManager: passKeyManager,
                             logManager: logManager)
        
        let expectation = expectation(description: "Init of ItemRepository")
        
        let pinnedItems = try await sut.getAllPinnedItems()
        var currentlyPinnedItems:[SymmetricallyEncryptedItem]?
        sut.currentlyPinnedItems
            .sink { value in
                currentlyPinnedItems = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 1, enforceOrder: true)

        XCTAssertFalse(pinnedItems.isEmpty)
        XCTAssertEqual(pinnedItems.count, 10)
        XCTAssertEqual(currentlyPinnedItems?.count, 10)
        XCTAssertTrue(localDatasource.invokedGetAllPinnedItemsfunction)
        XCTAssertEqual(localDatasource.invokedGetAllPinnedItemsCount, 2)
    }
}
