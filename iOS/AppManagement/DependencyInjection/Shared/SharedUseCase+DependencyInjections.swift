//
// SharedUseCase+DependencyInjections.swift
// Proton Pass - Created on 11/07/2023.
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
import CryptoKit
import Factory
import LocalAuthentication
import UseCases

final class SharedUseCasesContainer: SharedContainer, AutoRegistering {
    static let shared = SharedUseCasesContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .shared
    }
}

// MARK: Computed properties

private extension SharedUseCasesContainer {
    var logManager: any LogManagerProtocol {
        SharedToolingContainer.shared.logManager()
    }

    var preferencesManager: any PreferencesManagerProtocol {
        SharedToolingContainer.shared.preferencesManager()
    }

    var credentialManager: any CredentialManagerProtocol {
        SharedServiceContainer.shared.credentialManager()
    }

    var itemRepository: any ItemRepositoryProtocol {
        SharedRepositoryContainer.shared.itemRepository()
    }

    var userManager: any UserManagerProtocol {
        SharedServiceContainer.shared.userManager()
    }

    var symmetricKeyProvider: any SymmetricKeyProvider {
        SharedDataContainer.shared.symmetricKeyProvider()
    }

    var userSettingsRepository: any UserSettingsRepositoryProtocol {
        SharedRepositoryContainer.shared.userSettingsRepository()
    }

    var accessRepository: any AccessRepositoryProtocol {
        SharedRepositoryContainer.shared.accessRepository()
    }
}

// MARK: Permission

extension SharedUseCasesContainer {
    var checkCameraPermission: Factory<any CheckCameraPermissionUseCase> {
        self { CheckCameraPermission() }
    }
}

// MARK: Local authentication

extension SharedUseCasesContainer {
    var checkBiometryType: Factory<any CheckBiometryTypeUseCase> {
        self { CheckBiometryType() }
    }

    var authenticateBiometrically: Factory<any AuthenticateBiometricallyUseCase> {
        self { AuthenticateBiometrically(keychainService: SharedToolingContainer.shared.keychain()) }
    }

    var getLocalAuthenticationMethods: Factory<any GetLocalAuthenticationMethodsUseCase> {
        self { GetLocalAuthenticationMethods(checkBiometryType: self.checkBiometryType(),
                                             accessRepository: self.accessRepository,
                                             organizationRepository: SharedRepositoryContainer.shared
                                                 .organizationRepository()) }
    }

    var saveAllLogs: Factory<any SaveAllLogsUseCase> {
        self { SaveAllLogs(logManager: self.logManager) }
    }
}

// MARK: Telemetry

extension SharedUseCasesContainer {
    var addTelemetryEvent: Factory<any AddTelemetryEventUseCase> {
        self { AddTelemetryEvent(repository: SharedRepositoryContainer.shared.telemetryEventRepository(),
                                 logManager: self.logManager) }
    }

    var setUpSentry: Factory<any SetUpSentryUseCase> {
        self { SetUpSentry() }
    }

    var sendErrorToSentry: Factory<any SendErrorToSentryUseCase> {
        self { SendErrorToSentry(userManager: self.userManager) }
    }

    var setCoreLoggerEnvironment: Factory<any SetCoreLoggerEnvironmentUseCase> {
        self { SetCoreLoggerEnvironment() }
    }

    var setUpCoreTelemetry: Factory<any SetUpCoreTelemetryUseCase> {
        self { SetUpCoreTelemetry(apiService: SharedToolingContainer.shared.apiManager().apiService,
                                  logManager: self.logManager,
                                  userSettingsRepository: self.userSettingsRepository,
                                  userManager: self.userManager) }
    }
}

// MARK: AutoFill

extension SharedUseCasesContainer {
    var mapLoginItem: Factory<any MapLoginItemUseCase> {
        self { MapLoginItem(symmetricKeyProvider: self.symmetricKeyProvider) }
    }

    var indexAllLoginItems: Factory<any IndexAllLoginItemsUseCase> {
        self { IndexAllLoginItems(itemRepository: self.itemRepository,
                                  shareRepository: SharedRepositoryContainer.shared.shareRepository(),
                                  accessRepository: self.accessRepository,
                                  credentialManager: self.credentialManager,
                                  mapLoginItem: self.mapLoginItem(),
                                  logManager: self.logManager) }
    }

    var unindexAllLoginItems: Factory<any UnindexAllLoginItemsUseCase> {
        self { UnindexAllLoginItems(manager: self.credentialManager) }
    }
}

// MARK: Spotlight

extension SharedUseCasesContainer {
    var indexItemsForSpotlight: Factory<any IndexItemsForSpotlightUseCase> {
        self { IndexItemsForSpotlight(userManager: self.userManager,
                                      itemRepository: self.itemRepository,
                                      datasource: SharedRepositoryContainer.shared
                                          .localSpotlightVaultDatasource(),
                                      logManager: self.logManager) }
    }
}

// MARK: Vault

extension SharedUseCasesContainer {
    var processVaultSyncEvent: Factory<any ProcessVaultSyncEventUseCase> {
        self { ProcessVaultSyncEvent() }
    }

    var getMainVault: Factory<any GetMainVaultUseCase> {
        self { GetMainVault(vaultsManager: SharedServiceContainer.shared.vaultsManager()) }
    }
}

// MARK: - Shares

extension SharedUseCasesContainer {
    var getCurrentSelectedShareId: Factory<any GetCurrentSelectedShareIdUseCase> {
        self { GetCurrentSelectedShareId(vaultsManager: SharedServiceContainer.shared.vaultsManager(),
                                         getMainVault: self.getMainVault()) }
    }
}

// MARK: - Feature Flags

extension SharedUseCasesContainer {
    // periphery:ignore
    var getFeatureFlagStatus: Factory<any GetFeatureFlagStatusUseCase> {
        self {
            GetFeatureFlagStatus(repository: SharedRepositoryContainer.shared.featureFlagsRepository())
        }
    }
}

// MARK: TOTP

extension SharedUseCasesContainer {
    var sanitizeTotpUriForEditing: Factory<any SanitizeTotpUriForEditingUseCase> {
        self { SanitizeTotpUriForEditing() }
    }

    var sanitizeTotpUriForSaving: Factory<any SanitizeTotpUriForSavingUseCase> {
        self { SanitizeTotpUriForSaving() }
    }

    var generateTotpToken: Factory<any GenerateTotpTokenUseCase> {
        self { GenerateTotpToken(totpService: SharedServiceContainer.shared.totpService()) }
    }
}

// MARK: Password Utils

extension SharedUseCasesContainer {
    var generatePassword: Factory<any GeneratePasswordUseCase> {
        self { GeneratePassword() }
    }

    var generateRandomWords: Factory<any GenerateRandomWordsUseCase> {
        self { GenerateRandomWords() }
    }

    var generatePassphrase: Factory<any GeneratePassphraseUseCase> {
        self { GeneratePassphrase() }
    }

    var getPasswordStrength: Factory<any GetPasswordStrengthUseCase> {
        self { GetPasswordStrength() }
    }
}

// MARK: Data

extension SharedUseCasesContainer {
    var revokeCurrentSession: Factory<any RevokeCurrentSessionUseCase> {
        self { RevokeCurrentSession(networkRepository: SharedRepositoryContainer.shared.networkRepository()) }
    }

    var deleteLocalDataBeforeFullSync: Factory<any DeleteLocalDataBeforeFullSyncUseCase> {
        self { DeleteLocalDataBeforeFullSync(itemRepository: self.itemRepository,
                                             shareRepository: SharedRepositoryContainer.shared.shareRepository(),
                                             shareKeyRepository: SharedRepositoryContainer.shared
                                                 .shareKeyRepository()) }
    }

    var wipeAllData: Factory<any WipeAllDataUseCase> {
        self { WipeAllData(logManager: self.logManager,
                           appData: SharedDataContainer.shared.appData(),
                           apiManager: SharedToolingContainer.shared.apiManager(),
                           preferencesManager: self.preferencesManager,
                           databaseService: SharedServiceContainer.shared.databaseService(),
                           syncEventLoop: SharedServiceContainer.shared.syncEventLoop(),
                           vaultsManager: SharedServiceContainer.shared.vaultsManager(),
                           vaultSyncEventStream: SharedDataStreamContainer.shared.vaultSyncEventStream(),
                           credentialManager: SharedServiceContainer.shared.credentialManager(),
                           userManager: self.userManager,
                           featureFlagsRepository: SharedRepositoryContainer.shared.featureFlagsRepository(),
                           passMonitorRepository: SharedRepositoryContainer.shared.passMonitorRepository()) }
    }
}

// MARK: - Items

extension SharedUseCasesContainer {
    var pinItem: Factory<any PinItemUseCase> {
        self { PinItem(itemRepository: self.itemRepository,
                       logManager: self.logManager) }
    }

    var unpinItem: Factory<any UnpinItemUseCase> {
        self { UnpinItem(itemRepository: self.itemRepository,
                         logManager: self.logManager) }
    }

    var canEditItem: Factory<any CanEditItemUseCase> {
        self { CanEditItem() }
    }

    var getActiveLoginItems: Factory<any GetActiveLoginItemsUseCase> {
        self { GetActiveLoginItems(symmetricKeyProvider: SharedDataContainer.shared.symmetricKeyProvider(),
                                   repository: self.itemRepository) }
    }
}

// MARK: - Rust Validators

extension SharedUseCasesContainer {
    var validateAliasPrefix: Factory<any ValidateAliasPrefixUseCase> {
        self { ValidateAliasPrefix() }
    }

    var getRootDomain: Factory<any GetRootDomainUseCase> {
        // Register as `cached` because the list of root domain is long
        self { GetRootDomain() }
            .cached
    }

    var matchUrls: Factory<any MatchUrlsUseCase> {
        self { MatchUrls(getRootDomain: self.getRootDomain()) }
    }
}

// MARK: - Session

extension SharedUseCasesContainer {
    var forkSession: Factory<any ForkSessionUseCase> {
        self { ForkSession(networkRepository: SharedRepositoryContainer.shared.networkRepository()) }
    }
}

// MARK: - User

extension SharedUseCasesContainer {
    var refreshUserSettings: Factory<any RefreshUserSettingsUseCase> {
        self { RefreshUserSettings(userSettingsProtocol: self.userSettingsRepository)
        }
    }

    var toggleSentinel: Factory<any ToggleSentinelUseCase> {
        self { ToggleSentinel(userSettingsProtocol: self.userSettingsRepository,
                              userManager: self.userManager) }
    }

    var getSentinelStatus: Factory<any GetSentinelStatusUseCase> {
        self { GetSentinelStatus(userSettingsProtocol: self.userSettingsRepository,
                                 userManager: self.userManager) }
    }

    var getUserPlan: Factory<any GetUserPlanUseCase> {
        self { GetUserPlan(repository: SharedRepositoryContainer.shared.accessRepository()) }
    }
}

// MARK: Passkey

extension SharedUseCasesContainer {
    var passkeyManagerProvider: Factory<any PasskeyManagerProvider> {
        self { PasskeyManagerProviderImpl() }
    }

    var createPasskey: Factory<any CreatePasskeyUseCase> {
        self { CreatePasskey(managerProvider: self.passkeyManagerProvider()) }
    }

    var resolvePasskeyChallenge: Factory<any ResolvePasskeyChallengeUseCase> {
        self { ResolvePasskeyChallenge(managerProvider: self.passkeyManagerProvider()) }
    }
}

// MARK: Preferences

extension SharedUseCasesContainer {
    var getAppPreferences: Factory<any GetAppPreferencesUseCase> {
        self { GetAppPreferences(manager: self.preferencesManager) }
    }

    var getSharedPreferences: Factory<any GetSharedPreferencesUseCase> {
        self { GetSharedPreferences(manager: self.preferencesManager) }
    }

    var getUserPreferences: Factory<any GetUserPreferencesUseCase> {
        self { GetUserPreferences(manager: self.preferencesManager) }
    }

    var updateAppPreferences: Factory<any UpdateAppPreferencesUseCase> {
        self { UpdateAppPreferences(manager: self.preferencesManager) }
    }

    var updateSharedPreferences: Factory<any UpdateSharedPreferencesUseCase> {
        self { UpdateSharedPreferences(manager: self.preferencesManager) }
    }

    var updateUserPreferences: Factory<any UpdateUserPreferencesUseCase> {
        self { UpdateUserPreferences(manager: self.preferencesManager) }
    }
}

// MARK: Misc

extension SharedUseCasesContainer {
    var copyToClipboard: Factory<any CopyToClipboardUseCase> {
        self { CopyToClipboard(getSharedPreferences: self.getSharedPreferences()) }
    }

    var setUpEmailAndUsername: Factory<any SetUpEmailAndUsernameUseCase> {
        self { SetUpEmailAndUsername(featureFlags: self.getFeatureFlagStatus(),
                                     emailValidator: self.validateEmail()) }
    }

    var applyAppMigration: Factory<any ApplyAppMigrationUseCase> {
        self { ApplyAppMigration(dataMigrationManager: SharedServiceContainer.shared.dataMigrationManager(),
                                 userManager: self.userManager,
                                 appData: SharedDataContainer.shared.appData(),
                                 itemRepository: self.itemRepository,
                                 logManager: self.logManager) }
    }
}

// MARK: - Dark web monitor

extension SharedUseCasesContainer {
    var getCustomEmailSuggestion: Factory<any GetCustomEmailSuggestionUseCase> {
        self { GetCustomEmailSuggestion(itemRepository: self.itemRepository,
                                        symmetricKeyProvider: self.symmetricKeyProvider,
                                        validateEmailUseCase: self.validateEmail()) }
    }

    var validateEmail: Factory<any ValidateEmailUseCase> {
        self { ValidateEmail() }
    }

    var getAllAliases: Factory<any GetAllAliasesUseCase> {
        self { GetAllAliases(itemRepository: self.itemRepository) }
    }
}
