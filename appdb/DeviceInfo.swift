//
//  Settings+Properties.swift
//  appdb
//
//  Created by ned on 16/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import RealmSwift

struct DeviceInfo {
    
    static let realm = try! Realm()
    
    static var deviceIsLinked: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return !pref.token.isEmpty
    }
    
    static var pro: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.pro
    }
    
    static var proUntil: String {
        guard let pref = realm.objects(Preferences.self).first else { return "" }
        return pref.proUntil
    }
    
    static var proDisabled: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.proDisabled
    }
    
    static var proRevoked: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.proRevoked
    }
    
    static var proRevokedOn: String {
        guard let pref = realm.objects(Preferences.self).first else { return "" }
        return pref.proRevokedOn
    }
    
    static var linkCode: String {
        guard let pref = realm.objects(Preferences.self).first else { return "~" }
        return pref.linkCode
    }
    
    static var linkToken: String {
        guard let pref = realm.objects(Preferences.self).first else { return "" }
        return pref.token
    }
    
    static var appsync: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.appsync
    }
    
    static var ignoresCompatibility: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.ignoreCompatibility
    }
    
    static var askForInstallationOptions: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.askForInstallationOptions
    }
    
    static var showBadgeForUpdates: Bool {
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.showBadgeForUpdates
    }
    
}
