//
//  Preferences.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Preferences: Object {

    @objc dynamic var theme: Int = 0
    @objc dynamic var isFirstLaunch: Bool = false
    @objc dynamic var didSpecifyPreferredLanguage: Bool = false
    
    @objc dynamic var token: String = ""
    @objc dynamic var linkCode: String = ""
    
    @objc dynamic var appsync: Bool = false
    @objc dynamic var ignoreCompatibility: Bool = false
    @objc dynamic var askForInstallationOptions: Bool = false
    @objc dynamic var showBadgeForUpdates: Bool = true
    
    @objc dynamic var pro: Bool = false
    @objc dynamic var proDisabled: Bool = false
    @objc dynamic var proUntil: String = ""
    @objc dynamic var proRevoked: Bool = false
    @objc dynamic var proRevokedOn: String = ""
    
}
