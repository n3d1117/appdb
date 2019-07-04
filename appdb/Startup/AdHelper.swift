//
//  AdHelper.swift
//  appdb
//
//  Created by ned on 03/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import GoogleMobileAds
import Static

enum AdHelper {

    static let bannerUnitID: String = "YOUR_BANNER_ID"
    static let interstitialUnitID: String = "YOUR_INTERSTITIAL_ID"

    static var adSize: GADAdSize {
        return UIApplication.shared.statusBarOrientation.isLandscape ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait
    }

    static var adAwareContentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Preferences.adBannerHeight), right: 0)
    }

    static func generateBanner(on viewController: UIViewController) -> GADBannerView? {
        guard !Preferences.pro else { return nil }
        let banner = GADBannerView(adSize: AdHelper.adSize)
        banner.delegate = viewController as? GADBannerViewDelegate
        banner.adUnitID = AdHelper.bannerUnitID
        banner.rootViewController = viewController
        let request = GADRequest()
        #if DEBUG
        request.testDevices = [kGADSimulatorID]
        #endif
        banner.load(request)
        return banner
    }

    static func generateInterstitial(on viewController: UIViewController) -> GADInterstitial? {
        guard !Preferences.pro else { return nil }
        let interstitial = GADInterstitial(adUnitID: AdHelper.interstitialUnitID)
        interstitial.delegate = viewController as? GADInterstitialDelegate
        let request = GADRequest()
        #if DEBUG
        request.testDevices = [kGADSimulatorID]
        #endif
        interstitial.load(request)
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
