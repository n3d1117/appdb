//
//  Details+FullScreenshots.swift
//  appdb
//
//  Created by ned on 02/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage

class DetailsFullScreenshotsNavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
    }
    // Let's hide home indicator on iPhone X
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}

extension DetailsFullScreenshots: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fullscreenshot", for: indexPath) as? DetailsFullScreenshotCell else { return UICollectionViewCell() }
        guard let url = URL(string: screenshots[indexPath.row].image) else { return UICollectionViewCell() }

        // If 'mixedClasses' is true, assign image and rotate left if landscape.
        if mixedClasses {
            imageDownloader.download(URLRequest(url: url), completion: { response in
                guard let image = try? response.result.get() else { return }
                if self.screenshots[indexPath.row].class_ == "landscape", let cgImage = image.cgImage {
                    cell.image.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
                } else {
                    cell.image.image = image
                }
            })
        // if not, simply set image from url
        } else {
            cell.image.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenshots.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        itemSize(for: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: left)
    }
}

class DetailsFullScreenshots: UIViewController {

    // The array of screenshot to use as a data source
    var screenshots: [Screenshot] = []

    var collectionView: UICollectionView!
    var pageControl: UIPageControl!

    // Given index to open specific screenshot
    var index: Int = 0
    var spacing: CGFloat!

    // Image downloader, used to rotate image left if needed
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 5,
        imageCache: AutoPurgingImageCache()
    )

    var isPortrait: Bool { UIApplication.shared.statusBarOrientation.isPortrait }

    // We get these from previous view
    var mixedClasses, allLandscape: Bool!
    var magic: CGFloat!

    // Layout insets
    var height, width, left, top, bottom: CGFloat!

    // Returns item size at given index
    func itemSize(for index: Int) -> CGSize {
        if isPortrait { // device is portratit
            if screenshots[index].class_ == "landscape" && !mixedClasses {
                let w = round(view.bounds.width - (Global.Size.margin.value - (-100 ~~ 0)) * 2)
                return CGSize(width: w, height: w / magic)
            } else {
                let off: CGFloat = (Global.isIpad && magic == 1.775) ? (180 ~~ 20) : (100 ~~ 20)
                let w = round(view.bounds.width - (Global.Size.margin.value + off) * 2)
                return CGSize(width: w, height: w * magic)
            }
        } else { // device is landscape
            if screenshots[index].class_ == "landscape" && !mixedClasses {
                let h = round(view.bounds.height - (Global.Size.margin.value + (100 ~~ 25)) * 2)
                return CGSize(width: h * magic, height: h)
            } else {
                let h = round(view.bounds.height - (Global.Size.margin.value + (100 ~~ 25)) * 2)
                return CGSize(width: h / magic, height: h)
            }
        }
    }

    // Calculates width, height and insets for the correct layout
    func calculateAllSizes() {
        if isPortrait {
            if allLandscape {
                width = round(view.bounds.width - (Global.Size.margin.value - (-100 ~~ 0)) * 2)
                height = round(width / magic)
                left = round((view.bounds.width - width) / 2)

                let w = (view.bounds.width - Global.Size.margin.value / 2) / magic
                let topFull = round((view.bounds.height - w) / 2)
                top = topFull
                bottom = topFull - (50 ~~ 0)
            } else {
                let off: CGFloat = round((Global.isIpad && magic == 1.775) ? (180 ~~ 20) : (100 ~~ 20))
                width = round(view.bounds.width - (Global.Size.margin.value + off) * 2)
                height = round(width * magic)
                left = round((view.bounds.width - width) / 2)
                top = round((view.bounds.height - (view.bounds.width - (Global.Size.margin.value + 20) * 2) * magic) / 2 + 23)
                bottom = round((view.bounds.height - (view.bounds.width - (Global.Size.margin.value + 20) * 2) * magic) / 2 - 23)
            }
        } else {
            if allLandscape {
                height = round(view.bounds.height - (Global.Size.margin.value + (100 ~~ 25)) * 2)
                width = round(height * magic)
                left = round((view.bounds.width - width) / 2)
                top = round(Global.Size.margin.value + 20 + (30 ~~ 12))
                bottom = round(Global.Size.margin.value + 20 - (-30 ~~ 12) - (50 ~~ 0))
            } else {
                height = round(view.bounds.height - (Global.Size.margin.value + (100 ~~ 25)) * 2)
                width = round(height / magic)
                left = round((view.bounds.width - width) / 2)
                top = round(Global.Size.margin.value + 20 + (30 ~~ 15))
                bottom = round(Global.Size.margin.value + 20 - (-30 ~~ 15) - (50 ~~ 0))
            }
        }
    }

    // Initializer
    convenience init(_ screenshots: [Screenshot], _ index: Int, _ allLandscape: Bool, _ mixedClasses: Bool, _ magic: CGFloat) {
        self.init()
        self.screenshots = screenshots
        self.index = index
        self.allLandscape = allLandscape
        self.mixedClasses = mixedClasses
        self.magic = magic

        // wtf this crashes sourcekit? self.spacing = self.allLandscape ? (35~~10) : (35~~25)
        if self.allLandscape {
            self.spacing = (35 ~~ 10)
        } else {
            self.spacing = (35 ~~ 25)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        calculateAllSizes()

        // Insert light or dark blur based on current theme
        view.backgroundColor = .clear
        var darkBlur = UIBlurEffect()
        darkBlur = UIBlurEffect(style: Themes.isNight ? .dark : .light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)

        // Set up page control indicator
        pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = screenshots.count
        pageControl.theme_tintColor = Color.veryVeryLightGray
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.theme_currentPageIndicatorTintColor = Color.mainTint
        pageControl.isUserInteractionEnabled = false
        if Global.isRtl { pageControl.transform = CGAffineTransform(scaleX: -1, y: 1) }

        // Add done button
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
        navigationItem.rightBarButtonItem = doneButton

        // Configure SnappableFlowLayout
        let layout = SnappableFlowLayout(width: width, spacing: spacing, magic: 60)
        layout.minimumLineSpacing = spacing
        layout.scrollDirection = .horizontal

        // Initialize collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DetailsFullScreenshotCell.self, forCellWithReuseIdentifier: "fullscreenshot")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        // Add swipe down gesture recognizer
        let slideDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissAnimated))
        slideDown.direction = .down
        view.addGestureRecognizer(slideDown)

        view.addSubview(collectionView)
        view.addSubview(pageControl)

        setConstraints()
    }

    private func setConstraints() {
        constrain(collectionView, pageControl) { collection, pageControl in
            collection.edges ~== collection.superview!.edges
            pageControl.bottom ~== pageControl.superview!.layoutMarginsGuide.bottom
            pageControl.centerX ~== pageControl.superview!.centerX
        }
    }

    // If index != 0, we need to scroll the collection view to given index before presenting
    var shouldOpenWithCustomOffset = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if index != 0, !shouldOpenWithCustomOffset {
            shouldOpenWithCustomOffset = true
            pageControl.currentPage = index
            let offset = view.bounds.width - left - (left - spacing)
            let x = round(offset * CGFloat(index))
            collectionView.setContentOffset(CGPoint(x: x, y: 0), animated: false)
        }
    }

    // Update pageControl based on scroll offset
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let w = itemSize(for: pageControl.currentPage).width
        let page = floor((scrollView.contentOffset.x - w / 2) / w) + 1
        pageControl.currentPage = Int(page)
    }

    // This sucks - attempts at a smooth rotation with layout invalidation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        UIView.animate(withDuration: 0.1) {
            self.collectionView.alpha = 0
        }
        guard let layout = self.collectionView?.collectionViewLayout as? SnappableFlowLayout else { return }
        coordinator.animate(alongsideTransition: nil) { _ in
            self.calculateAllSizes()
            layout.invalidateLayout()
            layout.updateWidth(self.width)
            self.collectionView.scrollToItem(at: IndexPath(row: self.pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: false)
            UIView.animate(withDuration: 0.3) {
                self.collectionView.alpha = 1
            }
        }
    }

    @objc func dismissAnimated() { dismiss(animated: true) }
}
