//
// ItemFlagable.swift
// Proton Pass - Created on 27/04/2024.
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

import Foundation

public protocol ItemFlagable: Sendable {
    var flags: Int { get }
}

private extension ItemFlagable {
    var itemFlags: ItemFlags {
        .init(rawValue: flags)
    }
}

public extension ItemFlagable {
    var monitoringDisabled: Bool {
        itemFlags.contains(.monitoringDisabled)
    }

    var isBreached: Bool {
        itemFlags.contains(.isBreached)
    }
}

private struct ItemFlags: Sendable, OptionSet {
    let rawValue: Int
    static let monitoringDisabled = ItemFlags(rawValue: 1 << 0)
    static let isBreached = ItemFlags(rawValue: 1 << 1)
}
