//
// FetchCredentials.swift
// Proton Pass - Created on 28/02/2024.
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
import Core
import CryptoKit
import Entities
import Foundation
import UseCases

/// Fetch credentials from the database to display to users
protocol FetchCredentialsUseCase: Sendable {
    func execute(identifiers: [ASCredentialServiceIdentifier],
                 params: (any PasskeyRequestParametersProtocol)?) async throws -> CredentialsFetchResult
}

extension FetchCredentialsUseCase {
    func callAsFunction(identifiers: [ASCredentialServiceIdentifier],
                        params: (any PasskeyRequestParametersProtocol)?) async throws -> CredentialsFetchResult {
        try await execute(identifiers: identifiers, params: params)
    }
}

final class FetchCredentials: FetchCredentialsUseCase {
    private let symmetricKeyProvider: any SymmetricKeyProvider
    private let accessRepository: any AccessRepositoryProtocol
    private let itemRepository: any ItemRepositoryProtocol
    private let shareRepository: any ShareRepositoryProtocol
    private let matchUrls: any MatchUrlsUseCase
    private let mapServiceIdentifierToURL: any MapASCredentialServiceIdentifierToURLUseCase
    private let logger: Logger

    init(symmetricKeyProvider: any SymmetricKeyProvider,
         accessRepository: any AccessRepositoryProtocol,
         itemRepository: any ItemRepositoryProtocol,
         shareRepository: any ShareRepositoryProtocol,
         matchUrls: any MatchUrlsUseCase,
         mapServiceIdentifierToURL: any MapASCredentialServiceIdentifierToURLUseCase,
         logManager: any LogManagerProtocol) {
        self.symmetricKeyProvider = symmetricKeyProvider
        self.accessRepository = accessRepository
        self.itemRepository = itemRepository
        self.shareRepository = shareRepository
        self.matchUrls = matchUrls
        self.mapServiceIdentifierToURL = mapServiceIdentifierToURL
        logger = .init(manager: logManager)
    }

    func execute(identifiers: [ASCredentialServiceIdentifier],
                 params: (any PasskeyRequestParametersProtocol)?) async throws -> CredentialsFetchResult {
        async let symmetricKey = symmetricKeyProvider.getSymmetricKey()
        async let plan = accessRepository.getPlan()
        async let vaults = shareRepository.getVaults()
        async let encryptedItems = itemRepository.getActiveLogInItems()
        try await logger.debug("Mapping \(encryptedItems.count) encrypted items")

        if let params {
            return try await fetchPasskeys(params: params,
                                           symmetricKey: symmetricKey,
                                           vaults: vaults,
                                           encryptedItems: encryptedItems,
                                           plan: plan)
        }
        return try await fetchPasswords(identifiers: identifiers,
                                        symmetricKey: symmetricKey,
                                        vaults: vaults,
                                        encryptedItems: encryptedItems,
                                        plan: plan)
    }
}

private extension FetchCredentials {
    /// When in free plan, only take 2 oldest vaults into account (suggestions & search)
    /// Otherwise take everything into account
    func shouldTakeIntoAccount(_ vault: Vault, allVaults: [Vault], withPlan plan: Plan) -> Bool {
        switch plan.planType {
        case .free:
            let oldestVaults = allVaults.twoOldestVaults
            return oldestVaults.isOneOf(shareId: vault.shareId)
        default:
            return true
        }
    }
}

private extension FetchCredentials {
    func fetchPasswords(identifiers: [ASCredentialServiceIdentifier],
                        symmetricKey: SymmetricKey,
                        vaults: [Vault],
                        encryptedItems: [SymmetricallyEncryptedItem],
                        plan: Plan) async throws -> CredentialsFetchResult {
        let urls = identifiers.compactMap(mapServiceIdentifierToURL.callAsFunction)
        var searchableItems = [SearchableItem]()
        var matchedEncryptedItems = [ScoredSymmetricallyEncryptedItem]()
        var notMatchedEncryptedItems = [SymmetricallyEncryptedItem]()

        for encryptedItem in encryptedItems {
            let decryptedItem = try encryptedItem.getItemContent(symmetricKey: symmetricKey)
            guard let vault = vaults.first(where: { $0.shareId == decryptedItem.shareId }),
                  shouldTakeIntoAccount(vault, allVaults: vaults, withPlan: plan),
                  let data = decryptedItem.loginItem else {
                continue
            }

            searchableItems.append(SearchableItem(from: decryptedItem, allVaults: vaults))

            let itemUrls = data.urls.compactMap { URL(string: $0) }
            var matchResults = [UrlMatchResult]()
            for itemUrl in itemUrls {
                for url in urls {
                    let result = try matchUrls(itemUrl, with: url)
                    if case .matched = result {
                        matchResults.append(result)
                    }
                }
            }

            if matchResults.isEmpty {
                notMatchedEncryptedItems.append(encryptedItem)
            } else {
                let totalScore = matchResults.reduce(into: 0) { partialResult, next in
                    partialResult += next.score
                }
                matchedEncryptedItems.append(.init(item: encryptedItem,
                                                   matchScore: totalScore))
            }
        }

        let matchedItems = try await matchedEncryptedItems.sorted()
            .parallelMap { try $0.item.toItemUiModel(symmetricKey) }
        let notMatchedItems = try await notMatchedEncryptedItems.sorted()
            .parallelMap { try $0.toItemUiModel(symmetricKey) }

        logger.debug("Mapped \(encryptedItems.count) encrypted items for password autofill.")
        logger.debug("\(vaults.count) vaults, \(searchableItems.count) searchable items")
        logger.debug("\(matchedItems.count) matched items, \(notMatchedItems.count) not matched items")
        return CredentialsFetchResult(searchableItems: searchableItems,
                                      matchedItems: matchedItems,
                                      notMatchedItems: notMatchedItems)
    }
}

private extension FetchCredentials {
    func fetchPasskeys(params: any PasskeyRequestParametersProtocol,
                       symmetricKey: SymmetricKey,
                       vaults: [Vault],
                       encryptedItems: [SymmetricallyEncryptedItem],
                       plan: Plan) async throws -> CredentialsFetchResult {
        var searchableItems = [SearchableItem]()
        var matchedEncryptedItems = [SymmetricallyEncryptedItem]()
        var notMatchedEncryptedItems = [SymmetricallyEncryptedItem]()

        for encryptedItem in encryptedItems {
            let decryptedItem = try encryptedItem.getItemContent(symmetricKey: symmetricKey)
            guard let vault = vaults.first(where: { $0.shareId == decryptedItem.shareId }),
                  shouldTakeIntoAccount(vault, allVaults: vaults, withPlan: plan),
                  let data = decryptedItem.loginItem,
                  !data.passkeys.isEmpty else {
                continue
            }

            searchableItems.append(SearchableItem(from: decryptedItem, allVaults: vaults))

            if data.passkeys.map(\.rpID).contains(params.relyingPartyIdentifier) {
                matchedEncryptedItems.append(encryptedItem)
            } else {
                notMatchedEncryptedItems.append(encryptedItem)
            }
        }

        let matchedItems = try await matchedEncryptedItems.sorted()
            .parallelMap { try $0.toItemUiModel(symmetricKey) }
        let notMatchedItems = try await notMatchedEncryptedItems.sorted()
            .parallelMap { try $0.toItemUiModel(symmetricKey) }

        logger.debug("Mapped \(encryptedItems.count) encrypted items for passkey autofill.")
        logger.debug("\(vaults.count) vaults, \(searchableItems.count) searchable items")
        logger.debug("\(matchedItems.count) matched items, \(notMatchedItems.count) not matched items")
        return CredentialsFetchResult(searchableItems: searchableItems,
                                      matchedItems: matchedItems,
                                      notMatchedItems: notMatchedItems)
    }
}
