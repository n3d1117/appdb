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
        
        let featured = UIStoryboard(name: "Featured", bundle: nil)
        let featuredNav = featured.instantiateViewController(withIdentifier: "FeaturedNavController") as! UINavigationController
        featuredNav.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 1)
        
        //TODO ADD MORE
        
        self.viewControllers = [featuredNav]
    }

}
