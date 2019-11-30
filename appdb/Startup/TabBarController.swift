//
//  BBTabBarController.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import GoogleMobileAds

class TabBarController: UITabBarController {

    private var GADInterstitialView: GADInterstitial?
    private var GADBannerView: GADBannerView?

    private var bannerGroup = ConstraintGroup()
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

        GADBannerView = GADAdHelper.generateBanner(on: self)
        GADInterstitialView = GADAdHelper.generateInterstitial(on: self)
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

    // React to orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.setGADBannerConstraints()
        }, completion: nil)
    }
}

// MARK: - GADAds

extension TabBarController: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard self.GADBannerView != nil else { return }
        bannerView.alpha = 0
        view.addSubview(bannerView)
        setGADBannerConstraints()
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
        })
        Preferences.set(.adBannerHeight, to: Int(bannerView.frame.size.height))
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.GADBannerView != nil else { return }
        debugLog("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        GADBannerView?.alpha = 0
    }

    func setGADBannerConstraints() {
        guard let bannerView = GADBannerView, bannerView.superview != nil else { return }
        bannerView.adSize = GADAdHelper.GADAdSize
        constrain(bannerView, replace: bannerGroup) { banner in
            banner.leading ~== banner.superview!.leading
            banner.trailing ~== banner.superview!.trailing
            banner.bottom ~== banner.superview!.bottom - tabBar.frame.height
        }
    }
}

extension TabBarController: GADInterstitialDelegate {

    func showGADInterstitialIfReady() {
        guard let interstitialView = GADInterstitialView else { return }
        if interstitialReady, interstitialView.isReady, Int.random(in: 1..<4) == 3 {
            interstitialReady = false
            interstitialView.present(fromRootViewController: self)
            // Wait 30 seconds before showing a new interstitial ad
            delay(30) {
                self.interstitialReady = true
            }
        }
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        debugLog("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        GADInterstitialView = GADAdHelper.generateInterstitial(on: self)
    }
}
