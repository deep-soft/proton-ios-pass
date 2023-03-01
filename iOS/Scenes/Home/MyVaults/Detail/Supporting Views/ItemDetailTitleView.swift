//
// ItemDetailTitleView.swift
// Proton Pass - Created on 02/02/2023.
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

enum ItemDetailTitleIcon {
    case image(UIImage)
    case initials(String)
    case notApplicable
}

struct ItemDetailTitleView: View {
    let title: String
    let color: UIColor
    let icon: ItemDetailTitleIcon

    init(itemContent: ItemContent) {
        self.title = itemContent.name
        self.color = itemContent.tintColor
        switch itemContent.contentData.type {
        case .alias:
            self.icon = .image(IconProvider.alias)
        case .login:
            self.icon = .initials(String(itemContent.name.prefix(2)).uppercased())
        case .note:
            self.icon = .notApplicable
        }
    }

    var body: some View {
        HStack {
            ZStack {
                Color(uiColor: color.withAlphaComponent(0.24))
                    .clipShape(Circle())

                switch icon {
                case .image(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .foregroundColor(Color(uiColor: color))
                case .initials(let initials):
                    Text(initials.uppercased())
                        .fontWeight(.medium)
                        .foregroundColor(Color(uiColor: color))
                case .notApplicable:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}