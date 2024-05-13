//
// GetLocalAuthenticationMethodsUseCase.swift
// Proton Pass - Created on 13/07/2023.
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

import Client
import Entities
import LocalAuthentication

/// Get supported local authentication  methods
public protocol GetLocalAuthenticationMethodsUseCase: Sendable {
    func execute(policy: LAPolicy) async throws -> [LocalAuthenticationMethodUiModel]
}

public extension GetLocalAuthenticationMethodsUseCase {
    func callAsFunction(policy: LAPolicy) async throws -> [LocalAuthenticationMethodUiModel] {
        try await execute(policy: policy)
    }
}

public final class GetLocalAuthenticationMethods: GetLocalAuthenticationMethodsUseCase {
    private let checkBiometryType: any CheckBiometryTypeUseCase
    private let accessRepository: any AccessRepositoryProtocol
    private let organizationRepository: any OrganizationRepositoryProtocol

    public init(checkBiometryType: any CheckBiometryTypeUseCase,
                accessRepository: any AccessRepositoryProtocol,
                organizationRepository: any OrganizationRepositoryProtocol) {
        self.checkBiometryType = checkBiometryType
        self.accessRepository = accessRepository
        self.organizationRepository = organizationRepository
    }

    public func execute(policy: LAPolicy) async throws -> [LocalAuthenticationMethodUiModel] {
        var supportedTypes = [LocalAuthenticationMethodUiModel]()

        if accessRepository.access.value?.plan.isBusinessUser == true {
            if let organization = try await organizationRepository.getOrganization(),
               organization.settings?.appLockTime == nil {
                supportedTypes.append(.none)
            }
        } else {
            supportedTypes.append(.none)
        }

        do {
            let biometryType = try checkBiometryType(policy: policy)
            if biometryType.usable {
                supportedTypes.append(.biometric(biometryType))
            }
        } catch {
            // We only want to throw unexpected errors
            // If biometry is not available or passcode is not set for whatever reason, we just ignore it
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryLockout,
                     .biometryNotAvailable,
                     .biometryNotEnrolled,
                     .passcodeNotSet:
                    break
                default:
                    throw error
                }
            }
            throw error
        }

        supportedTypes.append(.pin)
        return supportedTypes
    }
}
