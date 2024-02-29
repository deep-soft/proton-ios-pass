//
// AutoFillMode.swift
// Proton Pass - Created on 23/02/2024.
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

/// Possible entry points when autofilling
enum AutoFillMode {
    case showAllLogins(ShowAllLoginsMode)
    case checkAndAutoFill(CheckAndAutoFillMode)
    case authenticateAndAutofill(AuthenticateAndAutofillMode)
    /// Proton Pass is chosen as credential provider in Settings
    case configuration
    case passkeyRegistration
}

/// User wants to manually select an item to autofill
enum ShowAllLoginsMode {
    case password([ASCredentialServiceIdentifier])
    case passkey([ASCredentialServiceIdentifier], PasskeyRequestParametersProtocol)
}

/// When user picks a proposed email from QuickType bar
/// Check if user has local authentication enabled (Face ID/Touch ID/PIN)
/// If authentication required: ask for authentication, pass to mode `AuthenticateAndAutofill`
/// If authentication not required: autofill straight away
enum CheckAndAutoFillMode {
    case password(ASPasswordCredentialIdentity)
    case passkey(PasskeyIdentityProtocol)
}

/// User picks a proposed email from QuickType bar but authentication (Face ID/Touch ID/PIN)  is required
enum AuthenticateAndAutofillMode {
    case password(ASPasswordCredentialIdentity)
    case passkey(PasskeyIdentityProtocol)
}
