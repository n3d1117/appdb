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
        case local, myappstore
    }
    
    fileprivate var myAppstoreIpas = [MyAppstoreApp]()
    fileprivate var timer: Timer? = nil
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        self.hasSegment = true
        super.viewDidLoad()
        
        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        
        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        collectionView.register(LibrarySectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "librarySectionHeaderView")
        collectionView.register(MyAppstoreCell.self, forCellWithReuseIdentifier: "myappstorecell")

    }
    
    var firstTimeOnly: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !firstTimeOnly {
            firstTimeOnly = true
            state = .loading
        }
        fetchIpas()
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(fetchIpas), userInfo: nil, repeats: true)
        }
    }
    
    @objc fileprivate func fetchIpas() {
        API.getIpas(success: { ipas in
            
            let changes = diff(old: self.myAppstoreIpas, new: ipas)
            let animated = self.myAppstoreIpas.isEmpty
            
            self.collectionView.reload(changes: changes, section: Section.myappstore.rawValue, updateData: {
                self.myAppstoreIpas = ipas
                if !self.isDone { self.state = .done(animated: animated) }
            })
            
            // todo handle empty
            
        }) { error in
            // todo
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
        if section == Section.myappstore.rawValue { return isLoading ? 0 : myAppstoreIpas.count }
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == Section.myappstore.rawValue {
            guard !isLoading, myAppstoreIpas.indices.contains(indexPath.row) else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myappstorecell", for: indexPath) as! MyAppstoreCell
            cell.configure(with: myAppstoreIpas[indexPath.row])
            cell.installButton.addTarget(self, action: #selector(install), for: .touchUpInside)
            cell.installButton.tag = indexPath.row
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myappstorecell", for: indexPath) as! MyAppstoreCell
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.myappstore.rawValue {
            
            guard self.myAppstoreIpas.indices.contains(indexPath.row) else { return }
            let ipa = self.myAppstoreIpas[indexPath.row]
            
            let title = ipa.name + Global.bulletPoint + ipa.version
            let message = "\(ipa.bundleId)\(Global.bulletPoint)\(ipa.size)\n\nUploaded on \(ipa.uploadedAt.unixToDetailedString)" // todo localize
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let delete = UIAlertAction(title: "Delete ipa".localized(), style: .destructive) { _ in // todo localize
                API.deleteIpa(id: ipa.id, completion: { error in
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
                    
                    ObservableRequestedApps.shared.addApp(type: .myAppstore, linkId: sender.linkId, name: self.myAppstoreIpas[sender.tag].name,
                                                          image: "", bundleId: self.myAppstoreIpas[sender.tag].bundleId)
                    
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
        return UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 50 : (20~~15)
    }
    
    var topInset: CGFloat {
        return Global.isIpad ? 25 : 15
    }
    
    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 20~~15
        layout.minimumInteritemSpacing = 15~~10
        layout.headerHeight = 25~~20
        layout.headerInset.top = 20
        if #available(iOS 11.0, *) {
            layout.headerInset.left = (UIDevice.current.orientation.isLandscape && Global.hasNotch ? 35 : 2)
        }
        layout.sectionInset = UIEdgeInsets(top: topInset, left: margin, bottom: topInset, right: margin)
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
        return CGSize(width: itemDimension, height: (80~~70))
    }
}

extension Library: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "librarySectionHeaderView", for: indexPath) as! LibrarySectionHeaderView
            header.configure(indexPath.section == Section.myappstore.rawValue ? "MyAppstore" : "Local files") // todo localize
            return header
        }
        return UICollectionReusableView()
    }
}
