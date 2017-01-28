//
//  AppDelegate.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window!.rootViewController = TabBarController()
        self.window!.makeKeyAndVisible()
        
        Themes.restoreLastTheme()
        
        // Set main tint color
        self.window!.theme_tintColor = Color.mainTint
        
        //Theme Status Bar
        UIApplication.shared.theme_setStatusBarStyle([.default, .lightContent], animated: true)
        
        // Theme navigation bar
        let navigationBar = UINavigationBar.appearance()
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        let titleAttributes: [[String: AnyObject]] = ["#121212", "#F8F8F8"].map { hexString in
            return [
                NSForegroundColorAttributeName: UIColor(rgba: hexString),
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
                NSShadowAttributeName: shadow
            ]
        }
        
        navigationBar.isTranslucent = true
        navigationBar.theme_barStyle = [.default, .black]
        navigationBar.theme_tintColor = Color.mainTint
        navigationBar.theme_titleTextAttributes = ThemeDictionaryPicker.pickerWithDicts(titleAttributes)
        
        // Theme Tab Bar
        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = true
        tabBar.theme_barStyle = [.default, .black]
        
        // Show network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.3
        NetworkActivityIndicatorManager.shared.completionDelay = 0.3
        
        // Realm config
        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in }
        )
        Realm.Configuration.defaultConfiguration = config
        
        //Log.debug(Realm.Configuration.defaultConfiguration.fileURL)

        return true
    }

}

