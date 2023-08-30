//
// ArrayIsStrictlyEqualToTests.swift
// Proton Pass - Created on 30/08/2023.
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

@testable import Core
import XCTest

final class ArrayIsStrictlyEqualToTests: XCTestCase {
    private struct Person: Identifiable, Equatable {
        var id = UUID().uuidString
        var name = String.random()
    }

    func testIsStrictylyEqualTo() {
        let alice = Person()
        let bob = Person()
        let charlie = Person()

        XCTAssertTrue([alice, bob, charlie].isStrictlyEqual(to: [bob, charlie, alice]))
        XCTAssertTrue([alice, charlie, bob].isStrictlyEqual(to: [charlie, alice, bob]))
        XCTAssertTrue([alice, bob, charlie].isStrictlyEqual(to: [alice, bob, charlie]))
        XCTAssertFalse([alice, bob, charlie].isStrictlyEqual(to: [alice, bob]))
        XCTAssertFalse([bob, charlie].isStrictlyEqual(to: [alice, bob, charlie]))
    }
}
