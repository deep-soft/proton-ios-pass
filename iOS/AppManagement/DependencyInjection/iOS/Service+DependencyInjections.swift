//
// Service+DependencyInjections.swift
// Proton Pass - Created on 25/07/2023.
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

import Core
import Factory
import ProtonCoreAuthentication
import ProtonCorePayments
import ProtonCorePaymentsUI

final class ServiceContainer: SharedContainer, AutoRegistering {
    static let shared = ServiceContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

extension ServiceContainer {
    var paymentManager: Factory<PaymentsManager> {
        self { .init(storage: kSharedUserDefaults) }
    }

    var payments: Factory<Payments> {
        self {
            .init(inAppPurchaseIdentifiers: [],
                  apiService: SharedToolingContainer.shared.apiManager().apiService,
                  localStorage: UserDefaultsServicePlanDataStorage(storage: kSharedUserDefaults),
                  reportBugAlertHandler: nil)
        }
    }

    var paymentsUI: Factory<PaymentsUI> {
        self { .init(payments: self.payments(),
                     clientApp: .pass,
                     shownPlanNames: [],
                     customization: .init(inAppTheme: {
                         SharedToolingContainer.shared.preferences().theme.inAppTheme
                     }, customPlansDescription: [:])) }
    }

    var shareInviteService: Factory<ShareInviteServiceProtocol> {
        self { ShareInviteService() }
    }

    var authenticator: Factory<AuthenticatorInterface> {
        self { Authenticator(api: SharedToolingContainer.shared.apiManager().apiService) }
    }
}
