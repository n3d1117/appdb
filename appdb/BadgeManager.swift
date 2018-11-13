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
}

extension UIViewController: BadgeManager {
    
    func updateBadge(with text: Any? = nil, for tab: BadgeableTabs) {
        let badge = text == nil ? nil : "\(text!)"
        tabBarController?.tabBar.items?[tab.rawValue].badgeValue = badge
    }
    
}
