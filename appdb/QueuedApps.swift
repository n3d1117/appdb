//
//  QueuedApps.swift
//  appdb
//
//  Created by ned on 22/04/2019.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class QueuedApps: LoadingCollectionView {
    
    fileprivate var requestedApps = [RequestedApp]()
 
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
        
        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.register(QueuedDownloadsCell.self, forCellWithReuseIdentifier: "queuedDownloadsCell")
        
        setErrorMessageIfEmpty()
        
        // Update collection view every time new data comes
        ObserveQueuedApps.shared.onUpdate = { [unowned self] apps in
            self.updateCollection(with: apps)
        }
    }
    
    // MARK: - Update source
    
    fileprivate func updateCollection(with apps: [RequestedApp]) {

        if !requestedApps.isEmpty || !apps.isEmpty {

            // Perform diff
            let diff = Diff(from: requestedApps, to: apps)
            let animated = requestedApps.isEmpty
            
            // Update collection view
            collectionView.performBatchUpdates({
                
                requestedApps = apps
                if !isDone { state = .done(animated: animated) }
                
                for index in diff.deleted { collectionView.deleteItems(at: [IndexPath(row: index, section: 0)]) }
                for index in diff.inserted { collectionView.insertItems(at: [IndexPath(row: index, section: 0)]) }
                for match in diff.matches {
                    if match.changed && match.from == match.to {
                        collectionView.reloadItems(at: [IndexPath(row: match.from, section: 0)])
                    }
                }
            })

            if requestedApps.isEmpty {
                setErrorMessageIfEmpty()
            }
        } else {
            setErrorMessageIfEmpty()
        }
    }
    
    fileprivate func setErrorMessageIfEmpty() {
        let noQueuesMessage = "No queued downloads".localized()
        if case LoadingCollectionView.State.error(noQueuesMessage, _, _) = state {} else {
            state = .error(first: noQueuesMessage, second: "", animated: false)
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
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (isLoading || hasError) ? 0 : requestedApps.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isLoading else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "queuedDownloadsCell", for: indexPath) as! QueuedDownloadsCell
        cell.configure(with: requestedApps[indexPath.row])
        return cell
    }
    
}

// MARK: - ETCollectionViewDelegateWaterfallLayout

extension QueuedApps: ETCollectionViewDelegateWaterfallLayout {
    
    var margin: CGFloat {
        return UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : (20~~15)
    }
    
    var topInset: CGFloat {
        return Global.isIpad ? 25 : 15
    }
    
    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 20~~15
        layout.minimumInteritemSpacing = 15~~10
        layout.sectionInset = UIEdgeInsets(top: topInset, left: margin, bottom: topInset, right: margin)
        layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 1 : 2
        return layout
    }
    
    var itemDimension: CGFloat {
        if UIDevice.current.orientation.isPortrait {
            return view.bounds.width - margin*2
        } else {
            return (view.bounds.width / 2) - margin*1.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemDimension, height: (80~~70) + Global.size.margin.value*2)
    }
}
