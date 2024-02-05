//
// EditSpotlightSelectedVaultsView.swift
// Proton Pass - Created on 01/02/2024.
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
import Entities
import Factory
import SwiftUI

struct EditSpotlightSelectedVaultsView: View {
    @StateObject private var viewModel = EditSpotlightSelectedVaultsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.allVaults, id: \.hashValue) { vault in
                view(for: vault)
                PassDivider()
                    .padding(.horizontal)
            }
        }
        .scrollViewEmbeded()
        .navigationBarTitleDisplayMode(.inline)
        .background(PassColor.backgroundWeak.toColor)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Selected vaults")
                    .navigationTitleText()
            }
        }
        .navigationStackEmbeded()
    }

    @MainActor
    private func view(for vault: VaultListUiModel) -> some View {
        Button(action: {
            viewModel.selectOrDeselect(vault: vault.vault)
        }, label: {
            VaultRow(thumbnail: { VaultThumbnail(vault: vault.vault) },
                     title: vault.vault.name,
                     itemCount: vault.itemCount,
                     isShared: vault.vault.shared,
                     isSelected: viewModel.isSelected(vault: vault.vault),
                     height: 74)
                .padding(.horizontal)
        })
        .buttonStyle(.plain)
    }
}
