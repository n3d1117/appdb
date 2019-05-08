//
//  AppDelegate.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftTheme
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        // Set main tint color
        self.window?.theme_backgroundColor = Color.tableViewBackgroundColor
        self.window?.theme_tintColor = Color.mainTint
        
        // Theme Status Bar
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent], animated: true)
        
        // Theme navigation bar
        let navigationBar = UINavigationBar.appearance()
        let titleAttributes = ["#121212", "#F8F8F8"].map { hexString in
            return [
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
        
        // Realm config
        let dbURL: URL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("db.realm")
        let config = Realm.Configuration(fileURL: dbURL, schemaVersion: 0, migrationBlock: { migration, oldVersion in
            if oldVersion < 1 {
                // Migrate if needed
            }
        })
        Realm.Configuration.defaultConfiguration = config
        //debugLog(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
        
        // Global Operations
        Global.setFirstLaunch()
        Themes.restoreLastTheme()
        
        // Show network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.3
        NetworkActivityIndicatorManager.shared.completionDelay = 0.2
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        // Handle IPA
        if url.isFileURL && IPAFileManager.shared.supportedFileExtensions.contains(url.pathExtension) {
            IPAFileManager.shared.moveToDocuments(url: url)
            guard let tabController = self.window?.rootViewController as? TabBarController else { return false }
            tabController.selectedIndex = 2
            guard let nav = tabController.viewControllers?[2] as? UINavigationController else { return false }
            guard let downloads = nav.viewControllers[0] as? Downloads else { return false }
            downloads.switchToIndex(i: 1)
            return true
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url, sourceApplication: "", annotation: options)
    }

}

