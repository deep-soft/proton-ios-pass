//
// GeneratePasswordViewModel.swift
// Proton Pass - Created on 24/07/2022.
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

import Combine
import Core
import SwiftUI
import UIComponents

protocol GeneratePasswordViewModelDelegate: AnyObject {
    func generatePasswordViewModelDidConfirm(password: String)
}

protocol GeneratePasswordViewModelUiDelegate: AnyObject {
    func generatePasswordViewModelWantsToChangePasswordType(currentType: PasswordType)
    func generatePasswordViewModelWantsToChangeWordSeparator(currentSeparator: WordSeparator)
    func generatePasswordViewModelWantsToUpdateSheetHeight(passwordType: PasswordType,
                                                           isShowingAdvancedOptions: Bool)
}

enum PasswordUtils {
    static func generateColoredPasswords(_ password: String) -> [Text] {
        var texts = [Text]()
        password.forEach { char in
            var color = Color(uiColor: PassColor.textNorm)
            if AllowedCharacter.digit.rawValue.contains(char) {
                color = Color(uiColor: PassColor.loginInteractionNormMajor2)
            } else if AllowedCharacter.special.rawValue.contains(char) {
                color = Color(uiColor: PassColor.aliasInteractionNormMajor2)
            }
            texts.append(Text(String(char)).foregroundColor(color))
        }
        return texts
    }
}

final class GeneratePasswordViewModel: DeinitPrintable, ObservableObject {
    deinit { print(deinitMessage) }

    let mode: GeneratePasswordViewMode

    @Published private(set) var password = ""
    @Published private(set) var texts: [Text] = []
    @Published private(set) var type: PasswordType = .random
    @Published var isShowingAdvancedOptions = false { didSet { requestHeightUpdate() } }

    // Random password options
    @Published var characterCount: Double = 16 // Slider expects Double instead of Int
    @Published var hasSpecialCharacters = true
    @Published var hasCapitalCharacters = true
    @Published var hasNumberCharacters = true

    // Memorable password options
    @Published private(set) var wordSeparator: WordSeparator = .hyphens
    @Published var wordCount: Double = 4
    @Published var capitalizingWords = false
    @Published var includingNumbers = false

    private var cancellables = Set<AnyCancellable>()
    weak var delegate: GeneratePasswordViewModelDelegate?
    weak var uiDelegate: GeneratePasswordViewModelUiDelegate?

    init(mode: GeneratePasswordViewMode) {
        self.mode = mode
        self.regenerate()

        $password
            .sink { [unowned self] newPassword in
                texts = PasswordUtils.generateColoredPasswords(newPassword)
            }
            .store(in: &cancellables)

        $characterCount
            .removeDuplicates()
            .sink { [unowned self] newValue in
                regenerate(length: newValue, hasSpecialCharacters: hasSpecialCharacters)
            }
            .store(in: &cancellables)

        $hasSpecialCharacters
            .sink { [unowned self] newValue in
                regenerate(length: characterCount, hasSpecialCharacters: newValue)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Public APIs
extension GeneratePasswordViewModel {
    func regenerate() {
        regenerate(length: characterCount, hasSpecialCharacters: hasSpecialCharacters)
    }

    func changeType() {
        uiDelegate?.generatePasswordViewModelWantsToChangePasswordType(currentType: type)
    }

    func changeWordSeparator() {
        uiDelegate?.generatePasswordViewModelWantsToChangeWordSeparator(currentSeparator: wordSeparator)
    }

    func confirm() {
        delegate?.generatePasswordViewModelDidConfirm(password: password)
    }
}

// MARK: - Private APIs
private extension GeneratePasswordViewModel {
    func regenerate(length: Double, hasSpecialCharacters: Bool) {
        var allowedCharacters: [AllowedCharacter] = [.lowercase, .uppercase, .digit]
        if hasSpecialCharacters {
            allowedCharacters.append(.special)
        }
        password = .random(allowedCharacters: allowedCharacters, length: Int(length))
    }

    func requestHeightUpdate() {
        uiDelegate?.generatePasswordViewModelWantsToUpdateSheetHeight(
            passwordType: type,
            isShowingAdvancedOptions: isShowingAdvancedOptions)
    }
}

// MARK: PasswordTypesViewModelDelegate
extension GeneratePasswordViewModel: PasswordTypesViewModelDelegate {
    func passwordTypesViewModelDidSelect(type: PasswordType) {
        self.type = type
        self.isShowingAdvancedOptions = false
        requestHeightUpdate()
    }
}

// MARK: - WordSeparatorsViewModelDelegate
extension GeneratePasswordViewModel: WordSeparatorsViewModelDelegate {
    func wordSeparatorsViewModelDidSelect(separator: WordSeparator) {
        self.wordSeparator = separator
    }
}
