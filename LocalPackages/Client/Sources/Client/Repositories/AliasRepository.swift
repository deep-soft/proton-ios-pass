//
// AliasRepository.swift
// Proton Pass - Created on 14/09/2022.
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

import Core
import Entities

public protocol AliasRepositoryProtocol: Sendable {
    func getAliasOptions(shareId: String) async throws -> AliasOptions
    func getAliasDetails(shareId: String, itemId: String) async throws -> Alias
    @discardableResult
    func changeMailboxes(shareId: String, itemId: String, mailboxIDs: [Int]) async throws -> Alias

    // MARK: - Simple login alias Sync

    func getAliasSyncStatus(userId: String) async throws -> AliasSyncStatus
    func enableSlAliasSync(userId: String, defaultShareID: String?) async throws
    func getPendingAliasesToSync(userId: String,
                                 since: String?,
                                 pageSize: Int) async throws -> PaginatedPendingAliases

    func getAliasSettings(userId: String) async throws -> AliasSettings
    @discardableResult
    func updateAliasDefaultDomain(userId: String, request: UpdateAliasDomainRequest) async throws -> AliasSettings
    @discardableResult
    func updateAliasDefaultMailbox(userId: String, request: UpdateAliasMailboxRequest) async throws
        -> AliasSettings
    func getAllAliasDomains(userId: String) async throws -> [Domain]
    func getAllAliasMailboxes(userId: String) async throws -> [MailboxSettings]
}

public extension AliasRepositoryProtocol {
    func getPendingAliasesToSync(userId: String,
                                 since: String?) async throws -> PaginatedPendingAliases {
        try await getPendingAliasesToSync(userId: userId, since: since, pageSize: Constants.Utils.defaultPageSize)
    }
}

public actor AliasRepository: AliasRepositoryProtocol {
    private let remoteDatasource: any RemoteAliasDatasourceProtocol
    private let userManager: any UserManagerProtocol

    public init(remoteDatasource: any RemoteAliasDatasourceProtocol,
                userManager: any UserManagerProtocol) {
        self.remoteDatasource = remoteDatasource
        self.userManager = userManager
    }
}

public extension AliasRepository {
    func getAliasOptions(shareId: String) async throws -> AliasOptions {
        let userId = try await userManager.getActiveUserId()
        return try await remoteDatasource.getAliasOptions(userId: userId, shareId: shareId)
    }

    func getAliasDetails(shareId: String, itemId: String) async throws -> Alias {
        let userId = try await userManager.getActiveUserId()
        return try await remoteDatasource.getAliasDetails(userId: userId, shareId: shareId, itemId: itemId)
    }

    func changeMailboxes(shareId: String, itemId: String, mailboxIDs: [Int]) async throws -> Alias {
        let userId = try await userManager.getActiveUserId()
        return try await remoteDatasource.changeMailboxes(userId: userId,
                                                          shareId: shareId,
                                                          itemId: itemId,
                                                          mailboxIDs: mailboxIDs)
    }
}

// MARK: - Simple login alias Sync

public extension AliasRepository {
    func getAliasSyncStatus(userId: String) async throws -> AliasSyncStatus {
        try await remoteDatasource.getAliasSyncStatus(userId: userId)
    }

    func enableSlAliasSync(userId: String, defaultShareID: String?) async throws {
        try await remoteDatasource.enableSlAliasSync(userId: userId, defaultShareID: defaultShareID)
    }

    func getPendingAliasesToSync(userId: String,
                                 since: String?,
                                 pageSize: Int = Constants.Utils
                                     .defaultPageSize) async throws -> PaginatedPendingAliases {
        try await remoteDatasource.getPendingAliasesToSync(userId: userId, since: since, pageSize: pageSize)
    }

    func getAliasSettings(userId: String) async throws -> AliasSettings {
        try await remoteDatasource.getAliasSettings(userId: userId)
    }

    func updateAliasDefaultDomain(userId: String,
                                  request: UpdateAliasDomainRequest) async throws -> AliasSettings {
        try await remoteDatasource.updateAliasDefaultDomain(userId: userId, request: request)
    }

    func updateAliasDefaultMailbox(userId: String,
                                   request: UpdateAliasMailboxRequest) async throws -> AliasSettings {
        try await remoteDatasource.updateAliasDefaultMailbox(userId: userId, request: request)
    }

    func getAllAliasDomains(userId: String) async throws -> [Domain] {
        try await remoteDatasource.getAllAliasDomains(userId: userId)
    }

    func getAllAliasMailboxes(userId: String) async throws -> [MailboxSettings] {
        try await remoteDatasource.getAllAliasMailboxes(userId: userId)
    }
}
