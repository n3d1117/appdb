//
//  Library.swift
//  appdb
//
//  Created by ned on 22/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import DeepDiff

class Library: LoadingCollectionView {

    enum Section: Int {
        case local = 0
        case myappstore = 1
    }

    internal var localIpas = [LocalIPAFile]() {
        didSet {
            setTrashButtonEnabled(enabled: !localIpas.isEmpty)
        }
    }
    internal var myAppstoreIpas = [MyAppStoreApp]()
    internal var timer: Timer?
    internal var documentController: UIDocumentInteractionController?
    internal var uploadBackgroundTask: BackgroundTaskUtil?
    internal var uploadRequestsAtIndex: [IndexPath: LocalIPAUploadUtil] = [:]

    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func viewDidLoad() {
        self.hasSegment = true
        super.viewDidLoad()

        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.contentInset.bottom = 25 ~~ 45
        collectionView.delaysContentTouches = false

        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor

        // Register cells
        registerCells()

        state = .hideIndicator

        loadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(loadContent), userInfo: nil, repeats: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
        timer = nil
    }

    @objc internal func loadContent() {
        let newLocalIpas = IPAFileManager.shared.listLocalIpas()
        let localIpaChanges = diff(old: localIpas, new: newLocalIpas)

        collectionView.reload(changes: localIpaChanges, section: Section.local.rawValue, updateData: {
            self.localIpas = newLocalIpas
            self.reloadFooterView(section: .local)
        })

        API.getIpas(success: { [weak self] ipas in
            guard let self = self else { return }

            let myappstoreChanges = diff(old: self.myAppstoreIpas, new: ipas)
            if !self.isDone { self.state = .done(animated: false) }
            self.collectionView.reload(changes: myappstoreChanges, section: Section.myappstore.rawValue, updateData: {
                self.myAppstoreIpas = ipas
                self.reloadFooterView(section: .myappstore)
            })
        }, fail: { [weak self] _ in
            guard let self = self else { return }

            if !self.isDone { self.state = .done(animated: false) }
            self.reloadFooterView(section: .myappstore)
        })
    }

    // MARK: - Orientation change

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if !self.isLoading {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.collectionViewLayout = self.layout
            }
        })
    }

    // MARK: - Collection view delegate

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Section.myappstore.rawValue { return myAppstoreIpas.count }
        return localIpas.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == Section.myappstore.rawValue {
            guard myAppstoreIpas.indices.contains(indexPath.row) else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myappstorecell", for: indexPath) as? MyAppStoreCell else { return UICollectionViewCell() }
            cell.configure(with: myAppstoreIpas[indexPath.row])
            cell.installButton.addTarget(self, action: #selector(installMyAppStoreApp), for: .touchUpInside)
            cell.installButton.tag = indexPath.row
            return cell
        } else {
            guard localIpas.indices.contains(indexPath.row) else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "localipacell", for: indexPath) as? LocalIPACell else { return UICollectionViewCell() }
            if let upload = uploadRequestsAtIndex[indexPath] {
                cell.configureForUpload(with: localIpas[indexPath.row], util: upload)
            } else {
                cell.configure(with: localIpas[indexPath.row])
            }
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.myappstore.rawValue {
            guard self.myAppstoreIpas.indices.contains(indexPath.row) else { return }
            let app = self.myAppstoreIpas[indexPath.row]
            presentOptionsForMyappstoreApp(app, indexPath)
        } else {
            guard self.localIpas.indices.contains(indexPath.row) else { return }
            let ipa = self.localIpas[indexPath.row]
            presentOptionsForLocalIpa(ipa, indexPath)
        }
    }

    private func presentOptionsForMyappstoreApp(_ app: MyAppStoreApp, _ indexPath: IndexPath) {
        let title = app.name
        let message = "\(app.bundleId)\(Global.bulletPoint)\(app.size)\(Global.bulletPoint)\(app.version)" +
                      "\n" + "Uploaded on %@".localizedFormat(app.uploadedAt.unixToDetailedString)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet, adaptive: true)

        alertController.addAction(UIAlertAction(title: "Install".localized(), style: .default) { _ in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? MyAppStoreCell {
                if let button = cell.installButton {
                    self.installMyAppStoreApp(sender: button)
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
            self.deleteMyAppStoreApp(id: app.id.description, indexPath: indexPath)
        })

        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        if let presenter = alertController.popoverPresentationController, let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = self.view
            presenter.sourceRect = collectionView.convert(attributes.frame, to: collectionView.superview)
            presenter.permittedArrowDirections = [.up, .down]
        }

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }

    private func presentOptionsForLocalIpa(_ ipa: LocalIPAFile, _ indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet, adaptive: true)

        if let upload = uploadRequestsAtIndex[indexPath] {
            if !upload.isPaused {
                alertController.addAction(UIAlertAction(title: "Pause".localized(), style: .default) { _ in
                    upload.pause()
                })
            } else {
                alertController.addAction(UIAlertAction(title: "Resume".localized(), style: .default) { _ in
                    upload.resume()
                })
            }
            alertController.addAction(UIAlertAction(title: "Stop".localized(), style: .destructive) { _ in
                upload.stop()
            })
        } else {
            alertController.title = ipa.filename

            alertController.addAction(UIAlertAction(title: "Install without signing".localized(), style: .default) { _ in
                self.customInstall(ipa: ipa, indexPath: indexPath)
            })

            alertController.addAction(UIAlertAction(title: "Upload to MyAppStore".localized(), style: .default) { _ in
                self.addToMyAppStore(ipa: ipa, indexPath: indexPath)
            })

            alertController.addAction(UIAlertAction(title: "Open in...".localized(), style: .default) { _ in
                self.openIn(ipa: ipa, indexPath: indexPath)
            })

            alertController.addAction(UIAlertAction(title: "Rename".localized(), style: .default) { _ in
                self.handleRename(for: ipa, at: indexPath)
            })

            alertController.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in
                self.deleteLocalIpa(ipa: ipa, indexPath: indexPath)
            })
        }

        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        if let presenter = alertController.popoverPresentationController, let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = self.view
            presenter.sourceRect = collectionView.convert(attributes.frame, to: collectionView.superview)
            presenter.permittedArrowDirections = [.up, .down]
        }

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension Library {

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == Section.local.rawValue {

            guard self.localIpas.indices.contains(indexPath.row) else { return nil }
            let ipa = self.localIpas[indexPath.row]

            if let upload = uploadRequestsAtIndex[indexPath] {

                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in

                    var playPauseAction: UIAction!
                    if !upload.isPaused {
                        playPauseAction = UIAction(title: "Pause".localized(), image: UIImage(systemName: "pause.circle")) { _ in
                            upload.pause()
                        }
                    } else {
                        playPauseAction = UIAction(title: "Resume".localized(), image: UIImage(systemName: "play.circle")) { _ in
                            upload.resume()
                        }
                    }
                    let stop = UIAction(title: "Stop".localized(), image: UIImage(systemName: "stop.circle"), attributes: .destructive) { _ in
                        upload.stop()
                    }
                    return UIMenu(title: "", children: [playPauseAction, stop])
                }
            } else {

                return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in

                    let installWithoutSigning = UIAction(title: "Install without signing".localized(), image: UIImage(systemName: "square.and.arrow.down")) { _ in
                        self.customInstall(ipa: ipa, indexPath: indexPath)
                    }

                    let uploadToMyAppstore = UIAction(title: "Upload to MyAppStore".localized(), image: UIImage(systemName: "icloud.and.arrow.up")) { _ in
                        self.addToMyAppStore(ipa: ipa, indexPath: indexPath)
                    }

                    let openIn = UIAction(title: "Open in...".localized(), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                        self.openIn(ipa: ipa, indexPath: indexPath)
                    }

                    let rename = UIAction(title: "Rename".localized(), image: UIImage(systemName: "square.and.pencil")) { _ in
                        self.handleRename(for: ipa, at: indexPath)
                    }

                    let deleteCancel = UIAction(title: "Cancel".localized(), image: UIImage(systemName: "xmark")) { _ in }
                    let deleteConfirmation = UIAction(title: "Delete".localized(), image: UIImage(systemName: "checkmark"), attributes: .destructive) { _ in
                        self.deleteLocalIpa(ipa: ipa, indexPath: indexPath)
                    }

                    let delete = UIMenu(title: "Delete".localized(), image: UIImage(systemName: "trash"), options: .destructive, children: [deleteCancel, deleteConfirmation])

                    return UIMenu(title: ipa.filename, children: [installWithoutSigning, uploadToMyAppstore, openIn, rename, delete])
                }
            }
        } else if indexPath.section == Section.myappstore.rawValue {

            guard self.myAppstoreIpas.indices.contains(indexPath.row) else { return nil }
            let app = self.myAppstoreIpas[indexPath.row]

            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in

                let title = "Uploaded on %@".localizedFormat(app.uploadedAt.unixToDetailedString)

                let install = UIAction(title: "Install".localized(), image: UIImage(systemName: "square.and.arrow.down")) { _ in
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? MyAppStoreCell {
                        if let button = cell.installButton {
                            self.installMyAppStoreApp(sender: button)
                        }
                    }
                }

                let deleteCancel = UIAction(title: "Cancel".localized(), image: UIImage(systemName: "xmark")) { _ in }
                let deleteConfirmation = UIAction(title: "Delete".localized(), image: UIImage(systemName: "checkmark"), attributes: .destructive) { _ in
                    self.deleteMyAppStoreApp(id: app.id.description, indexPath: indexPath)
                }

                let delete = UIMenu(title: "Delete".localized(), image: UIImage(systemName: "trash"), options: .destructive, children: [deleteCancel, deleteConfirmation])

                return UIMenu(title: title, children: [install, delete])
            }
        }
        return nil
    }

    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        if let collectionViewCell = collectionView.cellForItem(at: indexPath) {
            return UITargetedPreview(view: collectionViewCell.contentView, parameters: parameters)
        }
        return nil
    }
}
