//
//
// CreateEditIdentityView.swift
// Proton Pass - Created on 21/05/2024.
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

// swiftlint:disable file_length
private enum SectionsSheetStates: MultipleSheetsDisplaying {
    case none
    case personal(CreateEditIdentitySection)
    case address(CreateEditIdentitySection)
    case contact(CreateEditIdentitySection)
    case work(CreateEditIdentitySection)

    var title: LocalizedStringKey? {
        switch self {
        case .personal:
            "Personal details"
        case .address:
            "Address details"
        case .contact:
            "Contact details"
        case .work:
            "Work details"
        default:
            nil
        }
    }

    var height: CGFloat {
        switch self {
        case .contact, .personal:
            480
        case .address:
            280
        case .work:
            350
        default:
            0
        }
    }

    var section: CreateEditIdentitySection? {
        switch self {
        case let .address(section), let .contact(section), let .personal(section), let .work(section):
            section
        default:
            nil
        }
    }
}

struct CreateEditIdentityView: View {
    @StateObject private var viewModel: CreateEditIdentityViewModel
    @State private var sheetState: SectionsSheetStates = .none
    @State private var showCustomTitleAlert = false
    @State private var showSectionTitleModification = false
    @State private var showDeleteCustomSectionAlert = false
    @FocusState private var focusedField: Field?

    init(viewModel: CreateEditIdentityViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    enum Field: CustomFieldTypes {
        case title
        // swiftlint:disable:next todo
        // TODO: implement focus later
//        case fullName
//        case email
//        case phoneNumber
//        case firstName
//        case middleName
//        case lastName
//        case birthdate
//        case gender
//        case organization
//        case streetAddress
//        case zipOrPostalCode
//        case city
//        case stateOrProvince
//        case countryOrRegion
//        case floor
//        case county
//        case socialSecurityNumber
//        case passportNumber
//        case licenseNumber
//        case website
//        case xHandle
//        case secondPhoneNumber
//        case linkedIn
//        case reddit
//        case facebook
//        case yahoo
//        case instagram
//        case company
//        case jobTitle
//        case personalWebsite
//        case workPhoneNumber
//        case workEmail
        case custom(CustomFieldUiModel?)

        static func == (lhs: Field, rhs: Field) -> Bool {
            if case let .custom(lhsfield) = lhs,
               case let .custom(rhsfield) = rhs {
                lhsfield?.id == rhsfield?.id
            } else {
                lhs.hashValue == rhs.hashValue
            }
        }
    }

    var body: some View {
        mainContainer
            .sheet(isPresented: $sheetState.shouldDisplay) {
                sheetContent
                    .presentationDetents([.height(sheetState.height)])
                    .presentationDragIndicator(.visible)
            }
            .navigationStackEmbeded()
            .onAppear {
                focusedField = .title
            }
    }
}

private extension CreateEditIdentityView {
    var mainContainer: some View {
        LazyVStack(spacing: DesignConstant.sectionPadding) {
            CreateEditItemTitleSection(title: $viewModel.title,
                                       focusedField: $focusedField,
                                       field: .title,
                                       itemContentType: viewModel.itemContentType(),
                                       isEditMode: viewModel.mode.isEditMode,
                                       onSubmit: {})
                .padding(.vertical, DesignConstant.sectionPadding / 2)

            sections()
            PassSectionDivider()

            if viewModel.canAddMoreCustomFields {
                CapsuleLabelButton(icon: IconProvider.plus,
                                   title: "Add a custom section",
                                   titleColor: viewModel.itemContentType().normMajor2Color,
                                   backgroundColor: viewModel.itemContentType().normMinor1Color,
                                   height: 55) {
                    showCustomTitleAlert.toggle()
                }
            } else {
                Button { viewModel.upgrade() } label: {
                    Label(title: {
                        Text("Upgrade to add custom sections")
                            .font(.callout)
                            .fontWeight(.medium)
                    }, icon: {
                        Image(uiImage: IconProvider.arrowOutSquare)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 16)
                    })
                    .foregroundStyle(ItemContentType.identity.normMajor2Color.toColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, DesignConstant.sectionPadding)
            }
        }
        .padding(.horizontal, DesignConstant.sectionPadding)
        .padding(.bottom, DesignConstant.sectionPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: viewModel.sections)
        .animation(.default, value: viewModel.extraPersonalDetails)
        .animation(.default, value: viewModel.extraWorkDetails)
        .animation(.default, value: viewModel.extraAddressDetails)
        .animation(.default, value: viewModel.extraContactDetails)
        .scrollViewEmbeded(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(PassColor.backgroundNorm.toColor, for: .navigationBar)
        .itemCreateEditSetUp(viewModel)
        .alert("Custom section", isPresented: $showCustomTitleAlert) {
            TextField("Title", text: $viewModel.customSectionTitle)
                .autocorrectionDisabled()
            Button("Add", action: viewModel.addCustomSection)
            Button("Cancel", role: .cancel) { viewModel.reset() }
        } message: {
            Text("Enter a section title")
        }
        .alert("Remove custom section", isPresented: $showDeleteCustomSectionAlert) {
            Button("Delete", role: .destructive, action: viewModel.deleteCustomSection)
            Button("Cancel", role: .cancel) { viewModel.reset() }
        } message: {
            // swiftlint:disable:next line_length
            Text("Are you sure you want to delete the following section \"\(viewModel.selectedCustomSection?.title ?? "Unknown")\"?")
        }
        .alert("Modify the section name", isPresented: $showSectionTitleModification) {
            TextField("New title", text: $viewModel.customSectionTitle)
                .autocorrectionDisabled()
            Button("Modify") { viewModel.modifyCustomSectionName() }
            Button("Cancel", role: .cancel) { viewModel.reset() }
        } message: {
            Text("Enter a new section title")
        }
    }

    func addMoreButton(_ action: @escaping () -> Void) -> some View {
        CapsuleLabelButton(icon: IconProvider.plus,
                           title: "Add more",
                           titleColor: viewModel.itemContentType().normMajor2Color,
                           backgroundColor: viewModel.itemContentType().normMinor1Color,
                           fontWeight: .medium,
                           maxWidth: 140,
                           action: action)
    }
}

private extension CreateEditIdentityView {
    func sections() -> some View {
        ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
            Section(content: {
                switch section.id {
                case BaseIdentitySection.personalDetails.rawValue:
                    if !section.isCollapsed {
                        personalDetailSection(section)
                    }
                case BaseIdentitySection.address.rawValue:
                    if !section.isCollapsed {
                        addressDetailSection(section)
                    }
                case BaseIdentitySection.contact.rawValue:
                    if !section.isCollapsed {
                        contactDetailSection(section)
                    }
                case BaseIdentitySection.workDetail.rawValue:
                    if !section.isCollapsed {
                        workDetailSection(section)
                    }
                default:
                    if !section.isCollapsed {
                        customDetailSection(section, index: index)
                    }
                }
            }, header: {
                header(for: section)
            })
        }
    }

    func header(for section: CreateEditIdentitySection) -> some View {
        HStack(alignment: .center) {
            Label(title: { Text(section.title) },
                  icon: {
                      Image(systemName: section.isCollapsed ? "chevron.down" : "chevron.up")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 12)
                  })
                  .foregroundStyle(PassColor.textWeak.toColor)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.top, DesignConstant.sectionPadding)
                  .buttonEmbeded {
                      viewModel.toggleCollapsingSection(section)
                  }
            Spacer()

            if section.isCustom {
                Menu(content: {
                    Label(title: { Text("Edit section's title") }, icon: { Image(uiImage: IconProvider.pencil) })
                        .buttonEmbeded {
                            viewModel.setSelectedSection(section: section)
                            showSectionTitleModification.toggle()
                        }

                    Label(title: { Text("Remove section") },
                          icon: { Image(uiImage: IconProvider.crossCircle) })
                        .buttonEmbeded {
                            viewModel.setSelectedSection(section: section)
                            showDeleteCustomSectionAlert.toggle()
                        }
                }, label: {
                    IconProvider.threeDotsVertical
                        .foregroundStyle(PassColor.textWeak.toColor)
                        .padding(.top, DesignConstant.sectionPadding)
                })
            }
        }
    }

    func customDetailSection(_ section: CreateEditIdentitySection, index: Int) -> some View {
        VStack(alignment: .leading) {
            VStack(spacing: DesignConstant.sectionPadding) {
                ForEach(Array(section.content.enumerated()), id: \.element.id) { elementIndex, field in
                    VStack {
                        if elementIndex > 0 {
                            PassSectionDivider()
                        }
                        EditCustomFieldView(focusedField: $focusedField,
                                            field: .custom(field),
                                            contentType: .identity,
                                            uiModel: $viewModel.sections[index].content[elementIndex],
                                            // field,
                                            showIcon: false,
                                            roundedSection: false,
                                            onEditTitle: { viewModel.editCustomFieldTitle(field) },
                                            onRemove: {
                                                // Work around a crash in later versions of iOS 17
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    viewModel.sections[index].content
                                                        .removeAll(where: { $0.id == field.id })
                                                }
                                            })
                    }
                }
            }
            .if(!section.content.isEmpty) { view in
                view.padding(.vertical, DesignConstant.sectionPadding)
            }
            .roundedEditableSection()
            addMoreButton {
                viewModel.addCustomField(to: section)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Personal Detail Section

private extension CreateEditIdentityView {
    func personalDetailSection(_ section: CreateEditIdentitySection) -> some View {
        VStack(alignment: .leading) {
            VStack(spacing: DesignConstant.sectionPadding) {
                if viewModel.firstName.shouldShow {
                    identityRow(title: IdentityFields.firstName.title,
                                value: $viewModel.firstName.value)
                    PassSectionDivider()
                }

                if viewModel.middleName.shouldShow {
                    identityRow(title: IdentityFields.middleName.title,
                                value: $viewModel.middleName.value)
                    PassSectionDivider()
                }

                if viewModel.lastName.shouldShow {
                    identityRow(title: IdentityFields.lastName.title,
                                value: $viewModel.lastName.value)
                    PassSectionDivider()
                }

                identityRow(title: IdentityFields.fullName.title,
                            value: $viewModel.fullName)
                PassSectionDivider()

                identityRow(title: IdentityFields.email.title,
                            value: $viewModel.email,
                            keyboardType: .emailAddress)
                PassSectionDivider()

                identityRow(title: IdentityFields.phoneNumber.title,
                            value: $viewModel.phoneNumber,
                            keyboardType: .phonePad)

                if viewModel.birthdate.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.birthdate.title,
                                value: $viewModel.birthdate.value,
                                keyboardType: .numbersAndPunctuation)
                }

                if viewModel.gender.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.gender.title,
                                value: $viewModel.gender.value)
                }

                ForEach($viewModel.extraPersonalDetails) { $field in
                    PassSectionDivider()
                    EditCustomFieldView(focusedField: $focusedField,
                                        field: .custom(field),
                                        contentType: .identity,
                                        uiModel: $field,
                                        showIcon: false,
                                        roundedSection: false,
                                        onEditTitle: { viewModel.editCustomFieldTitle(field) },
                                        onRemove: {
                                            // Work around a crash in later versions of iOS 17
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                viewModel.extraPersonalDetails
                                                    .removeAll(where: { $0.id == field.id })
                                            }
                                        })
                }
            }
            .padding(.vertical, DesignConstant.sectionPadding)
            .roundedEditableSection()
            addMoreButton {
                sheetState = .personal(section)
            }
        }
    }
}

// MARK: - Address Detail Section

private extension CreateEditIdentityView {
    func addressDetailSection(_ section: CreateEditIdentitySection) -> some View {
        VStack(alignment: .leading) {
            VStack(spacing: DesignConstant.sectionPadding) {
                identityRow(title: IdentityFields.organization.title,
                            value: $viewModel.organization)
                PassSectionDivider()

                identityRow(title: IdentityFields.streetAddress.title,
                            value: $viewModel.streetAddress)
                PassSectionDivider()

                identityRow(title: IdentityFields.zipOrPostalCode.title,
                            value: $viewModel.zipOrPostalCode,
                            keyboardType: .asciiCapableNumberPad)
                PassSectionDivider()

                identityRow(title: IdentityFields.city.title,
                            value: $viewModel.city)
                PassSectionDivider()

                identityRow(title: IdentityFields.stateOrProvince.title,
                            value: $viewModel.stateOrProvince)
                PassSectionDivider()

                identityRow(title: IdentityFields.countryOrRegion.title,
                            value: $viewModel.countryOrRegion)

                if viewModel.floor.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.floor.title,
                                value: $viewModel.floor.value)
                }

                if viewModel.county.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.county.title,
                                value: $viewModel.county.value)
                }

                ForEach($viewModel.extraAddressDetails) { $field in
                    PassSectionDivider()
                    EditCustomFieldView(focusedField: $focusedField,
                                        field: .custom(field),
                                        contentType: .identity,
                                        uiModel: $field,
                                        showIcon: false,
                                        roundedSection: false,
                                        onEditTitle: { viewModel.editCustomFieldTitle(field) },
                                        onRemove: {
                                            // Work around a crash in later versions of iOS 17
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                viewModel.extraAddressDetails
                                                    .removeAll(where: { $0.id == field.id })
                                            }
                                        })
                }
            }
            .padding(.vertical, DesignConstant.sectionPadding)
            .roundedEditableSection()
            addMoreButton {
                sheetState = .address(section)
            }
        }
    }
}

// MARK: - Contact Detail Section

private extension CreateEditIdentityView {
    func contactDetailSection(_ section: CreateEditIdentitySection) -> some View {
        VStack(alignment: .leading) {
            VStack(spacing: DesignConstant.sectionPadding) {
                identityRow(title: IdentityFields.socialSecurityNumber.title,
                            value: $viewModel.socialSecurityNumber)
                PassSectionDivider()

                identityRow(title: IdentityFields.passportNumber.title,
                            value: $viewModel.passportNumber)
                PassSectionDivider()

                identityRow(title: IdentityFields.licenseNumber.title,
                            value: $viewModel.licenseNumber)
                PassSectionDivider()

                identityRow(title: IdentityFields.website.title,
                            value: $viewModel.website)
                PassSectionDivider()

                identityRow(title: IdentityFields.xHandle.title,
                            value: $viewModel.xHandle)
                PassSectionDivider()

                identityRow(title: IdentityFields.secondPhoneNumber.title,
                            value: $viewModel.secondPhoneNumber,
                            keyboardType: .phonePad)

                if viewModel.linkedIn.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.linkedIn.title,
                                value: $viewModel.linkedIn.value)
                }

                if viewModel.reddit.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.reddit.title,
                                value: $viewModel.reddit.value)
                }

                if viewModel.facebook.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.facebook.title,
                                value: $viewModel.facebook.value)
                }

                if viewModel.yahoo.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.yahoo.title,
                                value: $viewModel.yahoo.value)
                }

                if viewModel.instagram.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.instagram.title,
                                value: $viewModel.instagram.value)
                }

                ForEach($viewModel.extraContactDetails) { $field in
                    PassSectionDivider()
                    EditCustomFieldView(focusedField: $focusedField,
                                        field: .custom(field),
                                        contentType: .identity,
                                        uiModel: $field,
                                        showIcon: false,
                                        roundedSection: false,
                                        onEditTitle: { viewModel.editCustomFieldTitle(field) },
                                        onRemove: {
                                            // Work around a crash in later versions of iOS 17
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                viewModel.extraContactDetails
                                                    .removeAll(where: { $0.id == field.id })
                                            }
                                        })
                }
            }
            .padding(.vertical, DesignConstant.sectionPadding)
            .roundedEditableSection()
            addMoreButton {
                sheetState = .contact(section)
            }
        }
    }
}

// MARK: - Work Detail Section

private extension CreateEditIdentityView {
    func workDetailSection(_ section: CreateEditIdentitySection) -> some View {
        VStack(alignment: .leading) {
            VStack(spacing: DesignConstant.sectionPadding) {
                identityRow(title: IdentityFields.company.title,
                            value: $viewModel.company)
                PassSectionDivider()

                identityRow(title: IdentityFields.jobTitle.title,
                            value: $viewModel.jobTitle)

                if viewModel.personalWebsite.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.personalWebsite.title,
                                value: $viewModel.personalWebsite.value)
                }

                if viewModel.workPhoneNumber.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.workPhoneNumber.title,
                                value: $viewModel.workPhoneNumber.value,
                                keyboardType: .namePhonePad)
                }

                if viewModel.workEmail.shouldShow {
                    PassSectionDivider()
                    identityRow(title: IdentityFields.workEmail.title,
                                value: $viewModel.workEmail.value)
                }

                ForEach($viewModel.extraWorkDetails) { $field in
                    PassSectionDivider()
                    EditCustomFieldView(focusedField: $focusedField,
                                        field: .custom(field),
                                        contentType: .identity,
                                        uiModel: $field,
                                        showIcon: false,
                                        roundedSection: false,
                                        onEditTitle: { viewModel.editCustomFieldTitle(field) },
                                        onRemove: {
                                            // Work around a crash in later versions of iOS 17
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                viewModel.extraWorkDetails
                                                    .removeAll(where: { $0.id == field.id })
                                            }
                                        })
                }
            }
            .padding(.vertical, DesignConstant.sectionPadding)
            .roundedEditableSection()
            addMoreButton {
                sheetState = .work(section)
            }
        }
    }
}

// MARK: - Utils

private extension CreateEditIdentityView {
    func identityRow(title: String,
                     subtitle: String? = nil,
                     value: Binding<String>,
                     focusedField: Field? = nil,
                     keyboardType: UIKeyboardType = .asciiCapable) -> some View {
        HStack(spacing: DesignConstant.sectionPadding) {
            VStack(alignment: .leading, spacing: DesignConstant.sectionPadding / 4) {
                Text(title)
                    .sectionTitleText()

                TextField(subtitle ?? title, text: value)
                    .textInputAutocapitalization(.never)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: focusedField)
                    .foregroundStyle(PassColor.textNorm.toColor)
                    .submitLabel(.next)
                    // swiftlint:disable:next todo
                    // TODO: set next focus
                    .onSubmit {}
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !value.wrappedValue.isEmpty {
                Button(action: {
                    value.wrappedValue = ""
                }, label: {
                    ItemDetailSectionIcon(icon: IconProvider.cross)
                })
            }
        }
        .padding(.horizontal, DesignConstant.sectionPadding)
        .animation(.default, value: focusedField)
    }

    var sheetContent: some View {
        VStack {
            Text("Add field")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(PassColor.textWeak.toColor)
                .frame(maxWidth: .infinity)
                .padding(.top, DesignConstant.sectionPadding)

            if let title = sheetState.title {
                Text(title)
                    .foregroundStyle(PassColor.textNorm.toColor)
                    .frame(maxWidth: .infinity)
            }

            switch sheetState {
            case .personal:
                sheetOption("First name", value: $viewModel.firstName)
                PassSectionDivider()

                sheetOption("Middle name", value: $viewModel.middleName)
                PassSectionDivider()

                sheetOption("Last name", value: $viewModel.lastName)
                PassSectionDivider()

                sheetOption("Birthdate", value: $viewModel.birthdate)
                PassSectionDivider()

                sheetOption("Gender", value: $viewModel.gender)
                PassSectionDivider()

            case .address:
                sheetOption("Floor", value: $viewModel.floor)
                PassSectionDivider()

                sheetOption("County", value: $viewModel.county)
                PassSectionDivider()

            case .contact:
                sheetOption("LinkedIn", value: $viewModel.linkedIn)
                PassSectionDivider()

                sheetOption("Reddit", value: $viewModel.reddit)
                PassSectionDivider()

                sheetOption("Facebook", value: $viewModel.facebook)
                PassSectionDivider()

                sheetOption("Yahoo", value: $viewModel.yahoo)
                PassSectionDivider()

                sheetOption("Instagram", value: $viewModel.instagram)
                PassSectionDivider()

            case .work:
                sheetOption("Personal website", value: $viewModel.personalWebsite)
                PassSectionDivider()

                sheetOption("Work phone number", value: $viewModel.workPhoneNumber)
                PassSectionDivider()

                sheetOption("Work email", value: $viewModel.workEmail)
                PassSectionDivider()

            default:
                EmptyView()
            }
            if viewModel.canAddMoreCustomFields {
                Text("Custom field")
                    .foregroundStyle(PassColor.textNorm.toColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignConstant.sectionPadding)
                    .buttonEmbeded {
                        if let section = sheetState.section {
                            viewModel.addCustomField(to: section)
                        }
                    }
            } else {
                Button { viewModel.upgrade() } label: {
                    Label(title: {
                        Text("Upgrade to add custom fields")
                            .font(.callout)
                            .fontWeight(.medium)
                    }, icon: {
                        Image(uiImage: IconProvider.arrowOutSquare)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 16)
                    })
                    .foregroundStyle(ItemContentType.identity.normMajor2Color.toColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, DesignConstant.sectionPadding)
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, DesignConstant.sectionPadding)
        .background(PassColor.backgroundNorm.toColor)
    }

    func sheetOption(_ title: LocalizedStringKey,
                     value: Binding<HiddenStringValue>) -> some View {
        Text(title)
            .foregroundStyle(PassColor.textNorm.toColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, DesignConstant.sectionPadding)
            .buttonEmbeded { value.wrappedValue.shouldShow.toggle() }
            .disabled(value.wrappedValue.shouldShow)
    }
}

// swiftlint:enable file_length
