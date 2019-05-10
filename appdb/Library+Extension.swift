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
    
    internal func reloadFooterViews() {
        if let localIpasFooter = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: Section.local.rawValue)) as? LibrarySectionFooterView {
            if localIpas.isEmpty {
                localIpasFooter.configure("No Local IPAs Found", secondaryText: "Use iTunes File Sharing or import them from other apps") // todo localize
            } else {
                localIpasFooter.configure("")
            }
        }
        if let myappstoreFooter = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: Section.myappstore.rawValue)) as? LibrarySectionFooterView {
            if myAppstoreIpas.isEmpty {
                myappstoreFooter.configure("No MyAppstore apps", secondaryText: "This is your personal IPA library! Apps you upload over time will appear here") // todo localize
            } else {
                myappstoreFooter.configure("")
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
        collectionView.register(MyAppstoreCell.self, forCellWithReuseIdentifier: "myappstorecell")
        collectionView.register(LocalIPACell.self, forCellWithReuseIdentifier: "localipacell")
    }
    
    // MARK: - Add to MyAppstore
    
    internal func addToMyAppstore(ipa: LocalIPAFile, indexPath: IndexPath) {
        
        guard DeviceInfo.deviceIsLinked else {
            Messages.shared.showError(message: "Please authorize app from Settings first".localized())
            return
        }
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LocalIPACell else { return }        
        cell.updateText("Waiting...") // todo localize
        
        let randomString = Global.randomString(length: 30)
        guard let jobId = SHA1.hexString(from: randomString)?.replacingOccurrences(of: " ", with: "").lowercased() else { return }
        let url = IPAFileManager.shared.url(for: ipa)
        
        uploadBackgroundTask = BackgroundTaskUtil()
        uploadBackgroundTask?.start()
        
        API.addToMyAppstore(jobId: jobId, fileURL: url, request: { req in
            self.uploadRequestsAtIndex[indexPath] = LocalIPAUploadUtil(req)
            self.collectionView.reloadItems(at: [indexPath])
        }, completion: { [unowned self] error in
            
            self.uploadRequestsAtIndex.removeValue(forKey: indexPath)
            self.collectionView.reloadItems(at: [indexPath])
            
            if let error = error {
                Messages.shared.showError(message: error.prettified)
                self.uploadBackgroundTask = nil
            } else {
                delay(0.8) {
                    API.analyzeJob(jobId: jobId, completion: { [unowned self] error in
                        self.uploadBackgroundTask = nil
                        if let error = error {
                            Messages.shared.showError(message: error.prettified)
                        } else {
                            Messages.shared.showSuccess(message: "File uploaded successfully") // todo localize
                        }
                    })
                }
            }
        })
    }
    
    // MARK: - Custom install
    
    internal func customInstall(ipa: LocalIPAFile, indexPath: IndexPath) {
        
        guard DeviceInfo.deviceIsLinked else {
            Messages.shared.showError(message: "Please authorize app from Settings first".localized())
            return
        }
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? LocalIPACell else { return }
        cell.updateText("Waiting...") // todo localize
        
        IPAFileManager.shared.startServer()
        
        guard let plist = IPAFileManager.shared.base64ToJSONInfoPlist(from: ipa) else {
            cell.updateText(ipa.size)
            return
        }
        
        let link = IPAFileManager.shared.getIpaLocalUrl(from: ipa)
        
        API.requestInstallJB(plist: plist, icon: " ", link: link, completion: { error in
            cell.updateText(ipa.size)
            if let error = error {
                Messages.shared.showError(message: error.prettified)
                IPAFileManager.shared.stopServer()
            } else {
                // Allowing up to 3 mins for app to install...
                delay(180) { IPAFileManager.shared.stopServer() }
            }
        })
    }
    
    // MARK: - Rename local ipa
    
    internal func handleRename(for file: LocalIPAFile, at indexPath: IndexPath) {
        // todo localize
        let alert = UIAlertController(title: "Rename File", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.renameTextChanged), for: .editingChanged)
            textField.placeholder = String(file.filename.dropLast(4))
            textField.text = String(file.filename.dropLast(4))
            textField.theme_keyboardAppearance = [.light, .dark]
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
            (alert.actions[1] as UIAlertAction).isEnabled = sender.text != ""
        }
    }
    
    // MARK: - Install MyAppstore app
    
    @objc internal func installMyAppstoreApp(sender: RoundedButton) {
        
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }
        
        if DeviceInfo.deviceIsLinked {
            setButtonTitle("Requesting...") // todo localize
            
            API.install(id: sender.linkId, type: .myAppstore) { error in
                if let error = error {
                    Messages.shared.showError(message: error.prettified)
                    delay(0.3) { setButtonTitle("Install") }
                } else {
                    setButtonTitle("Requested") // todo localize
                    
                    Messages.shared.showSuccess(message: "Installation has been queued to your device!") // todo localize
                    
                    ObserveQueuedApps.shared.addApp(type: .myAppstore, linkId: sender.linkId, name: self.myAppstoreIpas[sender.tag].name, image: "", bundleId: self.myAppstoreIpas[sender.tag].bundleId)
                    
                    delay(5) { setButtonTitle("Install") }
                }
            }
        } else {
            // Install requested but device is not linked
            setButtonTitle("Checking...") // todo localize
            delay(0.3) {
                Messages.shared.showError(message: "Please authorize app from Settings first".localized())
                setButtonTitle("Install")
            }
        }
    }
    
    // MARK: - Delete MyAppstore app
    
    internal func deleteMyAppstoreApp(id: String, indexPath: IndexPath) {
        API.deleteIpa(id: id, completion: { error in
            if let error = error {
                Messages.shared.showError(message: error.prettified)
            } else {
                self.myAppstoreIpas.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
                self.reloadFooterViews()
            }
        })
    }
    
    // MARK: - Open in...

    internal func openIn(ipa: LocalIPAFile, indexPath: IndexPath) {
        self.documentController = UIDocumentInteractionController(url: IPAFileManager.shared.url(for: ipa))
        if let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
            let rect = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
            self.documentController!.presentOpenInMenu(from: rect, in: self.collectionView, animated: true)
            self.documentController = nil
        }
    }
    
    // MARK: - Delete local ipa
    
    internal func deleteLocalIpa(ipa: LocalIPAFile, indexPath: IndexPath) {
        IPAFileManager.shared.delete(file: ipa)
        self.localIpas.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
        self.reloadFooterViews()
    }
    
    internal func deleteAll() {
        guard uploadRequestsAtIndex.isEmpty else {
            Messages.shared.showError(message: "Please cancel any pending uploads before deleting local files") // todo localize
            return
        }
        for ipa in localIpas {
            IPAFileManager.shared.delete(file: ipa)
        }
        let changes = diff(old: localIpas, new: [])
        self.collectionView.reload(changes: changes, section: Section.local.rawValue, updateData: {
            localIpas.removeAll()
            reloadFooterViews()
        })
    }
    
    @objc internal func deleteAllFilesConfirmationAlert(sender: UIButton) {
        let onlyOne: Bool = localIpas.count == 1
        let title = onlyOne ? "Delete 1 file?" : "Are you sure you want to delete \(localIpas.count) files?".localized() // todo localize
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet, blurStyle: Themes.isNight ? .dark : .light)
        alertController.addAction(UIAlertAction(title: onlyOne ? "Delete".localized() : "Delete all".localized(), style: .destructive) { _ in // todo localize
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
        return UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : (20~~15)
    }
    
    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 18~~13
        layout.minimumInteritemSpacing = 13~~8
        
        // Header
        layout.headerHeight = 25
        layout.headerInset.top = 26~~21
        layout.headerInset.bottom = 4
        if #available(iOS 11.0, *) {
            layout.headerInset.left = (UIDevice.current.orientation.isLandscape && Global.hasNotch ? 45 : 2)
            layout.headerInset.right = layout.headerInset.left
        }
        
        // Section Inset
        layout.sectionInset = UIEdgeInsets(top: 10~~5, left: margin, bottom: 0, right: margin)
        
        if Global.isIpad {
            layout.columnCount = 2
        } else {
            layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 1 : 2
        }
        return layout
    }
    
    var itemDimension: CGFloat {
        if Global.isIpad {
            if UIDevice.current.orientation.isPortrait {
                return (view.bounds.width / 2) - margin*1.5
            } else {
                return (view.bounds.width / 3) - margin*1.5
            }
        } else {
            if UIDevice.current.orientation.isPortrait {
                return view.bounds.width - margin*2
            } else {
                return (view.bounds.width / 2) - margin*1.5
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForFooterIn section: Int) -> CGFloat {
        if section == Section.local.rawValue {
            return localIpas.isEmpty ? (230~~180) : 0.1
        } else {
            return myAppstoreIpas.isEmpty ? (230~~180) : 0.1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemDimension, height: indexPath.section == Section.myappstore.rawValue ? (68~~63) : (60~~55))
    }
}

extension Library: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == Section.local.rawValue {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewOne", for: indexPath) as! LibrarySectionHeaderView
                header.configure("Local Files", showsTrash: true) // todo localize
                header.trashButton.addTarget(self, action: #selector(deleteAllFilesConfirmationAlert), for: .touchUpInside)
                header.trashButton.isEnabled = !self.localIpas.isEmpty
                header.helpButton.addTarget(self, action: #selector(showHelpLocal), for: .touchUpInside)
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewTwo", for: indexPath) as! LibrarySectionHeaderView
                header.configure("MyAppstore")
                header.helpButton.addTarget(self, action: #selector(showHelpMyAppstore), for: .touchUpInside)
                return header
            }
        } else if kind == UICollectionView.elementKindSectionFooter {
            if indexPath.section == Section.local.rawValue {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionFooterViewOne", for: indexPath) as! LibrarySectionFooterView
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionFooterViewTwo", for: indexPath) as! LibrarySectionFooterView
            }
        }
        return UICollectionReusableView()
    }
    
    // todo localize
    @objc fileprivate func showHelpLocal() {
        let message = "Place your local .ipa (or .zip) files in the documents directory, either using iTunes File Sharing, the Files app or import them from other apps.\n\nPath to the documents directory:\n\n\(IPAFileManager.shared.documentsDirectoryURL().path)".localized()
        let alertController = UIAlertController(title: "Local Files".localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    // todo localize
    @objc fileprivate func showHelpMyAppstore() {
        let message = "appdb presents MyAppStore - your own AppStore. A brand new custom app installer transformed into your personal IPA library!\n\n• Save your personal apps to appdb\n• Shared across all your devices under the same email\n• Store apps up to 4GB\n• Upload multiple apps at once\n\nTo get started, click on a local IPA and select 'Upload to MyAppstore'".localized()
        let alertController = UIAlertController(title: "MyAppstore".localized(), message: message, preferredStyle: .alert)
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
