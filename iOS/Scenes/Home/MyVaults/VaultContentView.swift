//
// VaultContentView.swift
// Proton Pass - Created on 21/07/2022.
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
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct VaultContentView: View {
    @StateObject private var viewModel: VaultContentViewModel
    @State private var didAppear = false
    @State private var selectedItem: ItemListUiModel?
    @State private var isShowingTrashingAlert = false

    private var selectedVaultName: String {
        viewModel.selectedVault?.name ?? "All vaults"
    }

    init(viewModel: VaultContentViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            // Embed in a ZStack with clear color as background
            // in order for bottom banner to properly display
            // as Color occupies the whole ZStack
            Color.clear
            switch viewModel.state {
            case .loading:
                LoadingVaultView()
                    .padding()

            case .loaded:
                if viewModel.items.isEmpty {
                    EmptyVaultView()
                        .padding(.horizontal)
                } else {
                    itemList
                }

            case .error(let error):
                RetryableErrorView(errorMessage: error.messageForTheUser,
                                   onRetry: { viewModel.fetchItems(forceRefresh: true) })
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .moveToTrashAlert(isPresented: $isShowingTrashingAlert) {
            if let selectedItem {
                viewModel.trashItem(selectedItem)
            }
        }
        .toolbar { toolbarContent }
        .onAppear {
            if !didAppear {
                viewModel.fetchItems(forceRefresh: false)
                didAppear = true
            }
        }
    }

    private var itemList: some View {
        List {
            ForEach(viewModel.items, id: \.itemId) { item in
                GenericItemView(item: item,
                                action: { viewModel.selectItem(item) },
                                subtitleLineLimit: 1,
                                trailingView: { trailingView(for: item) })
                .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .animation(.default, value: viewModel.items.count)
        .refreshable { await viewModel.forceRefreshItems() }
    }

    private func trailingView(for item: ItemListUiModel) -> some View {
        VStack {
            Spacer()

            Menu(content: {
                switch item.type {
                case .login:
                    CopyMenuButton(title: "Copy username",
                                   action: { viewModel.copyUsername(item) })

                    CopyMenuButton(title: "Copy password",
                                   action: { viewModel.copyPassword(item) })

                case .alias:
                    CopyMenuButton(title: "Copy email address",
                                   action: { viewModel.copyEmailAddress(item) })
                default:
                    EmptyView()
                }

                EditMenuButton {
                    viewModel.editItem(item)
                }

                Divider()

                DestructiveButton(
                    title: "Move to Trash",
                    icon: IconProvider.trash,
                    action: {
                        selectedItem = item
                        isShowingTrashingAlert.toggle()
                    })
            }, label: {
                Image(uiImage: IconProvider.threeDotsHorizontal)
                    .foregroundColor(.secondary)
            })

            Spacer()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            ToggleSidebarButton(action: viewModel.toggleSidebar)
        }

//        ToolbarItem(placement: .principal) {
//            Menu(content: {
//                Section {
//                    Button(action: {
//                        viewModel.update(selectedVault: nil)
//                    }, label: {
//                        Text("All vaults")
//                    })
//                }
//
//                Section {
//                    ForEach(viewModel.vaults, id: \.id) { vault in
//                        Button(action: {
//                            viewModel.update(selectedVault: vault)
//                        }, label: {
//                            Label(title: {
//                                Text(vault.name)
//                            }, icon: {
//                                Image(uiImage: IconProvider.vault)
//                            })
//                        })
//                    }
//                }
//
//                Section {
//                    Button(action: viewModel.createVaultAction) {
//                        Label(title: {
//                            Text("Add vault")
//                        }, icon: {
//                            Image(uiImage: IconProvider.plus)
//                        })
//                    }
//                }
//            }, label: {
//                ZStack {
//                    Text(selectedVaultName)
//                        .fontWeight(.medium)
//                        .transaction { transaction in
//                            transaction.animation = nil
//                        }
//
//                    HStack {
//                        Spacer()
//                        Image(uiImage: IconProvider.chevronDown)
//                    }
//                    .padding(.trailing)
//                }
//                .foregroundColor(.white)
//                .frame(width: UIScreen.main.bounds.width / 2)
//                .padding(.vertical, 8)
//                .background(Color(ColorProvider.BrandNorm))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//            })
//        }

        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                Button(action: viewModel.search) {
                    Image(uiImage: IconProvider.magnifier)
                }

                Button(action: viewModel.createItem) {
                    Image(uiImage: IconProvider.plus)
                }
            }
            .foregroundColor(Color(.label))
            .disabled(!viewModel.state.isLoaded)
            .opacity(!viewModel.state.isLoaded ? 0.0 : 1.0)
        }
    }

    private var summaryView: some View {
        HStack {
            CategorySummaryView(summary: .init(aliasCount: 0))
            CategorySummaryView(summary: .init(loginCount: 0))
            CategorySummaryView(summary: .init(noteCount: 0))
        }
    }
}
