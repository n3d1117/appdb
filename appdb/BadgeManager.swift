//
//  BadgeManager.swift
//  appdb
//
//  Created by ned on 11/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

enum BadgeableTabs: Int {
    case downloads = 2 // third tab
    case updates = 4 // fifth tab
}

protocol BadgeManager {
    func updateBadge(with: Any?, for: BadgeableTabs)
    func badgeAddOne(for tab: BadgeableTabs)
    func badgeSubtractOne(for tab: BadgeableTabs)
}

extension UIViewController: BadgeManager {
    
    // Set badge value
    func updateBadge(with text: Any? = nil, for tab: BadgeableTabs) {
        let badge = text == nil ? nil : "\(text!)"
        (tabBarController ?? self as? UITabBarController)?.tabBar.items?[tab.rawValue].badgeValue = badge
    }
    
    // Badge += 1
    func badgeAddOne(for tab: BadgeableTabs) {
        guard let item = (tabBarController ?? self as? UITabBarController)?.tabBar.items?[tab.rawValue] else { return }
        guard let currentIntValue = Int(item.badgeValue ?? "0") else { return }
        item.badgeValue = "\(currentIntValue + 1)"
    }
    
    // Badge -= 1
    func badgeSubtractOne(for tab: BadgeableTabs) {
        guard let item = (tabBarController ?? self as? UITabBarController)?.tabBar.items?[tab.rawValue] else { return }
        guard let currentIntValue = Int(item.badgeValue ?? "0") else { return }
        let newValue = currentIntValue - 1 <= 0 ? nil : currentIntValue - 1
        item.badgeValue = newValue == nil ? nil : "\(newValue!)"
    }
    
}
