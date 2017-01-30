//
//  BBTabBarController.swift
//  appdb
//
//  Created by ned on 10/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let featuredNav : UINavigationController = UINavigationController(rootViewController: Featured())
        featuredNav.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
        
        // TODO ADD MORE
        
        self.viewControllers = [featuredNav]
    }

}
