//
// SuffixSelectionView.swift
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
import ProtonCore_UIFoundations
import SwiftUI
import UIComponents

struct SuffixSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var suffixSelection: SuffixSelection

    var body: some View {
        let tintColor = ItemContentType.alias.normMajor2Color
        NavigationView {
            // ZStack instead of VStack because of SwiftUI bug.
            // See more in "CreateAliasLiteView.swift"
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(suffixSelection.suffixes, id: \.suffix) { suffix in
                            HStack {
                                Text(suffix.suffix)
                                    .foregroundColor(Color(uiColor: isSelected(suffix) ?
                                                           tintColor : PassColor.textNorm))
                                Spacer()

                                if isSelected(suffix) {
                                    Image(uiImage: IconProvider.checkmark)
                                        .foregroundColor(Color(uiColor: tintColor))
                                }
                            }
                            .contentShape(Rectangle())
                            .background(Color.clear)
                            .padding(.horizontal)
                            .frame(height: OptionRowHeight.compact.value)
                            .onTapGesture {
                                suffixSelection.selectedSuffix = suffix
                                dismiss()
                            }

                            PassDivider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color(uiColor: PassColor.backgroundWeak))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationTitleWithHandle(title: "Suffix")
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func isSelected(_ suffix: Suffix) -> Bool {
        suffix == suffixSelection.selectedSuffix
    }
}
