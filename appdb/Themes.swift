//
//  Themes.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

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
        Preferences.set(.theme, to: ThemeManager.currentThemeIndex)
    }
    
    static func restoreLastTheme() {
        guard let theme = Themes(rawValue: Preferences.theme) else { return }
        switchTo(theme: theme)
    }
    
}

