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
        
        let featuredNav: UINavigationController = UINavigationController(rootViewController: Featured())
        featuredNav.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        
        /*let searchNav: UINavigationController = UINavigationController(rootViewController: Search())
        searchNav.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)*/
        
        // TODO ADD MORE
        
        self.viewControllers = [featuredNav/*, searchNav*/]
    }

}
