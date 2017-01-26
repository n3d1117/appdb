//
//  Colors.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit

enum Color {
    static let mainTint: UIColor = { return UIColor(red: 68/255, green: 108/255, blue: 179/255, alpha: 1.0) }()
    static let darkGray: UIColor = { return UIColor(red: 111/255, green: 113/255, blue: 121/255, alpha: 1.0) }()
    static let tableViewBackgroundColor: UIColor = { return UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1) }()
    static let borderColor: UIColor = { return UITableView().separatorColor }()!
    static let copyrightText: UIColor = { return UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 1) }()
    static let veryVeryLightGray: UIColor = { return UIColor(red: 253/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1) }()
}
