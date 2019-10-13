//
//  AdHelper.swift
//  appdb
//
//  Created by ned on 03/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Static
import GoogleMobileAds

enum AdHelper {

    static let startAppAppID: String = "STARTAPP_APP_ID"
    static let startAppDevID: String = "STARTAPP_DEV_ID"

    static let GADAdBannerUnitID: String = "GADBANNER_ID"
    static let GADAdInterstitialUnitID: String = "GADINTERSTITIAL_ID"

    static var adAwareContentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Preferences.adBannerHeight), right: 0)
    }
}

enum GADAdHelper {

    static var GADAdSize: GADAdSize {
        return UIApplication.shared.statusBarOrientation.isLandscape ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait
    }

    static func generateBanner(on viewController: UIViewController) -> GADBannerView? {
        guard !Preferences.pro else { return nil }
        let banner = GADBannerView(adSize: GADAdHelper.GADAdSize)
        banner.delegate = viewController as? GADBannerViewDelegate
        banner.adUnitID = AdHelper.GADAdBannerUnitID
        banner.rootViewController = viewController
        let request = GADRequest()
        banner.load(request)
        banner.alpha = 0
        return banner
    }

    static func generateInterstitial(on viewController: UIViewController) -> GADInterstitial? {
        guard !Preferences.pro else { return nil }
        let interstitial = GADInterstitial(adUnitID: AdHelper.GADAdInterstitialUnitID)
        interstitial.delegate = viewController as? GADInterstitialDelegate
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
}

enum StartAppAdsHelper {
    static func generateBanner(on viewController: UIViewController) -> STABannerView? {
        guard !Preferences.pro else { return nil }
        let banner = STABannerView(size: STA_AutoAdSize, autoOrigin: STAAdOrigin_Bottom, withDelegate: viewController as? STABannerDelegateProtocol)
        return banner
    }

    static func generateInterstitial() -> STAStartAppAd? {
        guard !Preferences.pro else { return nil }
        let interstitial = STAStartAppAd()
        return interstitial
    }
}

protocol AdAware: class {
    func adMobAdjustContentInsetsIfNeeded()
}

extension UITableViewController: AdAware {
    func adMobAdjustContentInsetsIfNeeded() {
        guard !Preferences.pro else { return }
        guard let tableView = tableView else { return }
        guard !(UIApplication.topNavigation(UIApplication.topViewController()) is DismissableModalNavController) else { return }
        tableView.contentInset = AdHelper.adAwareContentInsets
        tableView.scrollIndicatorInsets = AdHelper.adAwareContentInsets
    }
}

extension UICollectionViewController: AdAware {
    func adMobAdjustContentInsetsIfNeeded() {
        guard !Preferences.pro else { return }
        guard let collectionView = collectionView else { return }
        guard !(UIApplication.topNavigation(UIApplication.topViewController()) is DismissableModalNavController) else { return }
        collectionView.contentInset = AdHelper.adAwareContentInsets
        collectionView.scrollIndicatorInsets = AdHelper.adAwareContentInsets
    }
}

extension TableViewController: AdAware {
    func adMobAdjustContentInsetsIfNeeded() {
        guard !Preferences.pro else { return }
        guard !(UIApplication.topNavigation(UIApplication.topViewController()) is DismissableModalNavController) else { return }
        tableView.contentInset = AdHelper.adAwareContentInsets
        tableView.scrollIndicatorInsets = AdHelper.adAwareContentInsets
    }
}
