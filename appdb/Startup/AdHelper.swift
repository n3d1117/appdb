//
//  AdHelper.swift
//  appdb
//
//  Created by ned on 03/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Static

enum AdHelper {

    static let appID: String = "YOUR_APP_ID"
    static let devID: String = "YOUR_DEV_ID"

    static var adAwareContentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(Preferences.adBannerHeight), right: 0)
    }

    static func generateBanner(on viewController: UIViewController) -> STABannerView? {
        guard !Preferences.pro else { return nil }
        let banner = STABannerView(size: STA_AutoAdSize, autoOrigin: STAAdOrigin_Bottom, withDelegate: viewController as? STABannerDelegateProtocol)
        debugLog(banner == nil)
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
