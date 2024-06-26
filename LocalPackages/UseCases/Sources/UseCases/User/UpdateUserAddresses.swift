//
//
// UpdateUserAddresses.swift
// Proton Pass - Created on 17/10/2023.
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
//

import Client

@preconcurrency import ProtonCoreAuthentication
import ProtonCoreDataModel
import ProtonCoreLogin
import ProtonCoreNetworking

public protocol UpdateUserAddressesUseCase: Sendable {
    func execute() async throws -> [Address]?
}

public extension UpdateUserAddressesUseCase {
    func callAsFunction() async throws -> [Address]? {
        try await execute()
    }
}

public final class UpdateUserAddresses: UpdateUserAddressesUseCase {
    private let userManager: any UserManagerProtocol
    private let authenticator: any AuthenticatorInterface

    public init(userManager: any UserManagerProtocol,
                authenticator: any AuthenticatorInterface) {
        self.userManager = userManager
        self.authenticator = authenticator
    }

    public func execute() async throws -> [Address]? {
        let userData = try await userManager.getUnwrappedActiveUserData()
        let newAddresses = try await authenticator.getAddresses(userData.getCredential)

        let newUserData = UserData(credential: userData.credential,
                                   user: userData.user,
                                   salts: userData.salts,
                                   passphrases: userData.passphrases,
                                   addresses: newAddresses,
                                   scopes: userData.scopes)

        try await userManager.add(userData: newUserData, isActive: false)
        return newAddresses
    }
}

private extension AuthenticatorInterface {
    func getAddresses(_ credential: Credential?) async throws -> [Address] {
        try await withCheckedThrowingContinuation { continuation in
            getAddresses(credential) { result in
                continuation.resume(with: result)
            }
        }
    }
}
