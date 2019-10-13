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

    private var SAInterstitialAd: STAStartAppAd?
    private var SABannerAd: STABannerView?
    private var SAAdContainerView: UIView?

    private var GADInterstitialView: GADInterstitial?
    private var GADBannerView: GADBannerView?

    private var bannerGroup = ConstraintGroup()
    private var interstitialReady: Bool = true

    private var admobBannerFailed: Bool = false
    private var admobInterstitialFailed: Bool = false

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

        SAInterstitialAd = StartAppAdsHelper.generateInterstitial()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        SAInterstitialAd?.load()

        if SABannerAd == nil {
            SABannerAd = StartAppAdsHelper.generateBanner(on: self)

            if let bannerAd = SABannerAd {
                SAAdContainerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: tabBar.frame.origin.y - tabBar.frame.height), size: CGSize(width: view.frame.size.width, height: 90 ~~ 50)))
                SAAdContainerView?.addSubview(bannerAd)
                SAAdContainerView?.alpha = 0
                view.addSubview(SAAdContainerView!)
                setSTABannerConstraints()
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

    // React to orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if self.admobBannerFailed {
                self.setSTABannerConstraints()
            } else {
                self.setGADBannerConstraints()
            }
        }, completion: nil)
    }
}

// MARK: - GADAds

extension TabBarController: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        admobBannerFailed = false
        guard self.GADBannerView != nil else { return }
        bannerView.alpha = 0
        view.addSubview(bannerView)
        setGADBannerConstraints()
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
            self.SAAdContainerView?.alpha = 0
        })
        Preferences.set(.adBannerHeight, to: Int(bannerView.frame.size.height))
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.GADBannerView != nil else { return }
        debugLog("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        admobBannerFailed = true
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
        if admobInterstitialFailed { showSAInterstitialIfReady(); return }
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

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        admobInterstitialFailed = false
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        debugLog("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        admobInterstitialFailed = true
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        GADInterstitialView = GADAdHelper.generateInterstitial(on: self)
    }
}

// MARK: - STAAds

extension TabBarController: STABannerDelegateProtocol {

    func didDisplayBannerAd(_ banner: STABannerView!) {
        if admobBannerFailed {
            GADBannerView?.alpha = 0
            SAAdContainerView?.alpha = 1
            Preferences.set(.adBannerHeight, to: Int(banner.frame.size.height))
        } else {
            SAAdContainerView?.alpha = 0
        }
    }

    func failedLoadBannerAd(_ banner: STABannerView!, withError error: Error!) {
        GADBannerView?.alpha = 0
        SAAdContainerView?.alpha = 0
        Preferences.set(.adBannerHeight, to: 0)
    }

    // Set container view on top of tab bar, and add banner inside it
    func setSTABannerConstraints() {
        guard let bannerAd = SABannerAd, let adContainerView = SAAdContainerView else { return }

        bannerAd.setSTABannerSize(STA_AutoAdSize)

        constrain(adContainerView, bannerAd, replace: bannerGroup) { container, banner in

            container.leading ~== container.superview!.leading
            container.trailing ~== container.superview!.trailing
            container.bottom ~== container.superview!.bottom - tabBar.frame.height
            container.height ~== 90 ~~ 50

            banner.leading ~== banner.superview!.leading
            banner.trailing ~== banner.superview!.trailing
            banner.bottom ~== banner.superview!.bottom
            (banner.top ~== banner.superview!.top) ~ Global.notMaxPriority
        }
    }

    func showSAInterstitialIfReady() {
        guard let interstitialAd = SAInterstitialAd, interstitialReady, Int.random(in: 1..<4) == 3 else { return }
        interstitialReady = false
        interstitialAd.show()
        // Wait 30 seconds before showing a new interstitial ad
        delay(30) {
            self.interstitialReady = true
        }
    }
}
