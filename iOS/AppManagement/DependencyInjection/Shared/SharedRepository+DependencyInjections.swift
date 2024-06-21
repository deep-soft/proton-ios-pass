//
// SharedRepository+DependencyInjections.swift
// Proton Pass - Created on 21/07/2023.
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
import CoreData
import CryptoKit
import Factory
import ProtonCoreFeatureFlags
import ProtonCoreLogin
@preconcurrency import ProtonCoreServices
import ProtonCoreUtilities

/// Contain all repositories
final class SharedRepositoryContainer: SharedContainer, AutoRegistering {
    static let shared = SharedRepositoryContainer()
    let manager = ContainerManager()

    private init() {}

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

// MARK: - Computed properties

private extension SharedRepositoryContainer {
    var apiManager: APIManager {
        SharedToolingContainer.shared.apiManager()
    }

    var apiService: any APIService {
        apiManager.apiService
    }

    var logManager: any LogManagerProtocol {
        SharedToolingContainer.shared.logManager()
    }

    var currentDateProvider: any CurrentDateProviderProtocol {
        SharedToolingContainer.shared.currentDateProvider()
    }

    var databaseService: any DatabaseServiceProtocol {
        SharedServiceContainer.shared.databaseService()
    }

    var userDataProvider: any UserDataProvider {
        SharedDataContainer.shared.userDataProvider()
    }

    var symmetricKeyProvider: any SymmetricKeyProvider {
        SharedDataContainer.shared.symmetricKeyProvider()
    }

    var userDataSymmetricKeyProvider: any UserDataSymmetricKeyProvider {
        SharedDataContainer.shared.appData()
    }

    var keychain: any KeychainProtocol {
        SharedToolingContainer.shared.keychain()
    }

    var corruptedSessionEventStream: CorruptedSessionEventStream {
        SharedDataStreamContainer.shared.corruptedSessionEventStream()
    }
}

// MARK: Private datasources

private extension SharedRepositoryContainer {
    var remoteAliasDatasource: Factory<any RemoteAliasDatasourceProtocol> {
        self { RemoteAliasDatasource(apiService: self.apiService,
                                     eventStream: self.corruptedSessionEventStream) }
    }

    var localShareKeyDatasource: Factory<any LocalShareKeyDatasourceProtocol> {
        self { LocalShareKeyDatasource(databaseService: self.databaseService) }
    }

    var remoteShareKeyDatasource: Factory<any RemoteShareKeyDatasourceProtocol> {
        self { RemoteShareKeyDatasource(apiService: self.apiService,
                                        eventStream: self.corruptedSessionEventStream) }
    }

    var localShareEventIDDatasource: Factory<any LocalShareEventIDDatasourceProtocol> {
        self { LocalShareEventIDDatasource(databaseService: self.databaseService) }
    }

    var remoteShareEventIDDatasource: Factory<any RemoteShareEventIDDatasourceProtocol> {
        self { RemoteShareEventIDDatasource(apiService: self.apiService,
                                            eventStream: self.corruptedSessionEventStream) }
    }

    var remoteItemKeyDatasource: Factory<any RemoteItemKeyDatasourceProtocol> {
        self { RemoteItemKeyDatasource(apiService: self.apiService,
                                       eventStream: self.corruptedSessionEventStream) }
    }

    var localItemDatasource: Factory<any LocalItemDatasourceProtocol> {
        self { LocalItemDatasource(databaseService: self.databaseService) }
    }

    var remoteItemDatasource: Factory<any RemoteItemDatasourceProtocol> {
        self { RemoteItemDatasource(apiService: self.apiService,
                                    eventStream: self.corruptedSessionEventStream) }
    }

    var localAccessDatasource: Factory<any LocalAccessDatasourceProtocol> {
        self { LocalAccessDatasource(databaseService: self.databaseService) }
    }

    var remoteAccessDatasource: Factory<any RemoteAccessDatasourceProtocol> {
        self { RemoteAccessDatasource(apiService: self.apiService,
                                      eventStream: self.corruptedSessionEventStream) }
    }

    var remoteAccountDatasource: Factory<any RemoteAccountDatasourceProtocol> {
        self { RemoteAccountDatasource(apiService: self.apiService,
                                       eventStream: self.corruptedSessionEventStream) }
    }

    var localShareDatasource: Factory<any LocalShareDatasourceProtocol> {
        self { LocalShareDatasource(databaseService: self.databaseService) }
    }

    var remoteShareDatasource: Factory<any RemoteShareDatasourceProtocol> {
        self { RemoteShareDatasource(apiService: self.apiService,
                                     eventStream: self.corruptedSessionEventStream) }
    }

    var localPublicKeyDatasource: Factory<any LocalPublicKeyDatasourceProtocol> {
        self { LocalPublicKeyDatasource(databaseService: self.databaseService) }
    }

    var remotePublicKeyDatasource: Factory<any RemotePublicKeyDatasourceProtocol> {
        self { RemotePublicKeyDatasource(apiService: self.apiService,
                                         eventStream: self.corruptedSessionEventStream) }
    }

    var remoteShareInviteDatasource: Factory<any RemoteShareInviteDatasourceProtocol> {
        self { RemoteShareInviteDatasource(apiService: self.apiService,
                                           eventStream: self.corruptedSessionEventStream) }
    }

    var localTelemetryEventDatasource: Factory<any LocalTelemetryEventDatasourceProtocol> {
        self { LocalTelemetryEventDatasource(databaseService: self.databaseService) }
    }

    var remoteTelemetryEventDatasource: Factory<any RemoteTelemetryEventDatasourceProtocol> {
        self { RemoteTelemetryEventDatasource(apiService: self.apiService,
                                              eventStream: self.corruptedSessionEventStream) }
    }

    var telemetryScheduler: Factory<any TelemetrySchedulerProtocol> {
        self { TelemetryScheduler(currentDateProvider: self.currentDateProvider,
                                  thresholdProvider: SharedToolingContainer.shared.preferencesManager()) }
    }

    var remoteFavIconDatasource: Factory<any RemoteFavIconDatasourceProtocol> {
        self { RemoteFavIconDatasource(apiService: self.apiService,
                                       eventStream: self.corruptedSessionEventStream) }
    }

    var localOrganizationDatasource: Factory<any LocalOrganizationDatasourceProtocol> {
        self { LocalOrganizationDatasource(databaseService: self.databaseService) }
    }

    var remoteOrganizationDatasource: Factory<any RemoteOrganizationDatasourceProtocol> {
        self { RemoteOrganizationDatasource(apiService: self.apiService,
                                            eventStream: self.corruptedSessionEventStream) }
    }

    var remoteBreachDataSource: Factory<any RemoteBreachDataSourceProtocol> {
        self { RemoteBreachDataSource(apiService: self.apiService,
                                      eventStream: self.corruptedSessionEventStream) }
    }

    var localItemReadEventDatasource: Factory<any LocalItemReadEventDatasourceProtocol> {
        self { LocalItemReadEventDatasource(databaseService: self.databaseService) }
    }

    var remoteItemReadEventDatasource: Factory<any RemoteItemReadEventDatasourceProtocol> {
        self { RemoteItemReadEventDatasource(apiService: self.apiService,
                                             eventStream: self.corruptedSessionEventStream) }
    }
}

// MARK: Public datasources

extension SharedRepositoryContainer {
    var localSpotlightVaultDatasource: Factory<any LocalSpotlightVaultDatasourceProtocol> {
        self { LocalSpotlightVaultDatasource(databaseService: self.databaseService) }
    }

    var appPreferencesDatasource: Factory<any LocalAppPreferencesDatasourceProtocol> {
        self { LocalAppPreferencesDatasource(userDefault: kSharedUserDefaults) }
    }

    var sharedPreferencesDatasource: Factory<any LocalSharedPreferencesDatasourceProtocol> {
        self { LocalSharedPreferencesDatasource(symmetricKeyProvider: self.symmetricKeyProvider,
                                                keychain: self.keychain) }
    }

    var userPreferencesDatasource: Factory<any LocalUserPreferencesDatasourceProtocol> {
        self { LocalUserPreferencesDatasource(symmetricKeyProvider: self.symmetricKeyProvider,
                                              databaseService: self.databaseService) }
    }

    var remoteSecureLinkDatasource: Factory<any RemoteSecureLinkDatasourceProtocol> {
        self { RemoteSecureLinkDatasource(apiService: self.apiService,
                                          eventStream: self.corruptedSessionEventStream) }
    }

    var localUserDataDatasource: Factory<any LocalUserDataDatasourceProtocol> {
        self { LocalUserDataDatasource(symmetricKeyProvider: self.symmetricKeyProvider,
                                       databaseService: self.databaseService) }
    }

    var localActiveUserIdDatasource: Factory<any LocalActiveUserIdDatasourceProtocol> {
        self { LocalActiveUserIdDatasource(userDefault: kSharedUserDefaults) }
    }
}

// MARK: Repositories

extension SharedRepositoryContainer {
    var remoteUserSettingsDatasource: Factory<any RemoteUserSettingsDatasourceProtocol> {
        self { RemoteUserSettingsDatasource(apiService: self.apiService,
                                            eventStream: self.corruptedSessionEventStream) }
    }

    var aliasRepository: Factory<any AliasRepositoryProtocol> {
        self { AliasRepository(remoteDatasouce: self.remoteAliasDatasource()) }
    }

    var shareKeyRepository: Factory<any ShareKeyRepositoryProtocol> {
        self {
            ShareKeyRepository(localDatasource: self.localShareKeyDatasource(),
                               remoteDatasource: self.remoteShareKeyDatasource(),
                               logManager: self.logManager,
                               symmetricKeyProvider: self.symmetricKeyProvider,
                               userDataProvider: self.userDataProvider)
        }
    }

    var shareEventIDRepository: Factory<any ShareEventIDRepositoryProtocol> {
        self {
            ShareEventIDRepository(localDatasource: self.localShareEventIDDatasource(),
                                   remoteDatasource: self.remoteShareEventIDDatasource(),
                                   logManager: self.logManager)
        }
    }

    var passKeyManager: Factory<any PassKeyManagerProtocol> {
        self {
            PassKeyManager(shareKeyRepository: self.shareKeyRepository(),
                           itemKeyDatasource: self.remoteItemKeyDatasource(),
                           logManager: self.logManager,
                           symmetricKeyProvider: self.symmetricKeyProvider)
        }
    }

    var itemRepository: Factory<any ItemRepositoryProtocol> {
        self {
            ItemRepository(symmetricKeyProvider: self.symmetricKeyProvider,
                           userDataProvider: self.userDataProvider,
                           localDatasource: self.localItemDatasource(),
                           remoteDatasource: self.remoteItemDatasource(),
                           shareEventIDRepository: self.shareEventIDRepository(),
                           passKeyManager: self.passKeyManager(),
                           logManager: self.logManager)
        }
    }

    var accessRepository: Factory<any AccessRepositoryProtocol> {
        self {
            AccessRepository(localDatasource: self.localAccessDatasource(),
                             remoteDatasource: self.remoteAccessDatasource(),
                             userDataProvider: self.userDataProvider,
                             logManager: self.logManager)
        }
    }

    var accountRepository: Factory<any AccountRepositoryProtocol> {
        self {
            AccountRepository(remoteAccountDatasource: self.remoteAccountDatasource())
        }
    }

    var shareRepository: Factory<any ShareRepositoryProtocol> {
        self { ShareRepository(symmetricKeyProvider: self.userDataSymmetricKeyProvider,
                               userDataProvider: self.userDataProvider,
                               localDatasource: self.localShareDatasource(),
                               remoteDatasouce: self.remoteShareDatasource(),
                               passKeyManager: self.passKeyManager(),
                               logManager: self.logManager,
                               eventStream: SharedDataStreamContainer.shared.vaultSyncEventStream()) }
    }

    var publicKeyRepository: Factory<any PublicKeyRepositoryProtocol> {
        self {
            PublicKeyRepository(localPublicKeyDatasource: self.localPublicKeyDatasource(),
                                remotePublicKeyDatasource: self.remotePublicKeyDatasource(),
                                logManager: self.logManager)
        }
    }

    var shareInviteRepository: Factory<any ShareInviteRepositoryProtocol> {
        self { ShareInviteRepository(remoteDataSource: self.remoteShareInviteDatasource(),
                                     logManager: self.logManager) }
    }

    var telemetryEventRepository: Factory<any TelemetryEventRepositoryProtocol> {
        self {
            TelemetryEventRepository(localDatasource: self.localTelemetryEventDatasource(),
                                     remoteDatasource: self.remoteTelemetryEventDatasource(),
                                     userSettingsRepository: self.userSettingsRepository(),
                                     accessRepository: self.accessRepository(),
                                     itemReadEventRepository: self.itemReadEventRepository(),
                                     logManager: self.logManager,
                                     scheduler: self.telemetryScheduler(),
                                     userDataProvider: self.userDataProvider)
        }
    }

    var featureFlagsRepository: Factory<any FeatureFlagsRepositoryProtocol> {
        self {
            FeatureFlagsRepository.shared.setApiService(self.apiService)
            return FeatureFlagsRepository.shared
        }
    }

    var favIconRepository: Factory<any FavIconRepositoryProtocol> {
        self { FavIconRepository(datasource: self.remoteFavIconDatasource(),
                                 containerUrl: URL.favIconsContainerURL(),
                                 symmetricKeyProvider: self.symmetricKeyProvider) }
    }

    var localSearchEntryDatasource: Factory<any LocalSearchEntryDatasourceProtocol> {
        self { LocalSearchEntryDatasource(databaseService: self.databaseService) }
    }

    var remoteSyncEventsDatasource: Factory<any RemoteSyncEventsDatasourceProtocol> {
        self { RemoteSyncEventsDatasource(apiService: self.apiService,
                                          eventStream: self.corruptedSessionEventStream) }
    }

    var userSettingsRepository: Factory<any UserSettingsRepositoryProtocol> {
        self { UserSettingsRepository(userDefaultService: SharedServiceContainer.shared.userDefaultService(),
                                      remoteDatasource: self.remoteUserSettingsDatasource()) }
    }

    var organizationRepository: Factory<any OrganizationRepositoryProtocol> {
        self { OrganizationRepository(localDatasource: self.localOrganizationDatasource(),
                                      remoteDatasource: self.remoteOrganizationDatasource(),
                                      userDataProvider: self.userDataProvider,
                                      logManager: self.logManager) }
    }

    var networkRepository: Factory<any NetworkRepositoryProtocol> {
        self { NetworkRepository(apiService: self.apiService) }
    }

    var itemReadEventRepository: Factory<any ItemReadEventRepositoryProtocol> {
        self { ItemReadEventRepository(localDatasource: self.localItemReadEventDatasource(),
                                       remoteDatasource: self.remoteItemReadEventDatasource(),
                                       currentDateProvider: self.currentDateProvider,
                                       userDataProvider: self.userDataProvider,
                                       logManager: self.logManager) }
    }
}

// MARK: - Security

extension SharedRepositoryContainer {
    var passMonitorRepository: Factory<any PassMonitorRepositoryProtocol> {
        self {
            PassMonitorRepository(itemRepository: self.itemRepository(),
                                  remoteDataSource: self.remoteBreachDataSource(),
                                  symmetricKeyProvider: self.symmetricKeyProvider)
        }
    }
}

extension SharedRepositoryContainer {
    var localDataMigrationDatasource: Factory<any LocalDataMigrationDatasourceProtocol> {
        self { LocalDataMigrationDatasource(databaseService: self.databaseService) }
    }
}
