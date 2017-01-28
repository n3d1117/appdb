//
//  Themes.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift

enum Themes: Int {
    
    case Light = 0
    case Dark = 1

    static var current: Themes { return Themes(rawValue: ThemeManager.currentThemeIndex)! }
    
    // MARK: - Switch Theme
    
    static func switchTo(theme: Themes) {
        ThemeManager.setTheme(index: theme.rawValue)
        saveLastTheme()
    }

    static var isNight : Bool { return current == .Dark }
    
    // MARK: - Save & Restore
    
    static func saveLastTheme() {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first {
            try! realm.write { pref.theme = ThemeManager.currentThemeIndex }
        } else {
            let pref = Preferences()
            pref.theme = ThemeManager.currentThemeIndex
            try! realm.write { realm.add(pref) }
        }
    }
    
    static func restoreLastTheme() {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first {
            switchTo(theme: Themes(rawValue: pref.theme)!)
        }
    }
    
}

