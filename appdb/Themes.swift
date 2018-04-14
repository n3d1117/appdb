//
//  Themes.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import RealmSwift
import SwiftTheme

enum Themes: Int {
    
    case Light = 0
    case Dark = 1

    static var current: Themes { return Themes(rawValue: ThemeManager.currentThemeIndex)! }
    
    // MARK: - Switch Theme
    
    static func switchTo(theme: Themes) {
        ThemeManager.setTheme(index: theme.rawValue)
        saveCurrentTheme()
    }

    static var isNight: Bool { return current == .Dark }
    
    // MARK: - Save & Restore
    
    static func saveCurrentTheme() {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first {
            try! realm.write { pref.theme = ThemeManager.currentThemeIndex }
        }
    }
    
    static func restoreLastTheme() {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first {
            switchTo(theme: Themes(rawValue: pref.theme)!)
        } else {
            switchTo(theme: Themes(rawValue: 0)!)
        }
    }
    
}

