//
//  BBTabBarController.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class TabBarController: UITabBarController {

    private var interstitialAd: STAStartAppAd?
    private var bannerAd: STABannerView?

    private var bannerGroup = ConstraintGroup()
    private var adContainerView: UIView?
    private var interstitialReady: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let featuredNav = UINavigationController(rootViewController: Featured())
        featuredNav.tabBarItem = UITabBarItem(title: "Featured".localized(), image: #imageLiteral(resourceName: "featured"), tag: 0)

        let searchNav = UINavigationController(rootViewController: Search())
        searchNav.tabBarItem = UITabBarItem(title: "Search".localized(), image: #imageLiteral(resourceName: "search"), tag: 1)

        let downloadsNav = UINavigationController(rootViewController: Downloads())
        downloadsNav.tabBarItem = UITabBarItem(title: "Downloads".localized(), image: #imageLiteral(resourceName: "downloads"), tag: 2)

        let settingsNav = UINavigationController(rootViewController: Settings())
        settingsNav.tabBarItem = UITabBarItem(title: "Settings".localized(), image: #imageLiteral(resourceName: "settings"), tag: 3)

        let updatesNav = UINavigationController(rootViewController: Updates())
        updatesNav.tabBarItem = UITabBarItem(title: "Updates".localized(), image: #imageLiteral(resourceName: "updates"), tag: 4)

        viewControllers = [featuredNav, searchNav, downloadsNav, settingsNav, updatesNav]

        interstitialAd = AdHelper.generateInterstitial()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        interstitialAd?.load()

        if bannerAd == nil {
            bannerAd = AdHelper.generateBanner(on: self)

            if let bannerAd = bannerAd {
                adContainerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: tabBar.frame.origin.y - tabBar.frame.height), size: CGSize(width: view.frame.size.width, height: 90 ~~ 50)))
                adContainerView?.addSubview(bannerAd)
                view.addSubview(adContainerView!)
                setBannerConstraints()
            }
        }
    }

    // Bounce animation
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if !Global.isIpad, let view = item.value(forKey: "view") as? UIView, let image = view.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.1, animations: {
                image.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    image.transform = .identity
                }
            })
        }
    }
}

extension TabBarController: STABannerDelegateProtocol {

    func didDisplayBannerAd(_ banner: STABannerView!) {
        Preferences.set(.adBannerHeight, to: Int(banner.frame.size.height))
    }

    func failedLoadBannerAd(_ banner: STABannerView!, withError error: Error!) {
        Preferences.set(.adBannerHeight, to: 0)
    }

    // Set container view on top of tab bar, and add banner inside it
    func setBannerConstraints() {
        guard let bannerAd = bannerAd, let adContainerView = adContainerView else { return }

        bannerAd.setSTABannerSize(STA_AutoAdSize)

        constrain(adContainerView, bannerAd, replace: bannerGroup) { container, banner in

            container.leading ~== container.superview!.leading
            container.trailing ~== container.superview!.trailing
            container.bottom ~== container.superview!.bottom - tabBar.frame.height
            container.height ~== 90 ~~ 50

            banner.leading ~== banner.superview!.leading
            banner.trailing ~== banner.superview!.trailing
            banner.bottom ~== banner.superview!.bottom
        }
    }

    // React to orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.setBannerConstraints()
        }, completion: nil)
    }
}

extension TabBarController {

    func showInterstitialIfReady() {
        guard let interstitialAd = interstitialAd, interstitialReady, Int.random(in: 1..<4) == 3 else { return }
        interstitialReady = false
        interstitialAd.show()
        // Wait 30 seconds before showing a new interstitial ad
        delay(30) {
            self.interstitialReady = true
        }
    }
}
