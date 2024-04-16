//
// StaticToggle.swift
// Proton Pass - Created on 09/04/2024.
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

import SwiftUI

public struct StaticToggle: View {
    private let titleKey: LocalizedStringKey?
    private let isOn: Bool
    private let titleColor: UIColor
    private let tintColor: UIColor
    private let action: (() -> Void)?

    public init(_ titleKey: LocalizedStringKey? = nil,
                isOn: Bool,
                titleColor: UIColor = PassColor.textNorm,
                tintColor: UIColor = PassColor.interactionNorm,
                action: (() -> Void)? = nil) {
        self.titleKey = titleKey
        self.isOn = isOn
        self.titleColor = titleColor
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Toggle(isOn: .constant(isOn), label: {
            if let titleKey {
                Text(titleKey)
                    .foregroundStyle(titleColor.toColor)
            }
        })
        .tint(tintColor.toColor)
        .onTapGesture { action?() }
    }
}
