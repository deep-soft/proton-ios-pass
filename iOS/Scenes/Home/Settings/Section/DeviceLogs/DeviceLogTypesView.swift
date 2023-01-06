//
// DeviceLogTypesView.swift
// Proton Pass - Created on 02/01/2023.
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

import ProtonCore_UIFoundations
import SwiftUI

struct DeviceLogTypesView: View {
    var onGoBack: () -> Void
    var onSelect: (PassLogModule) -> Void
    var onClearLogs: () -> Void

    var body: some View {
        Form {
            Section {
                ForEach(PassLogModule.allCases, id: \.hashValue) { module in
                    Button(action: {
                        onSelect(module)
                    }, label: {
                        Text(module.title)
                    })
                    .foregroundColor(.interactionNorm)
                }
            }

            Section {
                Button(role: .destructive, action: onClearLogs) {
                    Text("Clear All Logs")
                }
            }
        }
        .navigationTitle("Device Logs")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onGoBack) {
                    Image(uiImage: IconProvider.chevronLeft)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}