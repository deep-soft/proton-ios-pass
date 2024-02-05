//
// UpdateSpotlightVaults.swift
// Proton Pass - Created on 01/02/2024.
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
import Foundation

public protocol UpdateSpotlightVaultsUseCase: Sendable {
    func execute(for vaults: [Vault]) async throws
}

public extension UpdateSpotlightVaultsUseCase {
    func callAsFunction(for vaults: [Vault]) async throws {
        try await execute(for: vaults)
    }
}

public final class UpdateSpotlightVaults: UpdateSpotlightVaultsUseCase {
    private let userDataProvider: any UserDataProvider
    private let datasource: any LocalSpotlightVaultDatasourceProtocol

    public init(userDataProvider: any UserDataProvider,
                datasource: any LocalSpotlightVaultDatasourceProtocol) {
        self.userDataProvider = userDataProvider
        self.datasource = datasource
    }

    public func execute(for vaults: [Vault]) async throws {
        let userId = try userDataProvider.getUserId()
        try await datasource.setIds(for: userId, ids: vaults.map(\.shareId))
    }
}
