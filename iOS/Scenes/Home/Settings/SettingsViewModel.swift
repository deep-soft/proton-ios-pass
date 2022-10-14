//
// SettingsViewModel.swift
// Proton Pass - Created on 28/09/2022.
// Copyright (c) 2022 Proton Technologies AG
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
import CryptoKit
import SwiftUI

final class SettingsViewModel: BaseViewModel, DeinitPrintable, ObservableObject {
    private let itemRepository: ItemRepositoryProtocol
    private let credentialManager: CredentialManagerProtocol
    private let symmetricKey: SymmetricKey
    let preferences: Preferences

    @Published var quickTypeBar = true {
        didSet {
            populateOrRemoveCredentials()
        }
    }

    /// Whether user has picked Proton Pass as AutoFill provider in Settings
    @Published private(set) var autoFillEnabled = false {
        didSet {
            populateOrRemoveCredentials()
        }
    }

    var onToggleSidebar: (() -> Void)?

    init(itemRepository: ItemRepositoryProtocol,
         credentialManager: CredentialManagerProtocol,
         symmetricKey: SymmetricKey,
         preferences: Preferences) {
        self.itemRepository = itemRepository
        self.credentialManager = credentialManager
        self.symmetricKey = symmetricKey
        self.preferences = preferences
        super.init()
        self.quickTypeBar = preferences.quickTypeBar
        self.updateAutoFillAvalability()

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.updateAutoFillAvalability()
            }
            .store(in: &cancellables)
    }

    private func updateAutoFillAvalability() {
        Task { @MainActor in
            self.autoFillEnabled = await credentialManager.isAutoFillEnabled()
        }
    }

    private func populateOrRemoveCredentials() {
        // When not enabled, iOS already deleted the credential database.
        // Atempting to populate this database will throw an error anyway so early exit here
        guard autoFillEnabled else { return }

        guard quickTypeBar != preferences.quickTypeBar else { return }
        Task { @MainActor in
            defer { isLoading = false }
            do {
                isLoading = true
                if quickTypeBar {
                    try await credentialManager.insertAllCredentials(from: itemRepository,
                                                                     symmetricKey: symmetricKey,
                                                                     forceRemoval: true)
                } else {
                    try await credentialManager.removeAllCredentials()
                }
                preferences.quickTypeBar = quickTypeBar
            } catch {
                self.quickTypeBar.toggle() // rollback to previous value
                self.error = error
            }
        }
    }
}

// MARK: - Actions
extension SettingsViewModel {
    func toggleSidebar() { onToggleSidebar?() }
}