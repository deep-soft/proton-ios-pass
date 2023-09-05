//
//  LoginBaseTestCase.swift
//  iOSUITests - Created on 12/23/22.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import fusion
import ProtonCoreDoh
import ProtonCoreEnvironment
import ProtonCoreObfuscatedConstants
import ProtonCoreQuarkCommands
import ProtonCoreTestingToolkit
import XCTest

class LoginBaseTestCase: ProtonCoreBaseTestCase {
    let testData = TestData()
    var doh: DoHInterface {
        if let customDomain = dynamicDomain.map({ "\($0)" }) {
            return CustomServerConfigDoH(
                signupDomain: customDomain,
                captchaHost: "https://api.\(customDomain)",
                humanVerificationV3Host: "https://verify.\(customDomain)",
                accountHost: "https://account.\(customDomain)",
                defaultHost: "https://\(customDomain)",
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
        } else {
            return CustomServerConfigDoH(
                signupDomain: ObfuscatedConstants.blackSignupDomain,
                captchaHost: ObfuscatedConstants.blackCaptchaHost,
                humanVerificationV3Host: ObfuscatedConstants.blackHumanVerificationV3Host,
                accountHost: ObfuscatedConstants.blackAccountHost,
                defaultHost: ObfuscatedConstants.blackDefaultHost,
                apiHost: ObfuscatedConstants.blackApiHost,
                defaultPath: ObfuscatedConstants.blackDefaultPath
            )
        }
    }

    let entryRobot = AppMainRobot()
    var appRobot: MainRobot!

    override func setUp() {
        beforeSetUp(bundleIdentifier: "me.proton.pass.ios.iOSUITests")
        super.setUp()
    }

    // MARK: - Helpers

    func createAccount(_ randomUsername: String, _ randomPassword: String) {
        let quarkCommandTimeout = 30.0

        let expectQuarkCommandToFinish = expectation(description: "Quark command should finish")
        var quarkCommandResult: Result<CreatedAccountDetails, CreateAccountError>?
        QuarkCommands.create(account: .freeNoAddressNoKeys(username: randomUsername, password: randomPassword),
                             currentlyUsedHostUrl: doh.getCurrentlyUsedHostUrl()) { result in
            quarkCommandResult = result
            expectQuarkCommandToFinish.fulfill()
        }
        wait(for: [expectQuarkCommandToFinish], timeout: quarkCommandTimeout)
        if case .failure(let error) = quarkCommandResult {
            XCTFail("Username account creation failed in test \(#function) because of \(error.userFacingMessageInQuarkCommands)")
        }
    }
}
