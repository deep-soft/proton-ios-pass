//
// WeaknessStats.swift
// Proton Pass - Created on 08/03/2024.
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

public struct WeaknessStats: Equatable, Sendable {
    public let weakPasswords: Int
    public let reusedPasswords: Int
    public let missing2FA: Int
    public let excludedItems: Int
    public let exposedPasswords: Int

    public init(weakPasswords: Int,
                reusedPasswords: Int,
                missing2FA: Int,
                excludedItems: Int,
                exposedPasswords: Int) {
        self.weakPasswords = weakPasswords
        self.reusedPasswords = reusedPasswords
        self.missing2FA = missing2FA
        self.excludedItems = excludedItems
        self.exposedPasswords = exposedPasswords
    }

    public static var `default`: WeaknessStats {
        WeaknessStats(weakPasswords: 0,
                      reusedPasswords: 0,
                      missing2FA: 0,
                      excludedItems: 0,
                      exposedPasswords: 0)
    }
}
