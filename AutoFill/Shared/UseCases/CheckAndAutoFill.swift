//
// CheckAndAutoFill.swift
// Proton Pass - Created on 24/02/2024.
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

import AuthenticationServices
import Client
import Entities
import Foundation

protocol CheckAndAutoFillUseCase: Sendable {
    func execute(_ request: AutoFillRequest,
                 context: ASCredentialProviderExtensionContext,
                 localAuthenticationMethod: LocalAuthenticationMethod) async throws
}

extension CheckAndAutoFillUseCase {
    func callAsFunction(_ request: AutoFillRequest,
                        context: ASCredentialProviderExtensionContext,
                        localAuthenticationMethod: LocalAuthenticationMethod) async throws {
        try await execute(request,
                          context: context,
                          localAuthenticationMethod: localAuthenticationMethod)
    }
}

final class CheckAndAutoFill: CheckAndAutoFillUseCase {
    private let credentialProvider: any CredentialProvider
    private let generateAuthorizationCredential: any GenerateAuthorizationCredentialUseCase
    private let cancelAutoFill: any CancelAutoFillUseCase
    private let completeAutoFill: any CompleteAutoFillUseCase
    private let userManager: any UserManagerProtocol

    init(credentialProvider: any CredentialProvider,
         userManager: any UserManagerProtocol,
         generateAuthorizationCredential: any GenerateAuthorizationCredentialUseCase,
         cancelAutoFill: any CancelAutoFillUseCase,
         completeAutoFill: any CompleteAutoFillUseCase) {
        self.credentialProvider = credentialProvider
        self.generateAuthorizationCredential = generateAuthorizationCredential
        self.cancelAutoFill = cancelAutoFill
        self.completeAutoFill = completeAutoFill
        self.userManager = userManager
    }

    func execute(_ request: AutoFillRequest,
                 context: ASCredentialProviderExtensionContext,
                 localAuthenticationMethod: LocalAuthenticationMethod) async throws {
        let userId = try await userManager.getActiveUserId()
        guard credentialProvider.isAuthenticated(userId: userId), localAuthenticationMethod == .none else {
            cancelAutoFill(reason: .userInteractionRequired, context: context)
            return
        }
        let (itemContent, credential) = try await generateAuthorizationCredential(request)
        try await completeAutoFill(quickTypeBar: true,
                                   identifiers: request.serviceIdentifiers,
                                   credential: credential,
                                   itemContent: itemContent,
                                   context: context)
    }
}
