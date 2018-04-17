//
//  Settings+Properties.swift
//  appdb
//
//  Created by ned on 16/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import RealmSwift

extension Settings {
    
    var deviceIsLinked: Bool {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return !pref.token.isEmpty
    }
    
    var linkCode: String {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return "~" }
        return pref.linkCode
    }
    
    var appsync: Bool {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.appsync
    }
    
    var ignoresCompatibility: Bool {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.ignoreCompatibility
    }
    
    var askForInstallationOptions: Bool {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return false }
        return pref.askForInstallationOptions
    }
    
}
