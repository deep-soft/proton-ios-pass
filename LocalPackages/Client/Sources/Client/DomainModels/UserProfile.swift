//
// UserProfile.swift
// Proton Pass - Created on 27/06/2024.
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

import Foundation
import ProtonCoreLogin

public struct UserProfile: Sendable, Identifiable {
    public let userdata: UserData
    public let isActive: Bool
    public let lastActiveTime: TimeInterval

    public var id: String {
        userdata.user.ID
    }

    public init(userdata: UserData, isActive: Bool, lastActiveTime: TimeInterval) {
        self.userdata = userdata
        self.isActive = isActive
        self.lastActiveTime = lastActiveTime
    }

    public func copy(userData: UserData) -> UserProfile {
        UserProfile(userdata: userData, isActive: isActive, lastActiveTime: lastActiveTime)
    }

    public func copy(isActive: Bool) -> UserProfile {
        UserProfile(userdata: userdata, isActive: isActive, lastActiveTime: lastActiveTime)
    }
}
