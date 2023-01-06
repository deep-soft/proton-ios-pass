//
// LogEntry.swift
// Proton Pass - Created on 04/01/2023.
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

import Foundation

public struct LogEntry: Codable {
    public let timestamp: TimeInterval
    public let subsystem: String
    public let category: String
    public let level: LogLevel
    public let message: String
    public let file: String
    public let function: String
    public let line: UInt
    public let column: UInt
}

extension LogEntry: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
        hasher.combine(subsystem)
        hasher.combine(category)
        hasher.combine(level)
        hasher.combine(message)
        hasher.combine(file)
        hasher.combine(function)
        hasher.combine(line)
        hasher.combine(column)
    }
}