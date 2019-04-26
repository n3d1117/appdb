//
//  Local+MyAppstore.swift
//  appdb
//
//  Created by ned on 22/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class LocalAndMyAppstore: LoadingCollectionView {
    
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
        
        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.register(TrendingCollectionViewCell.self, forCellWithReuseIdentifier: "id")
        
        state = .loading
        
        delay(3) {
            self.collectionView.reloadData()
            self.state = .done(animated: true)
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
        return (isLoading || hasError) ? 0 : 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isLoading else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath)
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.contentView.layer.cornerRadius = 6
        cell.contentView.layer.borderWidth = 1 / UIScreen.main.scale
        cell.contentView.layer.theme_borderColor = Color.borderCgColor
        cell.layer.backgroundColor = UIColor.clear.cgColor
        return cell
    }
    
}

// MARK: - ETCollectionViewDelegateWaterfallLayout

extension LocalAndMyAppstore: ETCollectionViewDelegateWaterfallLayout {
    
    var isLoading: Bool {
        if case LoadingCollectionView.State.loading = state {
            return true
        } else {
            return false
        }
    }
    
    var hasError: Bool {
        if case LoadingCollectionView.State.error(_, _, _) = state {
            return true
        } else {
            return false
        }
    }
    
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
                return (view.bounds.width / 2) - (Global.hasNotch ? 80 : 25)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemDimension, height: 100)
    }
}
