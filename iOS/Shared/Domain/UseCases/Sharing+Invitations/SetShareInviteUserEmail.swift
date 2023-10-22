//
//
// SetShareInviteUserEmail.swift
// Proton Pass - Created on 20/07/2023.
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

import Entities

protocol SetShareInviteUserEmailAndKeysUseCase {
    func execute(with email: String, and publicKeys: [PublicKey]?)
}

extension SetShareInviteUserEmailAndKeysUseCase {
    func callAsFunction(with email: String, and publicKeys: [PublicKey]?) {
        execute(with: email, and: publicKeys)
    }
}

final class SetShareInviteUserEmailAndKeys: SetShareInviteUserEmailAndKeysUseCase {
    private let shareInviteService: ShareInviteServiceProtocol

    init(shareInviteService: ShareInviteServiceProtocol) {
        self.shareInviteService = shareInviteService
    }

    func execute(with email: String, and publicKeys: [PublicKey]?) {
        shareInviteService.setCurrentDestinationUserEmail(with: email)
        if let publicKeys {
            shareInviteService.setReceiverPublicKeys(with: publicKeys)
        }
    }
}