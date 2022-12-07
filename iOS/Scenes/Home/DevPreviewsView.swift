//
// DevPreviewsView.swift
// Proton Pass - Created on 07/12/2022.
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

import SwiftUI

/// Preview features under development
struct DevPreviewsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    NavigationLink(destination: { OnboardingAutoFill(onProceed: {}, onCancel: {}) },
                                   label: { Text("AutoFill") })
                }, header: {
                    Text("Onboarding")
                })

                Section(content: {
                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }, label: {
                        Text("Success")
                    })

                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    }, label: {
                        Text("Warning")
                    })

                    Button(action: {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }, label: {
                        Text("Error")
                    })
                }, header: {
                    Text("Haptic feedbacks")
                })
            }
            .navigationTitle("Developer previews")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(.interactionNorm)
    }
}
