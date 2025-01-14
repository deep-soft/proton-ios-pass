//
// CompleteAutoFill.swift
// Proton Pass - Created on 31/07/2023.
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

import AuthenticationServices
import Client
import Core

// swiftlint:disable function_parameter_count
protocol CompleteAutoFillUseCase: Sendable {
    func execute(quickTypeBar: Bool,
                 credential: ASPasswordCredential,
                 itemContent: ItemContent,
                 itemRepository: ItemRepositoryProtocol,
                 upgradeChecker: UpgradeCheckerProtocol,
                 serviceIdentifiers: [ASCredentialServiceIdentifier],
                 telemetryEventRepository: TelemetryEventRepositoryProtocol?)
}

extension CompleteAutoFillUseCase {
    func callAsFunction(quickTypeBar: Bool,
                        credential: ASPasswordCredential,
                        itemContent: ItemContent,
                        itemRepository: ItemRepositoryProtocol,
                        upgradeChecker: UpgradeCheckerProtocol,
                        serviceIdentifiers: [ASCredentialServiceIdentifier],
                        telemetryEventRepository: TelemetryEventRepositoryProtocol?) {
        execute(quickTypeBar: quickTypeBar,
                credential: credential,
                itemContent: itemContent,
                itemRepository: itemRepository,
                upgradeChecker: upgradeChecker,
                serviceIdentifiers: serviceIdentifiers,
                telemetryEventRepository: telemetryEventRepository)
    }
}

final class CompleteAutoFill: @unchecked Sendable, CompleteAutoFillUseCase {
    private let context: ASCredentialProviderExtensionContext
    private let logger: Logger
    private let logManager: LogManagerProtocol
    private let clipboardManager: ClipboardManager
    private let copyTotpTokenAndNotify: CopyTotpTokenAndNotifyUseCase
    private let indexAllLoginItems: IndexAllLoginItemsUseCase
    private let resetFactory: ResetFactoryUseCase

    init(context: ASCredentialProviderExtensionContext,
         logManager: LogManagerProtocol,
         clipboardManager: ClipboardManager,
         copyTotpTokenAndNotify: CopyTotpTokenAndNotifyUseCase,
         indexAllLoginItems: IndexAllLoginItemsUseCase,
         resetFactory: ResetFactoryUseCase = ResetFactory()) {
        self.context = context
        logger = .init(manager: logManager)
        self.logManager = logManager
        self.clipboardManager = clipboardManager
        self.copyTotpTokenAndNotify = copyTotpTokenAndNotify
        self.indexAllLoginItems = indexAllLoginItems
        self.resetFactory = resetFactory
    }

    /*
     Complete the autofill process by updating item's `lastUseTime` and reindex all login items
     While these processes can eventually fails, we don't really do anything when errors happen but only log them.
     Because they all happen in the completion block of the `completeRequest` of `ASCredentialProviderExtensionContext`
     and at this moment the autofill process is done and the extension is already closed, we have no way to tell users about the errors anyway
     */
    func execute(quickTypeBar: Bool,
                 credential: ASPasswordCredential,
                 itemContent: ItemContent,
                 itemRepository: ItemRepositoryProtocol,
                 upgradeChecker: UpgradeCheckerProtocol,
                 serviceIdentifiers: [ASCredentialServiceIdentifier],
                 telemetryEventRepository: TelemetryEventRepositoryProtocol?) {
        context.completeRequest(withSelectedCredential: credential) { _ in
            Task(priority: .high) { [weak self] in
                guard let self else { return }
                defer {
                    resetFactory()
                }
                do {
                    if quickTypeBar {
                        try await telemetryEventRepository?.addNewEvent(type: .autofillTriggeredFromSource)
                    } else {
                        try await telemetryEventRepository?.addNewEvent(type: .autofillTriggeredFromApp)
                    }
                    logger.info("Autofilled from QuickType bar \(quickTypeBar) \(itemContent.debugInformation)")
                    try await complete(itemContent: itemContent,
                                       itemRepository: itemRepository,
                                       upgradeChecker: upgradeChecker,
                                       serviceIdentifiers: serviceIdentifiers)
                    await logManager.saveAllLogs()
                } catch {
                    // Do nothing but only log the errors
                    logger.error(error)
                    // Repeat the "saveAllLogs" function instead of deferring
                    // because we can't "await" in defer block
                    await logManager.saveAllLogs()
                }
            }
        }
    }
}

private extension CompleteAutoFill {
    func complete(itemContent: ItemContent,
                  itemRepository: ItemRepositoryProtocol,
                  upgradeChecker: UpgradeCheckerProtocol,
                  serviceIdentifiers: [ASCredentialServiceIdentifier]) async throws {
        try await copyTotpTokenAndNotify(itemContent: itemContent,
                                         clipboardManager: clipboardManager,
                                         upgradeChecker: upgradeChecker)
        logger.trace("Updating lastUseTime \(itemContent.debugInformation)")
        try await itemRepository.update(item: itemContent,
                                        lastUseTime: Date().timeIntervalSince1970)
        logger.info("Updated lastUseTime \(itemContent.debugInformation)")

        try await indexAllLoginItems(ignorePreferences: false)
    }
}

// swiftlint:enable function_parameter_count
