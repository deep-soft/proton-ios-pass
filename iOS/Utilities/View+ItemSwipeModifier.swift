//
// View+ItemSwipeModifier.swift
// Proton Pass - Created on 28/03/2023.
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
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct ItemSwipeModifier: ViewModifier {
    @Binding var itemToBePermanentlyDeleted: ItemTypeIdentifiable?
    let item: ItemTypeIdentifiable
    let isTrashed: Bool
    let itemContextMenuHandler: ItemContextMenuHandler

    /// Active item:  swipe right-to-left to move to trash
    /// Trashed item: swipe left-to-right to restore, swipe right-to-left to permanently delete
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                if isTrashed {
                    Button(action: {
                        itemContextMenuHandler.restore(item)
                    }, label: {
                        Label(title: {
                            Text("Restore")
                        }, icon: {
                            Image(uiImage: IconProvider.clockRotateLeft)
                        })
                    })
                    .tint(.notificationSuccess)
                } else {
                    EmptyView()
                }
            }
            .swipeActions(edge: .trailing) {
                if isTrashed {
                    Button(action: {
                        itemToBePermanentlyDeleted = item
                    }, label: {
                        Label(title: {
                            Text("Permanently delete")
                        }, icon: {
                            Image(uiImage: IconProvider.trash)
                        })
                    })
                    .tint(Color(uiColor: .init(red: 252, green: 156, blue: 159)))
                } else {
                    Button(action: {
                        itemContextMenuHandler.trash(item)
                    }, label: {
                        Label(title: {
                            Text("Trash")
                        }, icon: {
                            Image(uiImage: IconProvider.trash)
                        })
                    })
                    .tint(Color(uiColor: .init(red: 252, green: 156, blue: 159)))
                }
            }
    }
}
