// Generated using Sourcery 2.2.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// Proton Pass.
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
import Combine
import CryptoKit
import Entities
import Foundation
import PassRustCore

public final class PassMonitorRepositoryProtocolMock: @unchecked Sendable, PassMonitorRepositoryProtocol {

    public init() {}

    // MARK: - state
    public var invokedStateSetter = false
    public var invokedStateSetterCount = 0
    public var invokedState: CurrentValueSubject<MonitorState, Never>?
    public var invokedStateList = [CurrentValueSubject<MonitorState, Never>?]()
    public var invokedStateGetter = false
    public var invokedStateGetterCount = 0
    public var stubbedState: CurrentValueSubject<MonitorState, Never>!
    public var state: CurrentValueSubject<MonitorState, Never> {
        set {
            invokedStateSetter = true
            invokedStateSetterCount += 1
            invokedState = newValue
            invokedStateList.append(newValue)
        } get {
            invokedStateGetter = true
            invokedStateGetterCount += 1
            return stubbedState
        }
    }
    // MARK: - weaknessStats
    public var invokedWeaknessStatsSetter = false
    public var invokedWeaknessStatsSetterCount = 0
    public var invokedWeaknessStats: CurrentValueSubject<WeaknessStats, Never>?
    public var invokedWeaknessStatsList = [CurrentValueSubject<WeaknessStats, Never>?]()
    public var invokedWeaknessStatsGetter = false
    public var invokedWeaknessStatsGetterCount = 0
    public var stubbedWeaknessStats: CurrentValueSubject<WeaknessStats, Never>!
    public var weaknessStats: CurrentValueSubject<WeaknessStats, Never> {
        set {
            invokedWeaknessStatsSetter = true
            invokedWeaknessStatsSetterCount += 1
            invokedWeaknessStats = newValue
            invokedWeaknessStatsList.append(newValue)
        } get {
            invokedWeaknessStatsGetter = true
            invokedWeaknessStatsGetterCount += 1
            return stubbedWeaknessStats
        }
    }
    // MARK: - itemsWithSecurityIssues
    public var invokedItemsWithSecurityIssuesSetter = false
    public var invokedItemsWithSecurityIssuesSetterCount = 0
    public var invokedItemsWithSecurityIssues: CurrentValueSubject<[SecurityAffectedItem], Never>?
    public var invokedItemsWithSecurityIssuesList = [CurrentValueSubject<[SecurityAffectedItem], Never>?]()
    public var invokedItemsWithSecurityIssuesGetter = false
    public var invokedItemsWithSecurityIssuesGetterCount = 0
    public var stubbedItemsWithSecurityIssues: CurrentValueSubject<[SecurityAffectedItem], Never>!
    public var itemsWithSecurityIssues: CurrentValueSubject<[SecurityAffectedItem], Never> {
        set {
            invokedItemsWithSecurityIssuesSetter = true
            invokedItemsWithSecurityIssuesSetterCount += 1
            invokedItemsWithSecurityIssues = newValue
            invokedItemsWithSecurityIssuesList.append(newValue)
        } get {
            invokedItemsWithSecurityIssuesGetter = true
            invokedItemsWithSecurityIssuesGetterCount += 1
            return stubbedItemsWithSecurityIssues
        }
    }
    // MARK: - refreshSecurityChecks
    public var refreshSecurityChecksThrowableError1: Error?
    public var closureRefreshSecurityChecks: () -> () = {}
    public var invokedRefreshSecurityChecksfunction = false
    public var invokedRefreshSecurityChecksCount = 0

    public func refreshSecurityChecks() async throws {
        invokedRefreshSecurityChecksfunction = true
        invokedRefreshSecurityChecksCount += 1
        if let error = refreshSecurityChecksThrowableError1 {
            throw error
        }
        closureRefreshSecurityChecks()
    }
    // MARK: - getItemsWithSamePassword
    public var getItemsWithSamePasswordItemThrowableError2: Error?
    public var closureGetItemsWithSamePassword: () -> () = {}
    public var invokedGetItemsWithSamePasswordfunction = false
    public var invokedGetItemsWithSamePasswordCount = 0
    public var invokedGetItemsWithSamePasswordParameters: (item: ItemContent, Void)?
    public var invokedGetItemsWithSamePasswordParametersList = [(item: ItemContent, Void)]()
    public var stubbedGetItemsWithSamePasswordResult: [ItemContent]!

    public func getItemsWithSamePassword(item: ItemContent) async throws -> [ItemContent] {
        invokedGetItemsWithSamePasswordfunction = true
        invokedGetItemsWithSamePasswordCount += 1
        invokedGetItemsWithSamePasswordParameters = (item, ())
        invokedGetItemsWithSamePasswordParametersList.append((item, ()))
        if let error = getItemsWithSamePasswordItemThrowableError2 {
            throw error
        }
        closureGetItemsWithSamePassword()
        return stubbedGetItemsWithSamePasswordResult
    }
    // MARK: - getAllBreachesForUser
    public var getAllBreachesForUserThrowableError3: Error?
    public var closureGetAllBreachesForUser: () -> () = {}
    public var invokedGetAllBreachesForUserfunction = false
    public var invokedGetAllBreachesForUserCount = 0
    public var stubbedGetAllBreachesForUserResult: UserBreaches!

    public func getAllBreachesForUser() async throws -> UserBreaches {
        invokedGetAllBreachesForUserfunction = true
        invokedGetAllBreachesForUserCount += 1
        if let error = getAllBreachesForUserThrowableError3 {
            throw error
        }
        closureGetAllBreachesForUser()
        return stubbedGetAllBreachesForUserResult
    }
    // MARK: - getAllCustomEmailForUser
    public var getAllCustomEmailForUserThrowableError4: Error?
    public var closureGetAllCustomEmailForUser: () -> () = {}
    public var invokedGetAllCustomEmailForUserfunction = false
    public var invokedGetAllCustomEmailForUserCount = 0
    public var stubbedGetAllCustomEmailForUserResult: [CustomEmail]!

    public func getAllCustomEmailForUser() async throws -> [CustomEmail] {
        invokedGetAllCustomEmailForUserfunction = true
        invokedGetAllCustomEmailForUserCount += 1
        if let error = getAllCustomEmailForUserThrowableError4 {
            throw error
        }
        closureGetAllCustomEmailForUser()
        return stubbedGetAllCustomEmailForUserResult
    }
    // MARK: - addEmailToBreachMonitoring
    public var addEmailToBreachMonitoringEmailThrowableError5: Error?
    public var closureAddEmailToBreachMonitoring: () -> () = {}
    public var invokedAddEmailToBreachMonitoringfunction = false
    public var invokedAddEmailToBreachMonitoringCount = 0
    public var invokedAddEmailToBreachMonitoringParameters: (email: String, Void)?
    public var invokedAddEmailToBreachMonitoringParametersList = [(email: String, Void)]()
    public var stubbedAddEmailToBreachMonitoringResult: CustomEmail!

    public func addEmailToBreachMonitoring(email: String) async throws -> CustomEmail {
        invokedAddEmailToBreachMonitoringfunction = true
        invokedAddEmailToBreachMonitoringCount += 1
        invokedAddEmailToBreachMonitoringParameters = (email, ())
        invokedAddEmailToBreachMonitoringParametersList.append((email, ()))
        if let error = addEmailToBreachMonitoringEmailThrowableError5 {
            throw error
        }
        closureAddEmailToBreachMonitoring()
        return stubbedAddEmailToBreachMonitoringResult
    }
    // MARK: - verifyCustomEmail
    public var verifyCustomEmailEmailCodeThrowableError6: Error?
    public var closureVerifyCustomEmail: () -> () = {}
    public var invokedVerifyCustomEmailfunction = false
    public var invokedVerifyCustomEmailCount = 0
    public var invokedVerifyCustomEmailParameters: (email: CustomEmail, code: String)?
    public var invokedVerifyCustomEmailParametersList = [(email: CustomEmail, code: String)]()

    public func verifyCustomEmail(email: CustomEmail, code: String) async throws {
        invokedVerifyCustomEmailfunction = true
        invokedVerifyCustomEmailCount += 1
        invokedVerifyCustomEmailParameters = (email, code)
        invokedVerifyCustomEmailParametersList.append((email, code))
        if let error = verifyCustomEmailEmailCodeThrowableError6 {
            throw error
        }
        closureVerifyCustomEmail()
    }
    // MARK: - removeEmailFromBreachMonitoring
    public var removeEmailFromBreachMonitoringEmailThrowableError7: Error?
    public var closureRemoveEmailFromBreachMonitoring: () -> () = {}
    public var invokedRemoveEmailFromBreachMonitoringfunction = false
    public var invokedRemoveEmailFromBreachMonitoringCount = 0
    public var invokedRemoveEmailFromBreachMonitoringParameters: (email: CustomEmail, Void)?
    public var invokedRemoveEmailFromBreachMonitoringParametersList = [(email: CustomEmail, Void)]()

    public func removeEmailFromBreachMonitoring(email: CustomEmail) async throws {
        invokedRemoveEmailFromBreachMonitoringfunction = true
        invokedRemoveEmailFromBreachMonitoringCount += 1
        invokedRemoveEmailFromBreachMonitoringParameters = (email, ())
        invokedRemoveEmailFromBreachMonitoringParametersList.append((email, ()))
        if let error = removeEmailFromBreachMonitoringEmailThrowableError7 {
            throw error
        }
        closureRemoveEmailFromBreachMonitoring()
    }
    // MARK: - resendEmailVerification
    public var resendEmailVerificationEmailIdThrowableError8: Error?
    public var closureResendEmailVerification: () -> () = {}
    public var invokedResendEmailVerificationfunction = false
    public var invokedResendEmailVerificationCount = 0
    public var invokedResendEmailVerificationParameters: (emailId: String, Void)?
    public var invokedResendEmailVerificationParametersList = [(emailId: String, Void)]()

    public func resendEmailVerification(emailId: String) async throws {
        invokedResendEmailVerificationfunction = true
        invokedResendEmailVerificationCount += 1
        invokedResendEmailVerificationParameters = (emailId, ())
        invokedResendEmailVerificationParametersList.append((emailId, ()))
        if let error = resendEmailVerificationEmailIdThrowableError8 {
            throw error
        }
        closureResendEmailVerification()
    }
    // MARK: - getBreachesForAlias
    public var getBreachesForAliasSharedIdItemIdThrowableError9: Error?
    public var closureGetBreachesForAlias: () -> () = {}
    public var invokedGetBreachesForAliasfunction = false
    public var invokedGetBreachesForAliasCount = 0
    public var invokedGetBreachesForAliasParameters: (sharedId: String, itemId: String)?
    public var invokedGetBreachesForAliasParametersList = [(sharedId: String, itemId: String)]()
    public var stubbedGetBreachesForAliasResult: EmailBreaches!

    public func getBreachesForAlias(sharedId: String, itemId: String) async throws -> EmailBreaches {
        invokedGetBreachesForAliasfunction = true
        invokedGetBreachesForAliasCount += 1
        invokedGetBreachesForAliasParameters = (sharedId, itemId)
        invokedGetBreachesForAliasParametersList.append((sharedId, itemId))
        if let error = getBreachesForAliasSharedIdItemIdThrowableError9 {
            throw error
        }
        closureGetBreachesForAlias()
        return stubbedGetBreachesForAliasResult
    }
    // MARK: - updateState
    public var closureUpdateState: () -> () = {}
    public var invokedUpdateStatefunction = false
    public var invokedUpdateStateCount = 0
    public var invokedUpdateStateParameters: (newValue: MonitorState, Void)?
    public var invokedUpdateStateParametersList = [(newValue: MonitorState, Void)]()

    public func updateState(_ newValue: MonitorState) async {
        invokedUpdateStatefunction = true
        invokedUpdateStateCount += 1
        invokedUpdateStateParameters = (newValue, ())
        invokedUpdateStateParametersList.append((newValue, ()))
        closureUpdateState()
    }
}
