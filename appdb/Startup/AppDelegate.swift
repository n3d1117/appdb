//
//  AppDelegate.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import SwiftTheme
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    var window: UIWindow?

    func applicationWillTerminate(_ application: UIApplication) {
        IPAFileManager.shared.clearTmpDirectory()
        //IPAFileManager.shared.clearCacheDirectory()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()

        // Global Operations
        Global.deleteEventualKeychainData()
        Global.restoreLanguage()
        Themes.restoreLastTheme()

        // Set main tint color
        self.window?.theme_backgroundColor = Color.tableViewBackgroundColor
        self.window?.theme_tintColor = Color.mainTint

        // Theme Status Bar
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent], animated: true)

        // Theme navigation bar
        let navigationBar = UINavigationBar.appearance()
        let titleAttributes = Color.navigationBarTextColor.map { hexString in
            [
                AttributedStringKey.foregroundColor: UIColor(rgba: hexString),
                AttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.5)
            ]
        }
        navigationBar.theme_barStyle = [.default, .black]
        navigationBar.theme_tintColor = Color.mainTint
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithAttributes(titleAttributes)

        // Theme Tab Bar
        let tabBar = UITabBar.appearance()
        tabBar.theme_barStyle = [.default, .black]

        // Theme UISwitch
        UISwitch.appearance().theme_onTintColor = Color.mainTint

        // Show network activity indicator
        NetworkActivityIndicatorManager.shared.startDelay = 0.3
        NetworkActivityIndicatorManager.shared.isEnabled = true

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Handle IPA
        if url.isFileURL && IPAFileManager.shared.supportedFileExtensions.contains(url.pathExtension) {
            IPAFileManager.shared.moveToDocuments(url: url)
            guard let tabController = window?.rootViewController as? TabBarController else { return false }
            tabController.selectedIndex = 2
            guard let nav = tabController.viewControllers?[2] as? UINavigationController else { return false }
            guard let downloads = nav.viewControllers[0] as? Downloads else { return false }
            downloads.switchToIndex(i: 1)
            return true
        }

        // URL Schemes
        if let queryItems = NSURLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            return decodeUrlScheme(from: queryItems)
        }

        return false
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return application(app, open: url, sourceApplication: "", annotation: options)
    }

    // MARK: - URL Schemes

    private func decodeUrlScheme(from queryItems: [URLQueryItem]) -> Bool {
        guard let tab = window?.rootViewController as? TabBarController else { return false }

        // Tab selection, e.g. appdb2://?tab=search

        if let index = queryItems.firstIndex(where: { $0.name == "tab" }) {
            guard let value = queryItems[index].value else { return false }

            dismissCurrentNavIfAny()

            switch value {
            case "featured":
                tab.selectedIndex = 0
            case "search":
                tab.selectedIndex = 1
            case "downloads":
                tab.selectedIndex = 2
            case "settings":
                tab.selectedIndex = 3
            case "updates":
                tab.selectedIndex = 4
            case "news":
                tab.selectedIndex = 3
                guard let nav = tab.viewControllers?[3] as? UINavigationController else { break }
                guard let settings = nav.viewControllers[0] as? Settings else { break }
                settings.pushNews()
            case "system_status":
                tab.selectedIndex = 3
                guard let nav = tab.viewControllers?[3] as? UINavigationController else { break }
                guard let settings = nav.viewControllers[0] as? Settings else { break }
                settings.pushSystemStatus()
            case "device_status":
                tab.selectedIndex = 3
                guard let nav = tab.viewControllers?[3] as? UINavigationController else { break }
                guard let settings = nav.viewControllers[0] as? Settings else { break }
                settings.pushDeviceStatus()
            default: break
            }

            return true
        }

        // Open details page, e.g. appdb2://?trackid=x&type=ios

        if let index1 = queryItems.firstIndex(where: { $0.name == "trackid" }), let index2 = queryItems.firstIndex(where: { $0.name == "type" }) {
            guard let trackid = queryItems[index1].value, let typeString = queryItems[index2].value else { return false }
            guard let nav = tab.viewControllers?[0] as? UINavigationController else { return false }
            guard let type = ItemType(rawValue: typeString) else { return false }

            tab.selectedIndex = 0

            let vc = Details(type: type, trackid: trackid)

            if Global.isIpad {
                if let presented = nav.topViewController?.presentedViewController as? DismissableModalNavController {
                    // Already showing an app, add to stack
                    if presented.topViewController is Details {
                        presented.pushViewController(vc, animated: true)
                    } else {
                        dismissCurrentNavIfAny()
                        let navController = DismissableModalNavController(rootViewController: vc)
                        navController.modalPresentationStyle = .formSheet
                        nav.present(navController, animated: true)
                    }
                } else {
                    let navController = DismissableModalNavController(rootViewController: vc)
                    navController.modalPresentationStyle = .formSheet
                    nav.present(navController, animated: true)
                }
            } else {
                nav.pushViewController(vc, animated: true)
            }

            return true
        }

        // Search query with type, e.g. appdb2://?q=Facebook&type=ios

        if let index1 = queryItems.firstIndex(where: { $0.name == "q" }), let index2 = queryItems.firstIndex(where: { $0.name == "type" }) {
            guard let query = queryItems[index1].value, let typeString = queryItems[index2].value else { return false }
            guard let type = ItemType(rawValue: typeString) else { return false }

            dismissCurrentNavIfAny()

            tab.selectedIndex = 1

            guard let nav = tab.viewControllers?[1] as? UINavigationController else { return false }
            guard let search = nav.viewControllers[0] as? Search else { return false }

            delay(0.7) {
                search.setItemTypeAndSearch(type: type, query: query)
            }

            return true
        }

        // Open news with id, e.g. appdb2://?news_id=x

        if let index1 = queryItems.firstIndex(where: { $0.name == "news_id" }) {
            guard let id = queryItems[index1].value else { return false }

            dismissCurrentNavIfAny()

            tab.selectedIndex = 3
            guard let nav = tab.viewControllers?[3] as? UINavigationController else { return false }
            guard let settings = nav.viewControllers[0] as? Settings else { return false }
            settings.pushNews()

            let newsDetailViewController = NewsDetail(with: id)

            if Global.isIpad {
                delay(1) {
                    if let presented = nav.topViewController?.presentedViewController as? DismissableModalNavController {
                        presented.pushViewController(newsDetailViewController, animated: true)
                    }
                }
            } else {
                nav.pushViewController(newsDetailViewController, animated: true)
            }

            return true
        }

        // Open url in IPAWebViewController, e.g. appdb2://?url=https://google.com

        if let index1 = queryItems.firstIndex(where: { $0.name == "url" }) {
            guard let urlString = queryItems[index1].value, let url = URL(string: urlString) else { return false }

            dismissCurrentNavIfAny()

            tab.selectedIndex = 2

            guard let nav = tab.viewControllers?[2] as? UINavigationController else { return false }
            guard let downloads = nav.viewControllers[0] as? Downloads else { return false }

            let webVc = IPAWebViewController(delegate: downloads, url: url)
            let navController = IPAWebViewNavController(rootViewController: webVc)
            downloads.present(navController, animated: true)

            return true
        }

        // Authorize app with link code, e.g. appdb2://?action=authorize&code=x

        if let index1 = queryItems.firstIndex(where: { $0.name == "action" }), let index2 = queryItems.firstIndex(where: { $0.name == "code" }) {
            guard let action = queryItems[index1].value, let code = queryItems[index2].value else { return false }
            guard action == "authorize", !code.isEmpty, !Preferences.deviceIsLinked else { return false }

            dismissCurrentNavIfAny()

            tab.selectedIndex = 3

            guard let nav = tab.viewControllers?[3] as? UINavigationController else { return false }
            guard let settings = nav.viewControllers[0] as? Settings else { return false }

            delay(0.5) {
                settings.showlinkCodeFromURLSchemeBulletin(code: code)
            }

            return true
        }

        return false
    }

    private func dismissCurrentNavIfAny() {
        guard let tab = window?.rootViewController as? TabBarController else { return }

        if Global.isIpad, let currentNav = (tab.viewControllers?[tab.selectedIndex] as? UINavigationController)?.topViewController?.presentedViewController as? UINavigationController {
            currentNav.dismiss(animated: true)
        }

        if tab.selectedIndex == 3 {
            guard let nav = tab.viewControllers?[3] as? UINavigationController else { return }
            guard let settings = nav.viewControllers[0] as? Settings else { return }

            DispatchQueue.main.async {
                if settings.deviceLinkBulletinManager.isShowingBulletin {
                    settings.deviceLinkBulletinManager.dismissBulletin()
                } else if settings.deauthorizeBulletinManager.isShowingBulletin {
                    settings.deauthorizeBulletinManager.dismissBulletin()
                }
            }
        }
    }
}
