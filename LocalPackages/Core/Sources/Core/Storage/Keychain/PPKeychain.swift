//
// PPKeychain.swift
// Proton Pass - Created on 03/07/2022.
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

import Foundation
import ProtonCoreKeymaker

public protocol KeychainProtocol: AnyObject, Sendable {
    // Getters
    func dataOrError(forKey key: String, attributes: [CFString: Any]?) throws -> Data?
    func stringOrError(forKey key: String, attributes: [CFString: Any]?) throws -> String?

    // Setters
    func setOrError(_ data: Data, forKey key: String, attributes: [CFString: Any]?) throws
    func setOrError(_ string: String, forKey key: String, attributes: [CFString: Any]?) throws

    // Cleaner
    func removeOrError(forKey key: String) throws
}

public extension KeychainProtocol {
    func dataOrError(forKey key: String) throws -> Data? {
        try dataOrError(forKey: key, attributes: nil)
    }

    func stringOrError(forKey key: String) throws -> String? {
        try stringOrError(forKey: key, attributes: nil)
    }

    func setOrError(_ data: Data, forKey key: String) throws {
        try setOrError(data, forKey: key, attributes: nil)
    }

    func setOrError(_ string: String, forKey key: String) throws {
        try setOrError(string, forKey: key, attributes: nil)
    }
}

extension Keychain: @unchecked Sendable, KeychainProtocol {}

public final class PPKeychain: Keychain {
    public init() {
        super.init(service: "ch.protonmail", accessGroup: Constants.keychainGroup)
    }
}

extension PPKeychain: SettingsProvider {
    private static let LockTimeKey = "PPKeychain.LockTimeKey"

    public var lockTime: AutolockTimeout {
        get {
            guard let string = string(forKey: Self.LockTimeKey), let intValue = Int(string) else {
                return .never
            }
            return AutolockTimeout(rawValue: intValue)
        }
        set {
            set(String(newValue.rawValue), forKey: Self.LockTimeKey)
        }
    }
}
