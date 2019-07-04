//
//  BBTabBarController.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Cartography

class TabBarController: UITabBarController {

    private var interstitialView: GADInterstitial?
    private var bannerView: GADBannerView?
    private var bannerGroup = ConstraintGroup()

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

        bannerView = AdHelper.generateBanner(on: self)
        interstitialView = AdHelper.generateInterstitial(on: self)
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

extension TabBarController: GADBannerViewDelegate {

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.bannerView != nil else { return }
        Preferences.set(.adBannerHeight, to: 0)
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard self.bannerView != nil else { return }
        bannerView.alpha = 0
        view.addSubview(bannerView)
        constrainBanner()
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
        })
        Preferences.set(.adBannerHeight, to: Int(bannerView.frame.size.height))
    }

    func constrainBanner() {
        guard let bannerView = bannerView else { return }
        constrain(bannerView, replace: bannerGroup) { banner in
            banner.leading ~== banner.superview!.leading
            banner.trailing ~== banner.superview!.trailing
            banner.bottom ~== banner.superview!.bottom - tabBar.frame.height
        }
    }

    // React to orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard let bannerView = self.bannerView else { return }
            if bannerView.isDescendant(of: self.view) {
                bannerView.adSize = AdHelper.adSize
                self.constrainBanner()
            }
        }, completion: nil)
    }
}

extension TabBarController: GADInterstitialDelegate {

    func showInterstitialIfReady() {
        guard let interstitialView = interstitialView else { return }
        if interstitialView.isReady, Bool.random() {
            interstitialView.present(fromRootViewController: self)
        }
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialView = AdHelper.generateInterstitial(on: self)
    }
}
