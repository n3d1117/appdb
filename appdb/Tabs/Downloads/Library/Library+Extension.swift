//
//  Library+Extension.swift
//  appdb
//
//  Created by ned on 02/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

extension Library {

    // MARK: - Reload footer views

    internal func reloadFooterView(section: Section) {
        if let footer = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: section.rawValue)) as? LibrarySectionFooterView {
            switch section {
            case .local:
                if localIpas.isEmpty {
                    footer.configure("No Local IPAs Found".localized(), secondaryText: "Use iTunes File Sharing or import them from other apps".localized())
                } else {
                    footer.configure("")
                }
            case .myappstore:
                if myAppstoreIpas.isEmpty {
                    footer.configure("No MyAppStore apps".localized(), secondaryText: "This is your personal IPA library! Apps you upload over time will appear here".localized())
                } else {
                    footer.configure("")
                }
            }
        }
    }

    // MARK: - Register cells

    internal func registerCells() {
        // Header
        collectionView.register(LibrarySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "librarySectionHeaderViewOne")
        collectionView.register(LibrarySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "librarySectionHeaderViewTwo")

        // Footer
        collectionView.register(LibrarySectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "librarySectionFooterViewOne")
        collectionView.register(LibrarySectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "librarySectionFooterViewTwo")

        // Cells
        collectionView.register(MyAppStoreCell.self, forCellWithReuseIdentifier: "myappstorecell")
        collectionView.register(LocalIPACell.self, forCellWithReuseIdentifier: "localipacell")
    }

    // MARK: - Add to MyAppStore

    internal func addToMyAppStore(ipa: LocalIPAFile, indexPath: IndexPath) {
        guard Preferences.deviceIsLinked else {
            Messages.shared.showError(message: "Please authorize app from Settings first".localized())
            return
        }

        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LocalIPACell else { return }

        DispatchQueue.main.async {
            cell.updateText("Waiting...".localized())
        }

        func upload(filename: String) {

            delay(0.3) {

                let randomString = Global.randomString(length: 30)
                guard let jobId = SHA1.hexString(from: randomString)?.replacingOccurrences(of: " ", with: "").lowercased() else { return }
                let url = IPAFileManager.shared.urlFromFilename(filename: filename)

                self.uploadBackgroundTask = BackgroundTaskUtil()
                self.uploadBackgroundTask?.start()

                guard let ipa = self.localIpas.first(where: { $0.filename == filename }), let index = self.localIpas.firstIndex(of: ipa) else { return }
                let newIndex = IndexPath(row: index, section: 0)

                API.addToMyAppStore(jobId: jobId, fileURL: url, request: { [weak self] req in
                    guard let self = self else { return }

                    self.uploadRequestsAtIndex[newIndex] = LocalIPAUploadUtil(req)
                    self.collectionView.reloadItems(at: [newIndex])
                }, completion: { [weak self] error in
                    guard let self = self else { return }

                    self.uploadRequestsAtIndex.removeValue(forKey: indexPath)
                    self.collectionView.reloadItems(at: [indexPath])

                    if let error = error {
                        Messages.shared.showError(message: error.prettified)
                        self.uploadBackgroundTask = nil
                    } else {
                        delay(1) {
                            API.analyzeJob(jobId: jobId, completion: { [weak self] error in
                                guard let self = self else { return }

                                self.uploadBackgroundTask = nil
                                if let error = error {
                                    Messages.shared.showError(message: error.prettified)
                                } else {
                                    if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }
                                    Messages.shared.showSuccess(message: "File uploaded successfully".localized())
                                }
                            })
                        }
                    }
                })
            }
        }

        if Preferences.changeBundleBeforeUpload {

            delay(0.1) {
                guard let bundleId = IPAFileManager.shared.getBundleId(from: ipa) else { return }

                let vc = AskBundleBeforeUploadViewController(originalBundleId: bundleId)
                let nav = AskBundleBeforeUploadNavController(rootViewController: vc)

                let segue = Messages.shared.generateModalSegue(vc: nav, source: self, trackKeyboard: true)
                segue.perform()

                // If vc.cancelled is true, modal was dismissed either through 'Cancel' button or background tap
                segue.eventListeners.append { event in
                    if case .didHide = event, vc.cancelled {
                        cell.updateText(ipa.size)
                    }
                }

                vc.onCompletion = { (newBundleId: String, overwriteFile: Bool) in

                    if newBundleId == bundleId {
                        upload(filename: ipa.filename)
                    } else {

                        // change bundle id, save file and then upload
                        DispatchQueue.main.async {
                            cell.updateText("Changing bundle id...".localized())
                        }

                        delay(0.2) {
                            cell.updateText(ipa.size)
                            if let filename = IPAFileManager.shared.changeBundleId(for: ipa, from: bundleId, to: newBundleId, overwriteFile: overwriteFile) {
                                upload(filename: filename)
                            }
                        }
                    }
                }
            }
        } else {
            upload(filename: ipa.filename)
        }
    }

    // MARK: - Custom install

    internal func customInstall(ipa: LocalIPAFile, indexPath: IndexPath) {

        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LocalIPACell else { return }

        DispatchQueue.main.async {
            cell.updateText("Waiting...".localized())
        }

        delay(0.3) {

            IPAFileManager.shared.startServer()
            let link = IPAFileManager.shared.getIpaLocalUrl(from: ipa)

            if Preferences.deviceIsLinked {

                let queue = DispatchQueue(label: "it.ned.custom_install_\(Global.randomString(length: 5))", attributes: .concurrent)

                queue.async {

                    guard let plist = IPAFileManager.shared.base64ToJSONInfoPlist(from: ipa) else {
                        DispatchQueue.main.async {
                            cell.updateText(ipa.size)
                            IPAFileManager.shared.stopServer()
                        }
                        return
                    }

                    API.requestInstallJB(plist: plist, icon: " ", link: link, completion: { error in
                        DispatchQueue.main.async {
                            cell.updateText(ipa.size)
                            if let error = error {
                                Messages.shared.showError(message: error.prettified)
                                IPAFileManager.shared.stopServer()
                            } else {
                                // Allowing up to 3 mins for app to install...
                                delay(180) { IPAFileManager.shared.stopServer() }
                            }
                        }
                    })
                }
            } else {

                // Install ipa without signing and without appdb, using itms-services directly

                guard let bundleId = IPAFileManager.shared.getBundleId(from: ipa) else { return }

                API.getPlistFromItmsHelper(bundleId: bundleId, localIpaUrlString: link, title: ipa.filename, completion: { plistUrlString in
                    if let plistUrlString = plistUrlString {
                        if let url = URL(string: "itms-services://?action=download-manifest&url=\(plistUrlString)") {
                            UIApplication.shared.open(url)
                            cell.updateText(ipa.size)
                            // Allowing up to 3 mins for app to install...
                            delay(180) { IPAFileManager.shared.stopServer() }
                        } else {
                            cell.updateText(ipa.size)
                            IPAFileManager.shared.stopServer()
                        }
                    } else {
                        cell.updateText(ipa.size)
                        Messages.shared.showError(message: "Oops! Something went wrong. Please try again later.".localized())
                        IPAFileManager.shared.stopServer()
                    }
                })
            }
        }
    }

    // MARK: - Rename local ipa

    internal func handleRename(for file: LocalIPAFile, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Rename File".localized(), message: nil, preferredStyle: .alert, adaptive: true)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.renameTextChanged), for: .editingChanged)
            textField.placeholder = String(file.filename.dropLast(4))
            textField.text = String(file.filename.dropLast(4))
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let rename = UIAlertAction(title: "OK".localized(), style: .default, handler: { _ in
            guard let text = alert.textFields?[0].text else { return }
            IPAFileManager.shared.rename(file: file, to: text + ".ipa")
            self.loadContent()
        })

        alert.addAction(rename)
        rename.isEnabled = false

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    @objc func renameTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            (alert.actions[1] as UIAlertAction).isEnabled = !(sender.text ?? "").isEmpty
        }
    }

    // MARK: - Install MyAppStore app

    @objc internal func installMyAppStoreApp(sender: RoundedButton) {
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }

        if Preferences.deviceIsLinked {
            setButtonTitle("Requesting...")

            func install(_ additionalOptions: [AdditionalInstallationParameters: Any] = [:]) {
                API.install(id: sender.linkId, type: .myAppstore, additionalOptions: additionalOptions) { [weak self] error in
                    guard let self = self else { return }

                    if let error = error {
                        Messages.shared.showError(message: error.prettified)
                        delay(0.3) { setButtonTitle("Install") }
                    } else {
                        setButtonTitle("Requested")

                        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }

                        Messages.shared.showSuccess(message: "Installation has been queued to your device".localized())

                        ObserveQueuedApps.shared.addApp(type: .myAppstore, linkId: sender.linkId, name: self.myAppstoreIpas[sender.tag].name, image: "", bundleId: self.myAppstoreIpas[sender.tag].bundleId)

                        delay(5) { setButtonTitle("Install") }
                    }
                }
            }

            if Preferences.askForInstallationOptions {
                let vc = AdditionalInstallOptionsViewController()
                let nav = AdditionalInstallOptionsNavController(rootViewController: vc)

                vc.heightDelegate = nav

                let segue = Messages.shared.generateModalSegue(vc: nav, source: self, trackKeyboard: true)

                delay(0.3) {
                    segue.perform()
                }

                // If vc.cancelled is true, modal was dismissed either through 'Cancel' button or background tap
                segue.eventListeners.append { event in
                    if case .didHide = event, vc.cancelled {
                        setButtonTitle("Install")
                    }
                }

                vc.onCompletion = { (patchIap: Bool, enableGameTrainer: Bool, removePlugins: Bool, enablePushNotifications: Bool, duplicateApp: Bool, newId: String, newName: String) in
                    var additionalOptions: [AdditionalInstallationParameters: Any] = [:]
                    if patchIap { additionalOptions[.inApp] = 1 }
                    if enableGameTrainer { additionalOptions[.trainer] = 1 }
                    if removePlugins { additionalOptions[.removePlugins] = 1 }
                    if enablePushNotifications { additionalOptions[.pushNotifications] = 1 }
                    if duplicateApp && !newId.isEmpty { additionalOptions[.alongside] = newId }
                    if !newName.isEmpty { additionalOptions[.name] = newName }
                    install(additionalOptions)
                }
            } else {
                install()
            }
        } else {
            // Install requested but device is not linked
            setButtonTitle("Checking...")
            delay(0.3) {
                Messages.shared.showError(message: "Please authorize app from Settings first".localized())
                setButtonTitle("Install")
            }
        }
    }

    // MARK: - Delete MyAppStore app

    internal func deleteMyAppStoreApp(id: String, indexPath: IndexPath) {
        API.deleteIpa(id: id, completion: { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                Messages.shared.showError(message: error.prettified)
            } else {
                guard self.myAppstoreIpas.indices.contains(indexPath.row) else { return }
                self.myAppstoreIpas.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
                if self.myAppstoreIpas.isEmpty {
                    self.reloadFooterView(section: .myappstore)
                }
            }
        })
    }

    // MARK: - Open in...

    internal func openIn(ipa: LocalIPAFile, indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.documentController = UIDocumentInteractionController(url: IPAFileManager.shared.url(for: ipa))
            self.documentController?.delegate = self
            if let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
                let rect = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
                self.documentController?.presentOpenInMenu(from: rect, in: self.collectionView, animated: true)
            }
        }
    }

    // MARK: - Delete local ipa

    internal func deleteLocalIpa(ipa: LocalIPAFile, indexPath: IndexPath) {
        IPAFileManager.shared.delete(file: ipa)
        localIpas.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        if localIpas.isEmpty {
            reloadFooterView(section: .local)
        }
    }

    internal func deleteAll() {
        guard uploadRequestsAtIndex.isEmpty else {
            Messages.shared.showError(message: "Please cancel any pending uploads before deleting local files".localized())
            return
        }
        for ipa in localIpas {
            IPAFileManager.shared.delete(file: ipa)
        }
        let changes = diff(old: localIpas, new: [])
        collectionView.reload(changes: changes, section: Section.local.rawValue, updateData: {
            localIpas.removeAll()
        }, completion: { _ in
            self.reloadFooterView(section: .local)
        })
    }

    @objc internal func deleteAllFilesConfirmationAlert(sender: UIButton) {
        let onlyOne: Bool = localIpas.count == 1
        let title = onlyOne ? "Delete 1 file?".localized() : "Are you sure you want to delete %@ files?".localizedFormat(String(localIpas.count))
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet, adaptive: true)
        alertController.addAction(UIAlertAction(title: onlyOne ? "Delete".localized() : "Delete all".localized(), style: .destructive) { _ in
            self.deleteAll()
        })
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if let presenter = alertController.popoverPresentationController {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
            presenter.permittedArrowDirections = [.up, .down]
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - ETCollectionViewDelegateWaterfallLayout

extension Library: ETCollectionViewDelegateWaterfallLayout {
    var margin: CGFloat {
        UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : (20 ~~ 15)
    }

    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 18 ~~ 13
        layout.minimumInteritemSpacing = 13 ~~ 8

        // Header
        layout.headerHeight = 25
        layout.headerInset.top = 26 ~~ 21
        layout.headerInset.bottom = 4
        if #available(iOS 11.0, *) {
            layout.headerInset.left = (UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 45 : 2)
            layout.headerInset.right = layout.headerInset.left
        }

        // Section Inset
        layout.sectionInset = UIEdgeInsets(top: 10 ~~ 5, left: margin, bottom: 0, right: margin)

        if Global.isIpad {
            layout.columnCount = 2
        } else {
            layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 1 : 2
        }
        return layout
    }

    var itemDimension: CGFloat {
        if Global.isIpad {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return (view.bounds.width / 2) - margin * 1.5
            } else {
                return (view.bounds.width / 3) - margin * 1.5
            }
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return view.bounds.width - margin * 2
            } else {
                return (view.bounds.width / 2) - margin * 1.5
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterIn section: Int) -> CGFloat {
        if section == Section.local.rawValue {
            return localIpas.isEmpty ? (230 ~~ 180) : 0.1
        } else {
            return myAppstoreIpas.isEmpty ? (230 ~~ 180) : 0.1
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        CGSize(width: itemDimension, height: indexPath.section == Section.myappstore.rawValue ? (68 ~~ 63) : (60 ~~ 55))
    }
}

extension Library: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == Section.local.rawValue {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewOne", for: indexPath) as? LibrarySectionHeaderView else { return UICollectionReusableView() }
                header.configure("Local Files".localized(), showsTrash: true)
                header.trashButton.addTarget(self, action: #selector(deleteAllFilesConfirmationAlert), for: .touchUpInside)
                header.trashButton.isEnabled = !self.localIpas.isEmpty
                header.helpButton.addTarget(self, action: #selector(showHelpLocal), for: .touchUpInside)
                return header
            } else {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewTwo", for: indexPath) as? LibrarySectionHeaderView else { return UICollectionReusableView() }
                header.configure("MyAppStore")
                header.helpButton.addTarget(self, action: #selector(showHelpMyAppStore), for: .touchUpInside)
                return header
            }
        } else if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == Section.local.rawValue {
                return (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionFooterViewOne", for: indexPath) as? LibrarySectionFooterView) ?? UICollectionReusableView()
            } else {
                return (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionFooterViewTwo", for: indexPath) as? LibrarySectionFooterView) ?? UICollectionReusableView()
            }
        }
        return UICollectionReusableView()
    }

    @objc private func showHelpLocal() {
        let message = "Place your local .ipa (or .zip) files in the documents directory, either using iTunes File Sharing, the Files app or import them from other apps.\n\nPath to the documents directory:\n\n%@".localizedFormat(IPAFileManager.shared.documentsDirectoryURL().path)
        let alertController = UIAlertController(title: "Local Files".localized(), message: message, preferredStyle: .alert, adaptive: true)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }

    @objc private func showHelpMyAppStore() {
        let message = "appdb presents MyAppStore - your own AppStore. A brand new custom app installer transformed into your personal IPA library!\n\n• Save your personal apps to appdb\n• Shared across all your devices under the same email\n• Store apps up to 4GB\n• Upload multiple apps at once\n\nTo get started, click on a local IPA and select 'Upload to MyAppStore'".localized()
        let alertController = UIAlertController(title: "MyAppStore", message: message, preferredStyle: .alert, adaptive: true)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }

    internal func setTrashButtonEnabled(enabled: Bool) {
        if let header = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: Section.local.rawValue)) as? LibrarySectionHeaderView {
            header.trashButton.isEnabled = enabled
        }
    }
}

extension Library: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        documentController = nil
    }
}
