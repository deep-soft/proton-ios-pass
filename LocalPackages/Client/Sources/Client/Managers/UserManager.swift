//
// UserManager.swift
// Proton Pass - Created on 14/05/2024.
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
//

// Remove later
// periphery:ignore:all
@preconcurrency import Combine
import Core
import Entities
import Foundation
import ProtonCoreLogin

// sourcery:AutoMockable
public protocol UserManagerProtocol: Sendable {
    var currentActiveUser: CurrentValueSubject<UserData?, Never> { get }
    var allUserAccounts: CurrentValueSubject<[UserData], Never> { get }

    func setUp() async throws
    func getActiveUserData() async throws -> UserData?
    func addAndMarkAsActive(userData: UserData) async throws
    func update(userData: UserData) async throws
    func switchActiveUser(with userId: String) async throws
    func getAllUsers() async throws -> [UserData]
    func remove(userId: String) async throws
    func getActiveUserId() async throws -> String
    func cleanAllUsers() async throws
    nonisolated func setUserData(_ userData: UserData)
}

public extension UserManagerProtocol {
    var activeUserId: String? {
        currentActiveUser.value?.user.ID
    }

    func getUnwrappedActiveUserData() async throws -> UserData {
        guard let userData = try await getActiveUserData() else {
            throw PassError.userManager(.activeUserDataNotFound)
        }
        return userData
    }
}

public actor UserManager: UserManagerProtocol {
    public let currentActiveUser = CurrentValueSubject<UserData?, Never>(nil)
    public let allUserAccounts: CurrentValueSubject<[UserData], Never> = .init([])

    private var userProfiles = [UserProfile]()
    private let userDataDatasource: any LocalUserDataDatasourceProtocol
    private let logger: Logger
    private var didSetUp = false

    public init(userDataDatasource: any LocalUserDataDatasourceProtocol,
                logManager: any LogManagerProtocol) {
        self.userDataDatasource = userDataDatasource
        logger = .init(manager: logManager)
    }
}

public extension UserManager {
    func setUp() async throws {
        userProfiles = try await userDataDatasource.getAll()
        allUserAccounts.send(userProfiles.userDatas)
        await publishNewActiveUser(userProfiles.activeUser?.userdata)
        didSetUp = true
    }

    func getActiveUserData() async throws -> UserData? {
        await assertDidSetUp()

        if userProfiles.isEmpty {
            return nil
        }

        guard let activeUserData = userProfiles.activeUser?.userdata else {
            throw PassError.userManager(.userDatasAvailableButNoActiveUserId)
        }
        if currentActiveUser.value?.user.ID != activeUserData.user.ID {
            await publishNewActiveUser(activeUserData)
        }
        return activeUserData
    }

    func getAllUsers() async -> [UserData] {
        await assertDidSetUp()

        return userProfiles.userDatas
    }

    func getActiveUserId() async throws -> String {
        await assertDidSetUp()
        guard let id = try await getActiveUserData()?.user.ID else {
            throw PassError.userManager(.activeUserDataNotFound)
        }
        return id
    }

    func addAndMarkAsActive(userData: UserData) async throws {
        await assertDidSetUp()

        try await userDataDatasource.upsert(userData)
        try await switchActiveUser(with: userData.user.ID)
    }

    func update(userData: UserData) async throws {
        try await userDataDatasource.upsert(userData)
        try await updateCachedUserAccounts()

        if let activeUserId,
           activeUserId == userData.user.ID {
            await publishNewActiveUser(userData)
        }
    }

    /// Remove user profile from database and memory. If the user being removed if the current active user it sets
    /// a new active user
    /// - Parameter userId: The id of the user to remove
    func remove(userId: String) async throws {
        await assertDidSetUp()

        try await userDataDatasource.remove(userId: userId)

        try await updateCachedUserAccounts()

        if userProfiles.activeUser == nil, let newActiveUser = userProfiles.first {
            try await switchActiveUser(with: newActiveUser.userdata.user.ID)
        }
    }

    func switchActiveUser(with newActiveUserId: String) async throws {
        await assertDidSetUp()

        try await userDataDatasource.updateNewActiveUser(userId: newActiveUserId)

        try await updateCachedUserAccounts()

        guard let activeUserData = userProfiles.activeUser?.userdata else {
            throw PassError.userManager(.activeUserDataNotFound)
        }
        await publishNewActiveUser(activeUserData)
    }

    func cleanAllUsers() async throws {
        try await userDataDatasource.removeAll()
        currentActiveUser.send(nil)
        allUserAccounts.send([])
        userProfiles = []
    }
}

// MARK: - Utils

private extension UserManager {
    func updateCachedUserAccounts() async throws {
        userProfiles = try await userDataDatasource.getAll()
        allUserAccounts.send(userProfiles.userDatas)
    }

    /// Make sure to publish on main actor because other main actors listen to these changes and update the UI
    @MainActor
    func publishNewActiveUser(_ user: UserData?) {
        currentActiveUser.send(user)
    }
}

public extension UserManager {
    nonisolated func setUserData(_ userData: UserData) {
        Task { [weak self] in
            guard let self else {
                return
            }
            do {
                try await addAndMarkAsActive(userData: userData)
            } catch {
                logger.error(error)
            }
        }
    }
}

private extension UserManager {
    func assertDidSetUp() async {
        assert(didSetUp, "UserManager not set up. Call setUp() function as soon as possible.")
    }
}

private extension [UserProfile] {
    var activeUser: UserProfile? {
        self.first { $0.isActive }
    }

    var userDatas: [UserData] {
        self.map(\.userdata)
    }
}
