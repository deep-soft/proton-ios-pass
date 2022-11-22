//
// LogInDetailViewModel.swift
// Proton Pass - Created on 07/09/2022.
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

import Client
import Core
import UIKit

final class LogInDetailViewModel: BaseItemDetailViewModel, DeinitPrintable, ObservableObject {
    deinit { print(deinitMessage) }

    @Published private(set) var name = ""
    @Published private(set) var username = ""
    @Published private(set) var urls: [String] = []
    @Published private(set) var password = ""
    @Published private(set) var note = ""

    override func bindValues() {
        if case let .login(username, password, urls) = itemContent.contentData {
            self.name = itemContent.name
            self.username = username
            self.urls = urls
            self.password = password
            self.note = itemContent.note
        } else {
            fatalError("Expecting login type")
        }
    }

    func copyUsername() {
        copyToClipboard(text: username, message: "Username copied")
    }

    func copyPassword() {
        copyToClipboard(text: password, message: "Password copied")
    }

    func showLargePassword() {
        showLarge(password)
    }

    func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
