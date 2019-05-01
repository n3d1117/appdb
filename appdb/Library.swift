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
    
    fileprivate var localIpas = [LocalIPAFile]()
    fileprivate var myAppstoreIpas = [MyAppstoreApp]()
    fileprivate var timer: Timer? = nil
    fileprivate var documentController: UIDocumentInteractionController?
    fileprivate var uploadBackgroundTask: BackgroundTaskUtil? = nil
    fileprivate var useDiff: Bool = false
    
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
        collectionView.delaysContentTouches = false
        
        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        collectionView.register(LibrarySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "librarySectionHeaderViewOne")
        collectionView.register(LibrarySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "librarySectionHeaderViewTwo")
        collectionView.register(MyAppstoreCell.self, forCellWithReuseIdentifier: "myappstorecell")
        collectionView.register(LocalIPACell.self, forCellWithReuseIdentifier: "localipacell")
        
        state = .loading

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadContent()
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(loadContent), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func loadContent() {
        if useDiff {
            let newLocalIpas = IPAFileManager.shared.listLocalIpas()
            let localIpaChanges = diff(old: localIpas, new: newLocalIpas)
            
            API.getIpas(success: { ipas in
                let myappstoreChanges = diff(old: self.myAppstoreIpas, new: ipas)

                self.collectionView.reload(changes: localIpaChanges, section: Section.local.rawValue, updateData: {
                    self.localIpas = newLocalIpas
                })
                self.collectionView.reload(changes: myappstoreChanges, section: Section.myappstore.rawValue, updateData: {
                    self.myAppstoreIpas = ipas
                })
                
            }) { _ in
                self.collectionView.reload(changes: localIpaChanges, section: Section.local.rawValue, updateData: {
                    self.localIpas = newLocalIpas
                })
            }
            
        } else {
            localIpas = IPAFileManager.shared.listLocalIpas()
            API.getIpas(success: { ipas in
                self.myAppstoreIpas = ipas

                self.state = .done(animated: false)
                self.reloadHeaderViews()
                self.collectionView.reloadData()
                
                self.useDiff = true
                
            }) { _ in }
        }
    }
    
    fileprivate func reloadHeaderViews() {
        if let localIpasHeader = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: Section.local.rawValue)) as? LibrarySectionHeaderView {
            localIpasHeader.configure("Local Files") // todo localize
        }
        if let myappstoreHeader = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: Section.myappstore.rawValue)) as? LibrarySectionHeaderView {
            myappstoreHeader.configure("MyAppstore") // todo localize
        }
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
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Section.myappstore.rawValue { return myAppstoreIpas.count }
        return localIpas.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == Section.myappstore.rawValue {
            guard myAppstoreIpas.indices.contains(indexPath.row) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myappstorecell", for: indexPath) as! MyAppstoreCell
            cell.configure(with: myAppstoreIpas[indexPath.row])
            cell.installButton.addTarget(self, action: #selector(install), for: .touchUpInside)
            cell.installButton.tag = indexPath.row
            return cell
        } else {
            guard localIpas.indices.contains(indexPath.row) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "localipacell", for: indexPath) as! LocalIPACell
            cell.configure(with: localIpas[indexPath.row])
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
    
    fileprivate func presentOptionsForMyappstoreApp(_ app: MyAppstoreApp, _ indexPath: IndexPath) {
        let title = app.name
        // todo localize
        let message = "\(app.bundleId)\(Global.bulletPoint)\(app.size)\(Global.bulletPoint)\(app.version)" +
                      "\nUploaded on \(app.uploadedAt.unixToDetailedString)"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in // todo localize
            API.deleteIpa(id: app.id, completion: { error in
                if let error = error {
                    debugLog(error)
                } else {
                    self.myAppstoreIpas.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    // todo handle empty
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alertController.addAction(delete)
        alertController.addAction(cancel)

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
    
    fileprivate func presentOptionsForLocalIpa(_ ipa: LocalIPAFile, _ indexPath: IndexPath) {

        let alertController = UIAlertController(title: ipa.filename, message: nil, preferredStyle: .actionSheet)
        
        let installJB = UIAlertAction(title: "Install without signing".localized(), style: .default) { _ in // todo localize
            self.customInstall(ipa: ipa)
        }
        let addToMyAppstore = UIAlertAction(title: "Upload to MyAppstore".localized(), style: .default) { _ in // todo localize
            self.addToMyAppstore(ipa: ipa)
        }
        let openIn = UIAlertAction(title: "Open in...".localized(), style: .default) { _ in // todo localize
            self.documentController = UIDocumentInteractionController(url: IPAFileManager.shared.url(for: ipa))
            if let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
                let rect = self.collectionView.convert(attributes.frame, to: self.collectionView.superview)
                self.documentController!.presentOpenInMenu(from: rect, in: self.collectionView, animated: true)
            }
        }
        let rename = UIAlertAction(title: "Rename".localized(), style: .default) { _ in // todo localize
            self.handleRename(for: ipa, at: indexPath)
        }
        let delete = UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in // todo localize
            IPAFileManager.shared.delete(file: ipa)
            self.localIpas.remove(at: indexPath.row)
            self.collectionView.deleteItems(at: [indexPath])
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        
        alertController.addAction(installJB)
        alertController.addAction(addToMyAppstore)
        alertController.addAction(openIn)
        alertController.addAction(rename)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        
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
    
    // MARK: - Add to MyAppstore
    
    func addToMyAppstore(ipa: LocalIPAFile) {
        
        let randomString = Global.randomString(length: 30)
        guard let jobId = SHA1.hexString(from: randomString)?.replacingOccurrences(of: " ", with: "").lowercased() else { return }
        let url = IPAFileManager.shared.url(for: ipa)
        
        uploadBackgroundTask = BackgroundTaskUtil()
        uploadBackgroundTask?.start()
        
        API.addToMyAppstore(jobId: jobId, fileURL: url, progress: { p in
            debugLog("progress: \(p)")
        }, completion: { error in
            if let error = error {
                debugLog("error: \(error)")
                self.uploadBackgroundTask = nil
            } else {
                debugLog("success")
                delay(1) {
                    API.analyzeJob(jobId: jobId, completion: { error in
                        self.uploadBackgroundTask = nil
                        if let error = error {
                            debugLog("error 2: \(error)")
                        } else {
                            debugLog("success 2")
                        }
                    })
                }
            }
        })
    }
    
    // MARK: - Custom install
    
    func customInstall(ipa: LocalIPAFile) {

        IPAFileManager.shared.startServer()
        
        let plist = IPAFileManager.shared.base64ToJSONInfoPlist(from: ipa)
        let link = IPAFileManager.shared.getIpaLocalUrl(from: ipa)
        
        API.requestInstallJB(plist: plist, icon: " ", link: link, completion: { error in
            
            if let error = error {
                debugLog(error)
                IPAFileManager.shared.stopServer()
            } else {
                debugLog("success!")
                // Allowing up to 3 mins for app to install...
                delay(180) { IPAFileManager.shared.stopServer() }
            }
        })
    }
    
    // MARK: - Rename local ipa
    
    func handleRename(for file: LocalIPAFile, at indexPath: IndexPath) {
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
    
    // MARK: - Install app
    
    @objc fileprivate func install(sender: RoundedButton) {
        
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }
        
        if DeviceInfo.deviceIsLinked {
            setButtonTitle("Requesting...") // todo localize
            
            API.install(id: sender.linkId, type: .myAppstore) { error in
                if let error = error {
                    debugLog(error)
                    delay(0.3) { setButtonTitle("Install") }
                } else {
                    setButtonTitle("Requested") // todo localize
                    
                    ObserveQueuedApps.shared.addApp(type: .myAppstore, linkId: sender.linkId, name: self.myAppstoreIpas[sender.tag].name, image: "", bundleId: self.myAppstoreIpas[sender.tag].bundleId)
                    
                    delay(5) { setButtonTitle("Install") }
                }
            }
        } else {
            // Install requested but device is not linked
        }
    }
    
}

// MARK: - ETCollectionViewDelegateWaterfallLayout

extension Library: ETCollectionViewDelegateWaterfallLayout {
    
    var margin: CGFloat {
        return UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : (20~~15)
    }
    
    var topInset: CGFloat {
        return 25~~15
    }
    
    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 20~~15
        layout.minimumInteritemSpacing = 15~~10
        layout.headerHeight = 1
        layout.headerInset.top = 38~~33
        layout.headerInset.bottom = 4
        if #available(iOS 11.0, *) {
            layout.headerInset.left = (UIDevice.current.orientation.isLandscape && Global.hasNotch ? 45 : 2)
        }
        layout.sectionInset = UIEdgeInsets(top: topInset, left: margin, bottom: 0, right: margin)
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
                return (view.bounds.width / 2) - 30
            } else {
                return (view.bounds.width / 3) - 25
            }
        } else {
            if UIDevice.current.orientation.isPortrait {
                return view.bounds.width - 30
            } else {
                return (view.bounds.width / 2) - (Global.hasNotch ? 70 : 25)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemDimension, height: indexPath.section == Section.myappstore.rawValue ? (70~~65) : (60~~55))
    }
}

extension Library: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == Section.local.rawValue {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewOne", for: indexPath) as! LibrarySectionHeaderView
            } else {
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderViewTwo", for: indexPath) as! LibrarySectionHeaderView
            }
        }
        return UICollectionReusableView()
    }
}
