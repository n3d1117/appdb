//
//  BBTabBarController.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let featuredNav = UINavigationController(rootViewController: Featured())
        featuredNav.tabBarItem = UITabBarItem(title: "Featured".localized(), image: #imageLiteral(resourceName: "featured"), tag: 0)

        let searchNav = UINavigationController(rootViewController: Search())
        searchNav.tabBarItem = UITabBarItem(title: "Search".localized(), image: #imageLiteral(resourceName: "search"), tag: 1)

        let downloadsNav = UINavigationController(rootViewController: Downloads())
        downloadsNav.tabBarItem = UITabBarItem(title: "Downloads".localized(), image: #imageLiteral(resourceName: "downloads"), tag: 2)

        let settingsNav = UINavigationController(rootViewController: Settings())
        settingsNav.tabBarItem = UITabBarItem(title: "Settings".localized(), image: #imageLiteral(resourceName: "settings"), tag: 3)

        let updatesNav = UINavigationController(rootViewController: Updates())
        updatesNav.tabBarItem = UITabBarItem(title: "Updates".localized(), image: #imageLiteral(resourceName: "updates"), tag: 4)

        viewControllers = [featuredNav, searchNav, downloadsNav, settingsNav, updatesNav]
    }

    // Bounce animation
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if !Global.isIpad, let view = item.value(forKey: "view") as? UIView, let image = view.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.1, animations: {
                image.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    image.transform = .identity
                }
            })
        }
    }
}
