//
// AccountSwitcherSection.swift
// Proton Pass - Created on 26/06/2024.
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

import DesignSystem
import Factory
import Screens
import SwiftUI

struct AccountSwitcherSection: View {
    var body: some View {
        NavigationLink(destination: { AccountSwitcherView() },
                       label: { Text(verbatim: "Account switcher") })
    }
}

private struct AccountSwitcherView: View {
    @State private var showSwitcher = false
    @Namespace private var namespace
    private let router = resolve(\SharedRouterContainer.mainUIKitSwiftUIRouter)

    private let eric = AccountCellDetail(id: UUID().uuidString,
                                         isPremium: true,
                                         initial: "E",
                                         displayName: "Eric Norbert",
                                         planName: "Pass Plus",
                                         email: "eric.norbert@proton.me")

    private let john = AccountCellDetail(id: UUID().uuidString,
                                         isPremium: false,
                                         initial: "J",
                                         displayName: "John Doe",
                                         planName: "Pass Free",
                                         email: "john.doe@proton.me")

    var body: some View {
        ScrollView {
            VStack {
                Text(verbatim: "Account switcher")
                AccountCell(detail: eric,
                            isActive: false,
                            showInactiveIcon: true,
                            animationNamespace: namespace)
                    .padding()
                    .roundedEditableSection()
                    .animation(.default, value: showSwitcher)
                    .onTapGesture {
                        withAnimation {
                            showSwitcher.toggle()
                        }
                    }

                ForEach(0..<20, id: \.self) { index in
                    Text(verbatim: "Row #\(index)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .roundedEditableSection()
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(PassColor.backgroundNorm.toColor)
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AccountSwitchModifier(details: [eric, john],
                                        activeId: eric.id,
                                        showSwitcher: $showSwitcher,
                                        animationNamespace: namespace,
                                        onSelect: { handleSelection($0) },
                                        onManage: { handleManage($0) },
                                        onSignOut: { handleSignOut($0) },
                                        onAddAccount: { handleAddAccount() }))
    }
}

@MainActor
private extension AccountSwitcherView {
    func handleSelection(_ account: AccountCellDetail) {
        dismissAccountSwitcherAndDisplay(message: "Select \(account.id)")
    }

    func handleSignOut(_ account: AccountCellDetail) {
        dismissAccountSwitcherAndDisplay(message: "Sign out \(account)")
    }

    func handleManage(_ account: AccountCellDetail) {
        dismissAccountSwitcherAndDisplay(message: "Manage \(account)")
    }

    func handleAddAccount() {
        dismissAccountSwitcherAndDisplay(message: "Add new account")
    }

    func dismissAccountSwitcherAndDisplay(message: String) {
        withAnimation {
            showSwitcher.toggle()
        }
        router.display(element: .infosMessage(message))
    }
}
