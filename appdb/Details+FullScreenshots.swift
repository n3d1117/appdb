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

class DetailsFullScreenshotsNavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

extension DetailsFullScreenshots: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullscreenshot", for: indexPath) as! DetailsFullScreenshotCell
        
        if let url = URL(string: screenshots[indexPath.row].image) {
            let urlRequest = URLRequest(url: url)
            imageDownloader.download(urlRequest) { response in
                if let image = response.result.value {
                    if self.screenshots[indexPath.row].class_ == "landscape" {
                        cell.image.image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
                    } else {
                        cell.image.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: effectiveWidth, height: effectiveHeight)
    }
    
}

class DetailsFullScreenshots: UIViewController {
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 5,
        imageCache: AutoPurgingImageCache()
    )
    
    var didSetupConstraints: Bool = false
    var collectionView: UICollectionView!
    var pageControl: UIPageControl!
    var screenshots: [Screenshot] = []
    var index: Int = 0
    
    var widthIfPortrait: CGFloat { return round(((300~~280)-(Global.size.margin.value * 2)) / magic) }
    var widthIfLandscape: CGFloat { return round(((230~~176)-(Global.size.margin.value * 2)) * magic) }
    var allLandscape: Bool { return screenshots.filter({$0.class_=="portrait"}).isEmpty }
    var spacing: CGFloat = 25
    
    var magic: CGFloat {
        if screenshots.filter({$0.type=="ipad"}).isEmpty { return 1.775 }
        if screenshots.filter({$0.type=="iphone"}).isEmpty { return 1.333 }
        return 0
    }
    var top: CGFloat {
        return (navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.height
    }
    var bottomInset: CGFloat {
        return topInset + 10
    }
    var topInset: CGFloat {
        return top > 60.0 ? 35 : 20
    }
    var effectiveHeight: CGFloat {
        return view.bounds.height - top - bottomInset - topInset
    }
    var effectiveWidth: CGFloat {
        return round(effectiveHeight/magic)
    }
    
    convenience init(screenshots: [Screenshot], index: Int) {
        self.init()
        self.screenshots = screenshots
        self.index = index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Insert light or dark blur based on current theme
        view.backgroundColor = .clear
        var darkBlur: UIBlurEffect = UIBlurEffect()
        darkBlur = UIBlurEffect(style: Themes.isNight ? .dark : .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = screenshots.count
        pageControl.theme_tintColor = Color.veryVeryLightGray
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.theme_currentPageIndicatorTintColor = Color.mainTint
        pageControl.isUserInteractionEnabled = false
        
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action:#selector(self.dismissAnimated))
        navigationItem.rightBarButtonItem = doneButton
        
        let insets = (view.bounds.width - effectiveWidth) / 2
        let layout = SnappableFlowLayout(width: effectiveWidth, spacing: spacing, magic: 60)
        layout.sectionInset = UIEdgeInsets(top: top+topInset, left: insets, bottom: bottomInset, right: insets)
        layout.minimumLineSpacing = spacing
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
        view.addSubview(pageControl)
        
        setConstraints()
    }
    
    var shouldOpenWithCustomOffset: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if index != 0, !shouldOpenWithCustomOffset {
            shouldOpenWithCustomOffset = true
            pageControl.currentPage = index
            let insets = (view.bounds.width - effectiveWidth) / 2
            let offset = view.bounds.width - insets - (insets - spacing)
            let x = round(offset * CGFloat(index))
            collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = floor((scrollView.contentOffset.x - effectiveWidth/2) / effectiveWidth) + 1
        pageControl.currentPage = Int(page)
    }
    
    fileprivate func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(collectionView, pageControl) { collection, pageControl in
                collection.edges == collection.superview!.edges
                
                pageControl.bottom == pageControl.superview!.bottom + (bottomInset/6)
                pageControl.centerX == pageControl.superview!.centerX
            }
        }
    }
    
    /* Nah, let's not support rotation k?
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if let layout = collectionView.collectionViewLayout as? SnappableFlowLayout {
            layout.invalidateLayout()
        }
    }*/
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
}
