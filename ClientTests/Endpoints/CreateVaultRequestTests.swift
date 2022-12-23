//
// CreateVaultRequestTests.swift
// Proton Pass - Created on 12/07/2022.
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

@testable import Client
import Core
import GoLibs
import ProtonCore_Crypto
import ProtonCore_DataModel
import XCTest

final class CreateVaultRequestTests: XCTestCase {
    func testCreateVaultSuccess() throws {
        let (key, keyPassphrase) = try CryptoUtils.generateKey(name: "test", email: "test")
        let addressId = String.random()
        let vaultName = String.random()
        let vaultDescription = String.random()
        let addressKey = AddressKey(addressId: addressId,
                                    key: Key(keyID: String.random(), privateKey: key),
                                    keyPassphrase: keyPassphrase)
        let request = try CreateVaultRequest(addressKey: addressKey,
                                             name: vaultName,
                                             description: vaultDescription)
        XCTAssertEqual(request.addressID, addressId)
        let (armoredSigningKey, signingKeyPassphrase) =
        try validateSigningKey(addressKey: addressKey.key,
                               addressKeyPassphrase: keyPassphrase,
                               request: request)

        let signingKey = Key(keyID: String.random(), privateKey: armoredSigningKey)

        let (armoredVaultKey, vaultKeyPassphrase) =
        try validateVaultKey(addressKey: addressKey.key,
                             addressKeyPassphrase: keyPassphrase,
                             requestBody: request,
                             signingKey: signingKey,
                             signingKeyPassphrase: signingKeyPassphrase)
        let vaultKey = Key(keyID: String.random(), privateKey: armoredVaultKey)
        try validateItemKey(requestBody: request,
                            signingKey: signingKey,
                            signingKeyPassphrase: signingKeyPassphrase,
                            vaultKey: vaultKey,
                            vaultKeyPassphrase: vaultKeyPassphrase)
        try validateVaultData(vaultName: vaultName,
                              vaultDescription: vaultDescription,
                              request: request,
                              vaultKey: vaultKey,
                              vaultKeyPassphrase: vaultKeyPassphrase)
    }

    func validateSigningKey(addressKey: Key,
                            addressKeyPassphrase: String,
                            request: CreateVaultRequest) throws -> (signingKey: String,
                                                                    signingKeyPassphrase: String) {
        XCTAssertFalse(request.signingKeyPassphrase.isEmpty)
        XCTAssertFalse(request.signingKeyPassphraseKeyPacket.isEmpty)
        XCTAssertFalse(request.signingKey.isEmpty)
        let passphraseKeyPacket = try request.signingKeyPassphraseKeyPacket.base64Decode()
        let decodedPassphrase = try request.signingKeyPassphrase.base64Decode()

        let decryptedSessionKey = try throwing { error in
            HelperDecryptSessionKey(addressKey.privateKey,
                                    addressKeyPassphrase.data(using: .utf8),
                                    passphraseKeyPacket,
                                    &error)
        }

        let decryptedPassphrase = try decryptedSessionKey?.decrypt(decodedPassphrase)

        let signingKeyFingerprint = try CryptoUtils.getFingerprint(key: request.signingKey)
        let decodedAcceptanceSignature = try request.acceptanceSignature.base64Decode()

        let armoredDecodedAcceptanceSignature = try throwing { error in
            ArmorArmorWithType(decodedAcceptanceSignature,
                               "SIGNATURE",
                               &error)
        }

        XCTAssertTrue(try Crypto().verifyDetached(signature: armoredDecodedAcceptanceSignature,
                                                  plainData: Data(signingKeyFingerprint.utf8),
                                                  publicKey: addressKey.publicKey,
                                                  verifyTime: Int64(Date().timeIntervalSince1970)))

        return (request.signingKey, try XCTUnwrap(decryptedPassphrase).getString())
    }

    func validateVaultKey(addressKey: Key,
                          addressKeyPassphrase: String,
                          requestBody: CreateVaultRequest,
                          signingKey: Key,
                          signingKeyPassphrase: String) throws -> (vaultKey: String,
                                                                   vaultKeyPassphrase: String) {
        XCTAssertFalse(requestBody.vaultKeyPassphrase.isEmpty)
        XCTAssertFalse(requestBody.vaultKeySignature.isEmpty)
        XCTAssertFalse(requestBody.vaultKey.isEmpty)
        let passphraseKeyPacket = try requestBody.keyPacket.base64Decode()
        let decodedPassphrase = try requestBody.vaultKeyPassphrase.base64Decode()

        let decryptedSessionKey = try throwing { error in
            HelperDecryptSessionKey(addressKey.privateKey,
                                    addressKeyPassphrase.data(using: .utf8),
                                    passphraseKeyPacket,
                                    &error)
        }

        let decryptedPassphrase = try decryptedSessionKey?.decrypt(decodedPassphrase)

        let vaultKeyFingerprint = try CryptoUtils.getFingerprint(key: requestBody.vaultKey)
        let decodedVaultKeySignature = try requestBody.vaultKeySignature.base64Decode()

        let armoredDecodedVaultKeySignature = try throwing { error in
            ArmorArmorWithType(decodedVaultKeySignature,
                               "SIGNATURE",
                               &error)
        }

        XCTAssertTrue(try Crypto().verifyDetached(signature: armoredDecodedVaultKeySignature,
                                                  plainData: Data(vaultKeyFingerprint.utf8),
                                                  publicKey: signingKey.publicKey,
                                                  verifyTime: Int64(Date().timeIntervalSince1970)))

        return (requestBody.vaultKey, try XCTUnwrap(decryptedPassphrase).getString())
    }

    func validateItemKey(requestBody: CreateVaultRequest,
                         signingKey: Key,
                         signingKeyPassphrase: String,
                         vaultKey: Key,
                         vaultKeyPassphrase: String) throws {
        XCTAssertFalse(requestBody.itemKeyPassphrase.isEmpty)
        XCTAssertFalse(requestBody.itemKeySignature.isEmpty)
        XCTAssertFalse(requestBody.itemKey.isEmpty)
        let passphraseKeyPacket = try requestBody.itemKeyPassphraseKeyPacket.base64Decode()
        let decodedPassphrase = try requestBody.itemKeyPassphrase.base64Decode()

        let decryptedSessionKey = try throwing { error in
            HelperDecryptSessionKey(vaultKey.privateKey,
                                    vaultKeyPassphrase.data(using: .utf8),
                                    passphraseKeyPacket,
                                    &error)
        }

        // swiftlint:disable:next todo
        // TODO: Try to unlock item key
        let decryptedPassphrase = try decryptedSessionKey?.decrypt(decodedPassphrase)

        let itemKeyFingerprint = try CryptoUtils.getFingerprint(key: requestBody.itemKey)
        let decodedItemKeySignature = try requestBody.itemKeySignature.base64Decode()

        let armoredDecodedItemKeySignature = try throwing { error in
            ArmorArmorWithType(decodedItemKeySignature,
                               "SIGNATURE",
                               &error)
        }

        XCTAssertTrue(try Crypto().verifyDetached(signature: armoredDecodedItemKeySignature,
                                                  plainData: Data(itemKeyFingerprint.utf8),
                                                  publicKey: signingKey.publicKey,
                                                  verifyTime: Int64(Date().timeIntervalSince1970)))
    }

    func validateVaultData(vaultName: String,
                           vaultDescription: String,
                           request: CreateVaultRequest,
                           vaultKey: Key,
                           vaultKeyPassphrase: String) throws {
        XCTAssertFalse(request.content.isEmpty)
        let encryptedVaultData = try XCTUnwrap(request.content.base64Decode())

        let armoredContent = try throwing { error in
            ArmorArmorWithType(encryptedVaultData,
                               "PGP MESSAGE",
                               &error)
        }

        let deryptedVaultData = try XCTUnwrap(Crypto().decrypt(encrypted: armoredContent,
                                                               privateKey: vaultKey.privateKey,
                                                               passphrase: vaultKeyPassphrase).data(using: .utf8))
        let vault = try VaultProtobuf(data: deryptedVaultData)
        XCTAssertEqual(vault.name, vaultName)
        XCTAssertEqual(vault.description, vaultDescription)
    }
}
