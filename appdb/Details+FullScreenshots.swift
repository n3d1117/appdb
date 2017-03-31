//
//  Details+FullScreenshots.swift
//  appdb
//
//  Created by ned on 14/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

/* WIP */

class DetailsFullScreenshotsNavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
    }
}

extension DetailsFullScreenshots: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullscreenshot", for: indexPath) as! DetailsFullScreenshotCell
        if let url = URL(string: screenshots[indexPath.row].image) {
            cell.image.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var s = view.bounds.size
        s.height -= (64 + 35 + 45)
        s.width = s.height/1.775
        return s
    }
    
}

class DetailsFullScreenshots: UIViewController {
    
    var didSetupConstraints: Bool = false
    var collectionView: UICollectionView!
    var screenshots: [Screenshot] = []
    var index: Int = 0
    
    convenience init(screenshots: [Screenshot], index: Int) {
        self.init()
        self.screenshots = screenshots
        self.index = index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .clear
        var darkBlur: UIBlurEffect = UIBlurEffect()
        darkBlur = UIBlurEffect(style: Themes.isNight ? .dark : .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action:#selector(self.dismissAnimated))
        navigationItem.rightBarButtonItem = doneButton
        
        let layout = SnappableFlowLayout(width: 294, spacing: 25)
        layout.sectionInset = UIEdgeInsets(top: 64+35, left: 30, bottom: 45, right: 30)
        layout.minimumLineSpacing = 25
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DetailsFullScreenshotCell.self, forCellWithReuseIdentifier: "fullscreenshot")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        
        collectionView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray
        
        view.addSubview(collectionView)
        
        setConstraints()
    }
    
    func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(collectionView) { collection in
                collection.edges == collection.superview!.edges
            }
        }
    }
    
    func dismissAnimated() { dismiss(animated: true) }
    
}
