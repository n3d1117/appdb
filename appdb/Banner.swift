//
//  Banner.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

extension Banner: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! BannerImage
        
        switch indexPath.row {
            case 0: cell.image.image = #imageLiteral(resourceName: "banner")
            default: cell.image.image = #imageLiteral(resourceName: "placeholderBanner")
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setTimerIfNeeded()
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentIndex = indexPath.row
    }
    
}

class Banner: UITableViewCell {

    var collectionView: UICollectionView!
    
    let height: CGFloat = {
        let w: Double = Double(UIScreen.main.bounds.width)
        let h: Double = Double(UIScreen.main.bounds.height)
        let screenHeight: Double = max(w, h)

        switch screenHeight { /* Are these numbers out of my ass? Probably. There should be a better way. */
            case 480, 568: return 128
            case 667: return 150
            case 736: return 165
            case 812: return 150
            case 1024: return 220
            case 1112: return 225
            case 1366: return 250
            default: print("oh no, uncaught device height! (\(screenHeight))"); return 150
        }
        
    }()
    
    fileprivate var slideshowTimer: Timer?
    var slideshowInterval = 0.0 {
        didSet {
            self.slideshowTimer?.invalidate()
            self.slideshowTimer = nil
            setTimerIfNeeded()
        }
    }
    
    deinit { pauseTimer() }
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: Featured.CellType.banner.rawValue)
        
        theme_backgroundColor = Color.tableViewBackgroundColor
        contentView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        let layout = LNZInfiniteCollectionViewLayout()
        layout.itemSize = CGSize(width: height*2.5, height: height)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BannerImage.self, forCellWithReuseIdentifier: "image")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.alwaysBounceVertical = false
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        contentView.addSubview(collectionView)
        
        // Add constraints
        constrain(collectionView) { collectionView in
            collectionView.top == collectionView.superview!.top
            collectionView.left == collectionView.superview!.left
            collectionView.right == collectionView.superview!.right
            collectionView.height == height
        }
        
        slideshowInterval = 5.0
        setTimerIfNeeded()
        
        //
        // Get Promotions
        // TODO: ask fred to add banner image to API
        //
        
        /*API.getPromotions( success: { items in
            
            if items.isEmpty {
                print("no promotions to show")
            } else {
                print("found \(items.count) promotions.")
            }
            
        }, fail: { error in
                print(error.localizedDescription)
        })*/
        
    }
    
    fileprivate func setTimerIfNeeded() {
        if slideshowInterval > 0 && slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval, target: self, selector: #selector(self.slideshowTick(_:)), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate var currentIndex: Int = 0
    @objc func slideshowTick(_ timer: Timer) {
        let n = collectionView.numberOfItems(inSection: 0)
        guard n != 0 else { return }
        currentIndex += 1
        if currentIndex == n { currentIndex = 0 }
        collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    /// Stops slideshow timer
    open func pauseTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }

}
