//
// LocalUserPreferencesDatasource.swift
// Proton Pass - Created on 29/03/2024.
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

import CoreData
import Entities
import Foundation

public protocol LocalUserPreferencesDatasourceProtocol: Sendable {
    func getPreferences(for userId: String) async throws -> UserPreferences?
    func upsertPreferences(_ preferences: UserPreferences, for userId: String) async throws
    func removePreferences(for userId: String) async throws
}

public final class LocalUserPreferencesDatasource: LocalDatasource, LocalUserPreferencesDatasourceProtocol {
    private let symmetricKeyProvider: any SymmetricKeyProvider

    init(symmetricKeyProvider: any SymmetricKeyProvider,
         databaseService: any DatabaseServiceProtocol) {
        self.symmetricKeyProvider = symmetricKeyProvider
        super.init(databaseService: databaseService)
    }
}

public extension LocalUserPreferencesDatasource {
    func getPreferences(for userId: String) async throws -> UserPreferences? {
        let taskContext = newTaskContext(type: .fetch)
        let fetchRequest = UserPreferencesEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID = %@", userId)
        let entities = try await execute(fetchRequest: fetchRequest, context: taskContext)
        assert(entities.count <= 1, "Can not have more than 1 preferences per userId")
        let key = try symmetricKeyProvider.getSymmetricKey()
        return try entities.first?.toUserPreferences(key)
    }

    func upsertPreferences(_ preferences: UserPreferences, for userId: String) async throws {
        let taskContext = newTaskContext(type: .insert)

        let key = try symmetricKeyProvider.getSymmetricKey()
        var hydrationError: (any Error)?
        let batchInsertRequest =
            newBatchInsertRequest(entity: UserPreferencesEntity.entity(context: taskContext),
                                  sourceItems: [preferences]) { managedObject, preferences in
                do {
                    try (managedObject as? UserPreferencesEntity)?.hydrate(preferences: preferences,
                                                                           userId: userId,
                                                                           key: key)
                } catch {
                    hydrationError = error
                }
            }

        if let hydrationError {
            throw hydrationError
        }

        try await execute(batchInsertRequest: batchInsertRequest, context: taskContext)
    }

    func removePreferences(for userId: String) async throws {
        let taskContext = newTaskContext(type: .delete)
        let fetchRequest = NSFetchRequest<any NSFetchRequestResult>(entityName: "UserPreferencesEntity")
        fetchRequest.predicate = .init(format: "userID = %@", userId)
        try await execute(batchDeleteRequest: .init(fetchRequest: fetchRequest),
                          context: taskContext)
    }
}
