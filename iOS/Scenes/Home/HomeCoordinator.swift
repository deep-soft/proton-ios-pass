//
// HomeCoordinator.swift
// Proton Pass - Created on 02/07/2022.
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
import Combine
import Core
import CoreData
import CryptoKit
import MBProgressHUD
import ProtonCore_Login
import ProtonCore_Services
import SideMenuSwift
import SwiftUI
import UIComponents
import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorDidSignOut()
}

// swiftlint:disable:next todo
// TODO: Make width dynamic based on screen orientation
private let kMenuWidth = UIScreen.main.bounds.width * 4 / 5

final class HomeCoordinator: DeinitPrintable {
    deinit { print(deinitMessage) }

    private let sessionData: SessionData
    private let apiService: APIService
    private let symmetricKey: SymmetricKey
    private let shareRepository: ShareRepositoryProtocol
    private let vaultItemKeysRepository: VaultItemKeysRepositoryProtocol
    private let itemRepository: ItemRepositoryProtocol
    private let aliasRepository: AliasRepositoryProtocol
    private let publicKeyRepository: PublicKeyRepositoryProtocol
    private let credentialRepository: CredentialRepositoryProtocol
    weak var delegate: HomeCoordinatorDelegate?

    var rootViewController: UIViewController { sideMenuController }

    private lazy var sideMenuController: SideMenuController = {
        let sideMenuController = SideMenuController(contentViewController: myVaultsRootViewController,
                                                    menuViewController: sidebarViewController)
        return sideMenuController
    }()

    private var topMostViewController: UIViewController {
        sideMenuController.presentedViewController ?? sideMenuController
    }

    private lazy var sidebarViewController: UIViewController = {
        let sideBarViewModel = SideBarViewModel(user: sessionData.userData.user)
        sideBarViewModel.delegate = self
        let sidebarView = SidebarView(viewModel: sideBarViewModel, width: kMenuWidth)
        return UIHostingController(rootView: sidebarView)
    }()

    // My vaults
    let vaultSelection: VaultSelection

    private lazy var myVaultsCoordinator: MyVaultsCoordinator = {
        let myVaultsCoordinator = MyVaultsCoordinator(symmetricKey: symmetricKey,
                                                      userData: sessionData.userData,
                                                      vaultSelection: vaultSelection,
                                                      shareRepository: shareRepository,
                                                      vaultItemKeysRepository: vaultItemKeysRepository,
                                                      itemRepository: itemRepository,
                                                      aliasRepository: aliasRepository,
                                                      credentialRepository: credentialRepository,
                                                      publicKeyRepository: publicKeyRepository)
        myVaultsCoordinator.delegate = self
        myVaultsCoordinator.onTrashedItem = { [unowned self] in
            self.trashCoordinator.refreshTrashedItems()
        }
        return myVaultsCoordinator
    }()

    private var myVaultsRootViewController: UIViewController { myVaultsCoordinator.rootViewController }

    // Settings
    private lazy var settingsCoordinator: SettingsCoordinator = {
        let credentialRepository = CredentialRepository(itemRepository: itemRepository,
                                                        credentialIdentityStore: .shared,
                                                        symmetricKey: symmetricKey)
        let settingsCoordinator = SettingsCoordinator(credentialRepository: credentialRepository)
        settingsCoordinator.delegate = self
        return settingsCoordinator
    }()

    private var settingsRootViewController: UIViewController { settingsCoordinator.rootViewController }

    // Trash
    private lazy var trashCoordinator: TrashCoordinator = {
        let trashCoordinator = TrashCoordinator(symmetricKey: symmetricKey,
                                                shareRepository: shareRepository,
                                                itemRepository: itemRepository)
        trashCoordinator.delegate = self
        trashCoordinator.onRestoredItem = { [unowned self] in
            self.myVaultsCoordinator.refreshItems()
        }
        return trashCoordinator
    }()

    private var trashRootViewController: UIViewController { trashCoordinator.rootViewController }

    private var cancellables = Set<AnyCancellable>()

    init(sessionData: SessionData,
         apiService: APIService,
         symmetricKey: SymmetricKey,
         container: NSPersistentContainer) {
        self.sessionData = sessionData
        self.apiService = apiService
        self.symmetricKey = symmetricKey

        let userId = sessionData.userData.user.ID
        let authCredential = sessionData.userData.credential

        let itemRepository = ItemRepository(userData: sessionData.userData,
                                            symmetricKey: symmetricKey,
                                            container: container,
                                            apiService: apiService)
        self.itemRepository = itemRepository
        self.aliasRepository = AliasRepository(authCredential: authCredential, apiService: apiService)
        self.publicKeyRepository = PublicKeyRepository(container: container,
                                                       apiService: apiService)
        self.shareRepository = ShareRepository(userId: userId,
                                               container: container,
                                               authCredential: authCredential,
                                               apiService: apiService)
        self.vaultItemKeysRepository = VaultItemKeysRepository(container: container,
                                                               authCredential: authCredential,
                                                               apiService: apiService)
        self.credentialRepository = CredentialRepository(itemRepository: itemRepository,
                                                         credentialIdentityStore: .shared,
                                                         symmetricKey: symmetricKey)
        self.vaultSelection = .init(vaults: [])
        self.setUpSideMenuPreferences()
        self.observeVaultSelection()
    }

    private func setUpSideMenuPreferences() {
        SideMenuController.preferences.basic.menuWidth = kMenuWidth
        SideMenuController.preferences.basic.position = .sideBySide
        SideMenuController.preferences.basic.enablePanGesture = true
        SideMenuController.preferences.basic.enableRubberEffectWhenPanning = false
        SideMenuController.preferences.animation.shouldAddShadowWhenRevealing = true
        SideMenuController.preferences.animation.shadowColor = .black
        SideMenuController.preferences.animation.shadowAlpha = 0.52
        SideMenuController.preferences.animation.revealDuration = 0.25
        SideMenuController.preferences.animation.hideDuration = 0.25
    }

    private func observeVaultSelection() {
        vaultSelection.$selectedVault
            .sink { [unowned self] _ in
                self.showMyVaultsRootViewController()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Sidebar
extension HomeCoordinator {
    func showSidebar() {
        sideMenuController.revealMenu()
    }

    private func showMyVaultsRootViewController() {
        sideMenuController.setContentViewController(to: myVaultsRootViewController,
                                                    animated: true) { [unowned self] in
            self.sideMenuController.hideMenu()
        }
    }

    func handleSidebarItem(_ sidebarItem: SidebarItem) {
        switch sidebarItem {
        case .home:
            showMyVaultsRootViewController()
        case .settings:
            sideMenuController.setContentViewController(to: settingsRootViewController,
                                                        animated: true) { [unowned self] in
                self.sideMenuController.hideMenu()
            }
        case .trash:
            sideMenuController.setContentViewController(to: trashRootViewController,
                                                        animated: true) { [unowned self] in
                self.sideMenuController.hideMenu()
            }
        case .help:
            break
        case .signOut:
            requestSignOutConfirmation()
        }
    }

    func showUserSwitcher() {
        print(#function)
    }

    func alert(error: Error) {
        let alert = PPAlertController(title: "Error occured",
                                      message: error.messageForTheUser,
                                      preferredStyle: .alert)
        alert.addAction(.cancel)
        topMostViewController.present(alert, animated: true)
    }
}

// MARK: - Sign out
extension HomeCoordinator {
    private func requestSignOutConfirmation() {
        let alert = PPAlertController(title: "You will be signed out",
                                      message: "All associated data will be deleted. Please confirm.",
                                      preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "Yes, sign me out", style: .destructive) { [unowned self] _ in
            self.signOut()
        }
        alert.addAction(signOutAction)
        alert.addAction(.cancel)
        sideMenuController.present(alert, animated: true)
    }

    private func signOut() {
        Task { @MainActor in
            do {
                try await credentialRepository.removeAllCredentials()
                delegate?.homeCoordinatorDidSignOut()
            } catch {
                alert(error: error)
            }
        }
    }

    private func showLoadingHud() {
        MBProgressHUD.showAdded(to: topMostViewController.view, animated: true)
    }

    private func hideLoadingHud() {
        MBProgressHUD.hide(for: topMostViewController.view, animated: true)
    }
}

// MARK: - SideBarViewModelDelegate
extension HomeCoordinator: SideBarViewModelDelegate {
    func sideBarViewModelWantsToShowUsersSwitcher() {
        showUserSwitcher()
    }

    func sideBarViewModelWantsToHandleItem(_ item: SidebarItem) {
        handleSidebarItem(item)
    }
}

// MARK: - CoordinatorDelegate
extension HomeCoordinator: CoordinatorDelegate {
    func coordinatorWantsToToggleSidebar() {
        showSidebar()
    }

    func coordinatorWantsToShowLoadingHud() {
        showLoadingHud()
    }

    func coordinatorWantsToHideLoadingHud() {
        hideLoadingHud()
    }

    func coordinatorWantsToAlertError(_ error: Error) {
        alert(error: error)
    }
}
