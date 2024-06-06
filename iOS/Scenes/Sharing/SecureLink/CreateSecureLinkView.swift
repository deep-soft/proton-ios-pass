//
// CreateSecureLinkView.swift
// Proton Pass - Created on 16/05/2024.
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
//

import DesignSystem
import Entities
import Factory
import Macro
import ProtonCoreUIFoundations
import SwiftUI

struct CreateSecureLinkView: View {
    @StateObject private var viewModel: CreateSecureLinkViewModel

    init(viewModel: CreateSecureLinkViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        mainContainer
            .navigationStackEmbeded()
    }
}

private extension CreateSecureLinkView {
    var mainContainer: some View {
        VStack(spacing: DesignConstant.sectionPadding) {
            if let link = viewModel.link {
                let uiModel = SecureLinkDetailUiModel(itemContent: viewModel.itemContent,
                                                      url: link.url,
                                                      expirationTime: link.expirationTime,
                                                      readCount: nil,
                                                      maxReadCount: viewModel.readCount.nilIfZero,
                                                      mode: .create)
                SecureLinkDetailView(viewModel: .init(uiModel: uiModel))
            } else {
                createLink
            }
        }
        .padding(.horizontal, DesignConstant.sectionPadding)
        .padding(.bottom, DesignConstant.sectionPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showSpinner(viewModel.loading)
        .animation(.default, value: viewModel.link)
        .animation(.default, value: viewModel.readCount)
        .background(PassColor.backgroundNorm.toColor)
        .if(viewModel.link == nil) { view in
            view.toolbar { toolbarContent }
        }
    }
}

private extension CreateSecureLinkView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Share Secure Link")
                .navigationTitleText()
        }
    }
}

private extension CreateSecureLinkView {
    var createLink: some View {
        VStack(spacing: DesignConstant.sectionPadding) {
            HStack {
                Text("Link expires after")
                    .foregroundStyle(PassColor.textNorm.toColor)

                Spacer()

                Picker("Link expires after", selection: $viewModel.selectedExpiration) {
                    ForEach(SecureLinkExpiration.supportedExpirations) { expiration in
                        Text(expiration.title)
                            .tag(expiration)
                            .fontWeight(.bold)
                    }
                }
                .labelsHidden()
                .padding(4)
                .tint(PassColor.textNorm.toColor)
                .background(PassColor.interactionNormMinor1.toColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            PassDivider()

            Toggle("Restrict number of views", isOn: viewCountBinding)
                .toggleStyle(SwitchToggleStyle.pass)
                .foregroundStyle(PassColor.textNorm.toColor)

            if viewModel.readCount != 0 {
                HStack {
                    Text("Maximum views:")
                    Spacer()
                    CapsuleStepper(value: $viewModel.readCount,
                                   step: 1,
                                   minValue: 1,
                                   textColor: PassColor.textNorm.toColor,
                                   backgroundColor: PassColor.interactionNormMinor1.toColor)
                }
                .foregroundStyle(PassColor.textNorm.toColor)
                .padding(.vertical, 5)
            } else {
                Spacer()
            }

            CapsuleTextButton(title: "Generate secure link",
                              titleColor: PassColor.textInvert,
                              backgroundColor: PassColor.interactionNormMajor1,
                              height: 48,
                              action: { viewModel.createLink() })
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var viewCountBinding: Binding<Bool> {
        .init(get: {
            viewModel.readCount != 0
        }, set: { newValue in
            viewModel.readCount = newValue ? 1 : 0
        })
    }
}
