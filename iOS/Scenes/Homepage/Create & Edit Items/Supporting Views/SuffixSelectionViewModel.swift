//
// SuffixSelectionViewModel.swift
// Proton Pass - Created on 03/05/2023.
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

import Client
import Combine
import Core
import Factory

final class SuffixSelectionViewModel: ObservableObject, DeinitPrintable {
    deinit { print(deinitMessage) }

    @Published private(set) var shouldUpgrade = false

    private let router = resolve(\SharedRouterContainer.mainUIKitSwiftUIRouter)

    let suffixSelection: SuffixSelection
    private var cancellables = Set<AnyCancellable>()

    init(suffixSelection: SuffixSelection) {
        self.suffixSelection = suffixSelection
        suffixSelection.attach(to: self, storeIn: &cancellables)
    }

    func upgrade() {
        router.present(for: .upgradeFlow)
    }
}
