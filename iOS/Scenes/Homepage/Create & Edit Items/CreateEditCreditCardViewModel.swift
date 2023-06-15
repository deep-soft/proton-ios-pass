//
// CreateEditCreditCardViewModel.swift
// Proton Pass - Created on 13/06/2023.
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
import Core
import SwiftUI

final class CreateEditCreditCardViewModel: BaseCreateEditItemViewModel, DeinitPrintable, ObservableObject {
    deinit { print(deinitMessage) }

    @Published var title = ""
    @Published var cardholderName = ""
    @Published var cardNumber = ""
    @Published var verificationNumber = ""
    @Published var month: Int?
    @Published var year: Int?
    @Published var note = ""

    override func itemContentType() -> ItemContentType { .creditCard }

    override var isSaveable: Bool { !title.isEmpty }

    override init(mode: ItemMode,
                  itemRepository: ItemRepositoryProtocol,
                  upgradeChecker: UpgradeCheckerProtocol,
                  featureFlagsRepository: FeatureFlagsRepositoryProtocol,
                  vaults: [Vault],
                  preferences: Preferences,
                  logManager: LogManager) throws {
        try super.init(mode: mode,
                       itemRepository: itemRepository,
                       upgradeChecker: upgradeChecker,
                       featureFlagsRepository: featureFlagsRepository,
                       vaults: vaults,
                       preferences: preferences,
                       logManager: logManager)

        $cardNumber
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .map { $0.toCreditCardNumber() }
            .sink { [unowned self] formattedCardNumber in
                self.cardNumber = formattedCardNumber
            }
            .store(in: &cancellables)
    }
}