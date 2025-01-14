// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
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
// swiftlint:disable all

@testable import Client
import Core
import Entities
import Foundation
import ProtonCoreLogin

final class ShareInviteRepositoryProtocolMock: @unchecked Sendable, ShareInviteRepositoryProtocol {
    // MARK: - getAllPendingInvites
    var getAllPendingInvitesShareIdThrowableError: Error?
    var closureGetAllPendingInvites: () -> () = {}
    var invokedGetAllPendingInvites = false
    var invokedGetAllPendingInvitesCount = 0
    var invokedGetAllPendingInvitesParameters: (shareId: String, Void)?
    var invokedGetAllPendingInvitesParametersList = [(shareId: String, Void)]()
    var stubbedGetAllPendingInvitesResult: ShareInvites!

    func getAllPendingInvites(shareId: String) async throws -> ShareInvites {
        invokedGetAllPendingInvites = true
        invokedGetAllPendingInvitesCount += 1
        invokedGetAllPendingInvitesParameters = (shareId, ())
        invokedGetAllPendingInvitesParametersList.append((shareId, ()))
        if let error = getAllPendingInvitesShareIdThrowableError {
            throw error
        }
        closureGetAllPendingInvites()
        return stubbedGetAllPendingInvitesResult
    }
    // MARK: - sendInvite
    var sendInviteShareIdInviteeDataTargetTypeShareRoleThrowableError: Error?
    var closureSendInvite: () -> () = {}
    var invokedSendInvite = false
    var invokedSendInviteCount = 0
    var invokedSendInviteParameters: (shareId: String, inviteeData: InviteeData, targetType: TargetType, shareRole: ShareRole)?
    var invokedSendInviteParametersList = [(shareId: String, inviteeData: InviteeData, targetType: TargetType, shareRole: ShareRole)]()
    var stubbedSendInviteResult: Bool!

    func sendInvite(shareId: String, inviteeData: InviteeData, targetType: TargetType, shareRole: ShareRole) async throws -> Bool {
        invokedSendInvite = true
        invokedSendInviteCount += 1
        invokedSendInviteParameters = (shareId, inviteeData, targetType, shareRole)
        invokedSendInviteParametersList.append((shareId, inviteeData, targetType, shareRole))
        if let error = sendInviteShareIdInviteeDataTargetTypeShareRoleThrowableError {
            throw error
        }
        closureSendInvite()
        return stubbedSendInviteResult
    }
    // MARK: - promoteNewUserInvite
    var promoteNewUserInviteShareIdInviteIdKeysThrowableError: Error?
    var closurePromoteNewUserInvite: () -> () = {}
    var invokedPromoteNewUserInvite = false
    var invokedPromoteNewUserInviteCount = 0
    var invokedPromoteNewUserInviteParameters: (shareId: String, inviteId: String, keys: [ItemKey])?
    var invokedPromoteNewUserInviteParametersList = [(shareId: String, inviteId: String, keys: [ItemKey])]()
    var stubbedPromoteNewUserInviteResult: Bool!

    func promoteNewUserInvite(shareId: String, inviteId: String, keys: [ItemKey]) async throws -> Bool {
        invokedPromoteNewUserInvite = true
        invokedPromoteNewUserInviteCount += 1
        invokedPromoteNewUserInviteParameters = (shareId, inviteId, keys)
        invokedPromoteNewUserInviteParametersList.append((shareId, inviteId, keys))
        if let error = promoteNewUserInviteShareIdInviteIdKeysThrowableError {
            throw error
        }
        closurePromoteNewUserInvite()
        return stubbedPromoteNewUserInviteResult
    }
    // MARK: - sendInviteReminder
    var sendInviteReminderShareIdInviteIdThrowableError: Error?
    var closureSendInviteReminder: () -> () = {}
    var invokedSendInviteReminder = false
    var invokedSendInviteReminderCount = 0
    var invokedSendInviteReminderParameters: (shareId: String, inviteId: String)?
    var invokedSendInviteReminderParametersList = [(shareId: String, inviteId: String)]()
    var stubbedSendInviteReminderResult: Bool!

    func sendInviteReminder(shareId: String, inviteId: String) async throws -> Bool {
        invokedSendInviteReminder = true
        invokedSendInviteReminderCount += 1
        invokedSendInviteReminderParameters = (shareId, inviteId)
        invokedSendInviteReminderParametersList.append((shareId, inviteId))
        if let error = sendInviteReminderShareIdInviteIdThrowableError {
            throw error
        }
        closureSendInviteReminder()
        return stubbedSendInviteReminderResult
    }
    // MARK: - deleteInvite
    var deleteInviteShareIdInviteIdThrowableError: Error?
    var closureDeleteInvite: () -> () = {}
    var invokedDeleteInvite = false
    var invokedDeleteInviteCount = 0
    var invokedDeleteInviteParameters: (shareId: String, inviteId: String)?
    var invokedDeleteInviteParametersList = [(shareId: String, inviteId: String)]()
    var stubbedDeleteInviteResult: Bool!

    func deleteInvite(shareId: String, inviteId: String) async throws -> Bool {
        invokedDeleteInvite = true
        invokedDeleteInviteCount += 1
        invokedDeleteInviteParameters = (shareId, inviteId)
        invokedDeleteInviteParametersList.append((shareId, inviteId))
        if let error = deleteInviteShareIdInviteIdThrowableError {
            throw error
        }
        closureDeleteInvite()
        return stubbedDeleteInviteResult
    }
    // MARK: - deleteNewUserInvite
    var deleteNewUserInviteShareIdInviteIdThrowableError: Error?
    var closureDeleteNewUserInvite: () -> () = {}
    var invokedDeleteNewUserInvite = false
    var invokedDeleteNewUserInviteCount = 0
    var invokedDeleteNewUserInviteParameters: (shareId: String, inviteId: String)?
    var invokedDeleteNewUserInviteParametersList = [(shareId: String, inviteId: String)]()
    var stubbedDeleteNewUserInviteResult: Bool!

    func deleteNewUserInvite(shareId: String, inviteId: String) async throws -> Bool {
        invokedDeleteNewUserInvite = true
        invokedDeleteNewUserInviteCount += 1
        invokedDeleteNewUserInviteParameters = (shareId, inviteId)
        invokedDeleteNewUserInviteParametersList.append((shareId, inviteId))
        if let error = deleteNewUserInviteShareIdInviteIdThrowableError {
            throw error
        }
        closureDeleteNewUserInvite()
        return stubbedDeleteNewUserInviteResult
    }
}
