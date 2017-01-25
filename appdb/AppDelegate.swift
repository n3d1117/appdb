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
        
        // Set main tint color
        self.window!.tintColor = Color.mainTint
        
        // Show network activity indicator
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.3
        NetworkActivityIndicatorManager.shared.completionDelay = 0.3
        
        let config = Realm.Configuration(
            schemaVersion: 0,
            migrationBlock: { migration, oldSchemaVersion in }
        )
        Realm.Configuration.defaultConfiguration = config
        
        //Log.debug(Realm.Configuration.defaultConfiguration.fileURL)

        return true
    }

}

