//
//  Details+Screenshots.swift
//  appdb
//
//  Created by ned on 22/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import Cartography

protocol ScreenshotRedirectionDelegate {
    func screenshotImageSelected(with index: Int, _ allLandscape: Bool, _ mixedClasses: Bool, _ magic: CGFloat)
}

extension DetailsScreenshots: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenshot", for: indexPath) as! DetailsScreenshotCell
        if let url = URL(string: screenshots[indexPath.row].image) {
            cell.image.af_setImage(withURL: url, filter: filterAtIndex(indexPath.row), imageTransition: .crossDissolve(0.2))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeAtIndex(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.screenshotImageSelected(with: indexPath.row, allLandscape, mixedClasses, magic)
    }
    
}

class DetailsScreenshots: DetailsCell {
    
    override var identifier: String { return "screenshots" }
    override var height: CGFloat {
        if screenshots.isEmpty { return 0 }
        return allLandscape ? (230~~176) : (314~~280)
    }
    
    var delegate: ScreenshotRedirectionDelegate? = nil
    
    var collectionView: UICollectionView!
    var screenshots: [Screenshot] = []
    
    var magic: CGFloat {
        if screenshots.filter({$0.type=="ipad"}).isEmpty { return 1.775 }
        if screenshots.filter({$0.type=="iphone"}).isEmpty { return 1.333 }
        return 0
    }

    var widthIfPortrait: CGFloat { return round(((314~~280)-(Global.size.margin.value * 2)) / magic) }
    var widthIfLandscape: CGFloat { return round(((230~~176)-(Global.size.margin.value * 2)) * magic) }
    var allLandscape: Bool { return (screenshots.filter({$0.class_=="portrait"}).isEmpty && screenshots.filter({$0.class_.isEmpty}).isEmpty) }
    var mixedClasses: Bool { return !screenshots.filter({$0.class_=="portrait"}).isEmpty && !screenshots.filter({$0.class_=="landscape"}).isEmpty }
    var spacing: CGFloat = 15
    
    func sizeAtIndex(_ index: Int) -> CGSize {
        if screenshots[index].class_ == "landscape" {
            return CGSize(width: widthIfLandscape, height: (230~~176)-(Global.size.margin.value*2)-1)
        } else {
            return CGSize(width: widthIfPortrait, height: height-(Global.size.margin.value*2)-1)
        }
    }
    
    func filterAtIndex(_ index: Int) -> ImageFilter {
        return Global.screenshotRoundedFilter(size: sizeAtIndex(index), radius: 7)
    }
    
    convenience init(type: ItemType, screenshots: [Screenshot], delegate: ScreenshotRedirectionDelegate) {
        self.init(style: .default, reuseIdentifier: "screenshots")
        
        self.type = type
        self.screenshots = screenshots
        self.delegate = delegate
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        if !height.isZero {
            
            let proposedWidth = allLandscape ? widthIfLandscape : widthIfPortrait
            let layout = SnappableFlowLayout(width: mixedClasses ? 0 : proposedWidth, spacing: spacing)
            layout.sectionInset = UIEdgeInsets(top: Global.size.margin.value, left: Global.size.margin.value,
                                               bottom: Global.size.margin.value, right: Global.size.margin.value)
            layout.minimumLineSpacing = spacing
            layout.scrollDirection = .horizontal
            
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(DetailsScreenshotCell.self, forCellWithReuseIdentifier: "screenshot")
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.scrollsToTop = false
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            
            collectionView.theme_backgroundColor = Color.veryVeryLightGray
            theme_backgroundColor = Color.veryVeryLightGray
            contentView.theme_backgroundColor = Color.veryVeryLightGray
            
            contentView.addSubview(collectionView)
            
            setConstraints()
            
        }
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(collectionView) { collection in
                collection.edges == collection.superview!.edges
            }
        }
    }
    
}
