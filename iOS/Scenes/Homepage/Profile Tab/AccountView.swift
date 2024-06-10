//
// AccountView.swift
// Proton Pass - Created on 30/03/2023.
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

import DesignSystem
import Macro
import ProtonCoreAccountRecovery
import ProtonCoreUIFoundations
import SwiftUI

struct AccountView: View {
    @State private var isShowingSignOutConfirmation = false
    @StateObject var viewModel: AccountViewModel
    @State private var showDisableExtraPasswordAlert = false

    var body: some View {
        if viewModel.isShownAsSheet {
            NavigationStack {
                realBody
            }
        } else {
            realBody
        }
    }

    @ViewBuilder
    private var realBody: some View {
        ScrollView {
            VStack {
                VStack(spacing: 0) {
                    OptionRow(title: #localized("Username"),
                              height: .tall,
                              content: {
                                  Text(viewModel.username)
                                      .foregroundStyle(PassColor.textNorm.toColor)
                              })

                    if let plan = viewModel.plan {
                        PassSectionDivider()

                        OptionRow(title: #localized("Subscription plan"),
                                  height: .tall,
                                  content: {
                                      Text(plan.displayName)
                                          .foregroundStyle(PassColor.textNorm.toColor)
                                  })
                    }
                }
                .roundedEditableSection()

                if viewModel.canChangePassword {
                    VStack(spacing: 0) {
                        OptionRow(action: { viewModel.openChangeUserPassword() },
                                  height: .tall,
                                  content: {
                                      Text("Change password")
                                          .foregroundStyle(PassColor.textNorm.toColor)
                                  },
                                  trailing: { ChevronRight() })

                        if viewModel.canChangeMailboxPassword {
                            PassSectionDivider()

                            OptionRow(action: { viewModel.openChangeMailboxPassword() },
                                      height: .tall,
                                      content: {
                                          Text("Change mailbox password")
                                              .foregroundStyle(PassColor.textNorm.toColor)
                                      },
                                      trailing: { ChevronRight() })
                        }
                    }
                    .roundedEditableSection()
                    .padding(.top)
                }

                VStack(spacing: 0) {
                    OptionRow(action: { viewModel.openAccountSettings() },
                              height: .tall,
                              content: {
                                  Text("Manage account")
                                      .foregroundStyle(PassColor.interactionNormMajor2.toColor)
                              },
                              trailing: {
                                  CircleButton(icon: IconProvider.arrowOutSquare,
                                               iconColor: PassColor.interactionNormMajor2,
                                               backgroundColor: PassColor.interactionNormMinor1)
                              })

                    PassSectionDivider()

                    OptionRow(action: { viewModel.manageSubscription() },
                              height: .tall,
                              content: {
                                  Text("Manage subscription")
                                      .foregroundStyle(PassColor.interactionNormMajor2.toColor)
                              },
                              trailing: {
                                  CircleButton(icon: IconProvider.arrowOutSquare,
                                               iconColor: PassColor.interactionNormMajor2,
                                               backgroundColor: PassColor.interactionNormMinor1)
                              })
                }
                .roundedEditableSection()
                .padding(.top)

                if let accountRecovery = viewModel.accountRecovery, accountRecovery.shouldShowSettingsItem {
                    OptionRow(action: { viewModel.openAccountRecovery() },
                              height: .tall,
                              content: {
                                  HStack {
                                      Text(AccountRecoveryModule.settingsItem)
                                      Spacer()
                                      Text(accountRecovery.valueForSettingsItem)
                                  }.foregroundStyle(PassColor.interactionNormMajor2.toColor)
                              },
                              trailing: {
                                  if let image = accountRecovery.imageForSettingsItem {
                                      CircleButton(icon: image,
                                                   iconColor: PassColor.interactionNormMajor2,
                                                   backgroundColor: PassColor.interactionNormMinor1)
                                  }
                              })
                              .roundedEditableSection()
                              .padding(.vertical)
                }

                if viewModel.extraPasswordSupported {
                    if viewModel.extraPasswordEnabled {
                        extraPasswordEnabledRow
                    } else {
                        extraPasswordDisabledRow
                    }
                    // swiftlint:disable:next line_length
                    Text(verbatim: "The extra password will be required to use Pass. It acts as an additional password on top of your Proton password.")
                        .sectionTitleText()
                }

                OptionRow(action: { isShowingSignOutConfirmation.toggle() },
                          height: .tall,
                          content: {
                              Text("Sign out")
                                  .foregroundStyle(PassColor.interactionNormMajor2.toColor)
                          },
                          trailing: {
                              CircleButton(icon: IconProvider.arrowOutFromRectangle,
                                           iconColor: PassColor.interactionNormMajor2,
                                           backgroundColor: PassColor.interactionNormMinor1)
                          })
                          .roundedEditableSection()
                          .padding(.vertical)

                OptionRow(action: { viewModel.deleteAccount() },
                          height: .tall,
                          content: {
                              Text("Delete account")
                                  .foregroundStyle(PassColor.signalDanger.toColor)
                          },
                          trailing: {
                              CircleButton(icon: IconProvider.trash,
                                           iconColor: PassColor.signalDanger,
                                           backgroundColor: PassColor.passwordInteractionNormMinor1)
                          })
                          .roundedEditableSection()

                // swiftlint:disable:next line_length
                Text("This will permanently delete your Proton account and all of its data, including email, calendars and data stored in Drive. You will not be able to reactivate this account.")
                    .sectionTitleText()

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .animation(.default, value: viewModel.plan)
            .animation(.default, value: viewModel.extraPasswordEnabled)
        }
        .navigationTitle("Account")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.large)
        .background(PassColor.backgroundNorm.toColor)
        .toolbar { toolbarContent }
        .showSpinner(viewModel.isLoading)
        .alert("Enter your extra password",
               isPresented: $showDisableExtraPasswordAlert,
               actions: {
                   SecureField("Extra password", text: $viewModel.extraPassword)
                   Button(role: .destructive,
                          action: { viewModel.disableExtraPassword() },
                          label: { Text("Remove extra password") })
                   Button(role: .cancel, label: { Text("Cancel") })
               })
        .alert("You will be signed out",
               isPresented: $isShowingSignOutConfirmation,
               actions: {
                   Button(role: .destructive,
                          action: { viewModel.signOut() },
                          label: { Text("Yes, sign me out") })

                   Button(role: .cancel, label: { Text("Cancel") })
               })
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            CircleButton(icon: viewModel.isShownAsSheet ? IconProvider.chevronDown : IconProvider.chevronLeft,
                         iconColor: PassColor.interactionNormMajor2,
                         backgroundColor: PassColor.interactionNormMinor1,
                         accessibilityLabel: viewModel.isShownAsSheet ? "Close" : "Go back",
                         action: { viewModel.goBack() })
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.plan?.hideUpgrade == false {
                CapsuleLabelButton(icon: PassIcon.brandPass,
                                   title: #localized("Upgrade"),
                                   titleColor: ColorProvider.TextInverted,
                                   backgroundColor: PassColor.interactionNormMajor2,
                                   action: { viewModel.upgradeSubscription() })
            } else {
                EmptyView()
            }
        }
    }
}

private extension AccountView {
    var extraPasswordDisabledRow: some View {
        OptionRow(action: { viewModel.enableExtraPassword() },
                  height: .tall,
                  content: {
                      Text(verbatim: "Set extra password for Proton Pass")
                          .foregroundStyle(PassColor.interactionNormMajor2.toColor)
                  })
                  .roundedEditableSection()
                  .padding(.top)
    }

    var extraPasswordEnabledRow: some View {
        OptionRow(height: .tall,
                  content: {
                      VStack(alignment: .leading) {
                          Text(verbatim: "Extra password for Proton Pass")
                              .foregroundStyle(PassColor.textNorm.toColor)
                          Text("Active")
                              .font(.callout)
                              .foregroundStyle(PassColor.cardInteractionNormMajor1.toColor)
                      }
                  },
                  trailing: {
                      Menu(content: {
                          Button(role: .destructive,
                                 action: { showDisableExtraPasswordAlert.toggle() },
                                 label: { Text("Remove") })
                      }, label: {
                          Image(uiImage: IconProvider.threeDotsVertical)
                              .resizable()
                              .scaledToFit()
                              .foregroundStyle(PassColor.textWeak.toColor)
                              .frame(width: 24)
                      })
                  })
                  .roundedEditableSection()
                  .padding(.top)
    }
}
