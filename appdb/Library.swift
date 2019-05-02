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
    
    internal var localIpas = [LocalIPAFile]()
    internal var myAppstoreIpas = [MyAppstoreApp]()
    internal var timer: Timer? = nil
    internal var documentController: UIDocumentInteractionController?
    internal var useDiff: Bool = false
    internal var uploadBackgroundTask: BackgroundTaskUtil? = nil
    
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
        collectionView.contentInset.bottom = 25~~15
        collectionView.delaysContentTouches = false
        
        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        // Register cells
        registerCells()
        
        state = .hideIndicator
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
                self.reloadFooterViews()
                
            }) { error in
                self.collectionView.reload(changes: localIpaChanges, section: Section.local.rawValue, updateData: {
                    self.localIpas = newLocalIpas
                })
                self.reloadFooterViews()
            }
            
        } else {
            localIpas = IPAFileManager.shared.listLocalIpas()
            API.getIpas(success: { ipas in
                self.myAppstoreIpas = ipas

                self.state = .done(animated: false)
                self.reloadFooterViews()
                self.collectionView.reloadData()
                
                self.useDiff = true
                
            }) { error in
                self.state = .done(animated: false)
                self.reloadFooterViews()
            }
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
            cell.installButton.addTarget(self, action: #selector(installMyAppstoreApp), for: .touchUpInside)
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
        let message = "\(app.bundleId)\(Global.bulletPoint)\(app.size)\(Global.bulletPoint)\(app.version)" +
                      "\nUploaded on \(app.uploadedAt.unixToDetailedString)" // todo localize
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Install".localized(), style: .default) { _ in // todo localize
            if let cell = self.collectionView.cellForItem(at: indexPath) as? MyAppstoreCell {
                if let button = cell.installButton {
                    self.installMyAppstoreApp(sender: button)
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in // todo localize
            self.deleteMyAppstoreApp(id: app.id, indexPath: indexPath)
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
    
    fileprivate func presentOptionsForLocalIpa(_ ipa: LocalIPAFile, _ indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LocalIPACell else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if cell.isUploadInProgress() {
            if !cell.paused {
                alertController.addAction(UIAlertAction(title: "Pause".localized(), style: .default) { _ in // todo localize
                    self.pauseUpload(cell: cell)
                })
            } else {
                alertController.addAction(UIAlertAction(title: "Resume".localized(), style: .default) { _ in // todo localize
                    self.resumeUpload(cell: cell)
                })
            }
            alertController.addAction(UIAlertAction(title: "Stop".localized(), style: .destructive) { _ in // todo localize
                self.stopUpload(cell: cell, ipa: ipa)
            })
        } else {
            alertController.title = ipa.filename
            
            alertController.addAction(UIAlertAction(title: "Install without signing".localized(), style: .default) { _ in // todo localize
                self.customInstall(ipa: ipa)
            })
            
            alertController.addAction(UIAlertAction(title: "Upload to MyAppstore".localized(), style: .default) { _ in // todo localize
                self.addToMyAppstore(ipa: ipa, indexPath: indexPath)
            })
            
            alertController.addAction(UIAlertAction(title: "Open in...".localized(), style: .default) { _ in // todo localize
                self.openIn(ipa: ipa, indexPath: indexPath)
            })
            
            alertController.addAction(UIAlertAction(title: "Rename".localized(), style: .default) { _ in // todo localize
                self.handleRename(for: ipa, at: indexPath)
            })
            
            alertController.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive) { _ in // todo localize
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
