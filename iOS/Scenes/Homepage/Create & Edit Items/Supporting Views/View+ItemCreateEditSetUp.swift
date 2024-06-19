//
// View+ItemCreateEditSetUp.swift
// Proton Pass - Created on 19/06/2024.
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
import SwiftUI

/// Set up common UI appearance for item create/edit pages
/// e.g. navigation bar, background color, toolbar, discard changes alert...
struct ItemCreateEditSetUpModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BaseCreateEditItemViewModel

    func body(content: Content) -> some View {
        content
            .background(PassColor.backgroundNorm.toColor)
            .navigationBarTitleDisplayMode(.inline)
            .tint(viewModel.itemContentType().normMajor1Color.toColor)
            .disabled(viewModel.isSaving)
            .obsoleteItemAlert(isPresented: $viewModel.isObsolete,
                               onAction: dismiss.callAsFunction)
            .discardChangesAlert(isPresented: $viewModel.isShowingDiscardAlert,
                                 onDiscard: dismiss.callAsFunction)
            .toolbar {
                CreateEditItemToolbar(saveButtonTitle: viewModel.saveButtonTitle(),
                                      isSaveable: viewModel.isSaveable,
                                      isSaving: viewModel.isSaving,
                                      canScanDocuments: viewModel.canScanDocuments,
                                      vault: viewModel.editableVault,
                                      itemContentType: viewModel.itemContentType(),
                                      shouldUpgrade: viewModel.shouldUpgrade,
                                      isPhone: viewModel.isPhone,
                                      onSelectVault: { viewModel.changeVault() },
                                      onGoBack: { viewModel.isShowingDiscardAlert.toggle() },
                                      onUpgrade: {
                                          if viewModel.shouldUpgrade {
                                              viewModel.upgrade()
                                          }
                                      },
                                      onScan: { viewModel.openScanner() },
                                      onSave: { viewModel.save() })
            }
    }
}

@MainActor
extension View {
    func itemCreateEditSetUp(_ viewModel: BaseCreateEditItemViewModel) -> some View {
        modifier(ItemCreateEditSetUpModifier(viewModel: viewModel))
    }
}
