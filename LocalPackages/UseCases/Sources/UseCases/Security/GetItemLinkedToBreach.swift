//
//
// GetItemLinkedToBreach.swift
// Proton Pass - Created on 23/04/2024.
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
import Entities

public protocol GetItemsLinkedToBreachUseCase: Sendable {
    func execute(email: String) async throws -> [ItemUiModel]
}

public extension GetItemsLinkedToBreachUseCase {
    func callAsFunction(email: String) async throws -> [ItemUiModel] {
        try await execute(email: email)
    }
}

public final class GetItemsLinkedToBreach: GetItemsLinkedToBreachUseCase {
    private let symmetricKeyProvider: any SymmetricKeyProvider
    private let repository: any ItemRepositoryProtocol

    public init(symmetricKeyProvider: any SymmetricKeyProvider,
                repository: any ItemRepositoryProtocol) {
        self.symmetricKeyProvider = symmetricKeyProvider
        self.repository = repository
    }

    public func execute(email: String) async throws -> [ItemUiModel] {
        let symmetricKey = try symmetricKeyProvider.getSymmetricKey()
        let encryptedItems = try await repository.getAllItems()
        return encryptedItems.compactMap { element in
            guard let uimodel = try? element.toItemUiModel(symmetricKey),
                  uimodel.type == .login || (uimodel.type == .alias && uimodel.description != email),
                  uimodel.description.contains(email) else {
                return nil
            }
            return uimodel
        }
    }
}
