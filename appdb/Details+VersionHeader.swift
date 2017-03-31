//
//  Details+VersionHeader.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class DetailsVersionHeader: TableViewHeader {
    
    var version: UILabel!
    static var height: CGFloat { return 25 }
    private let backgroundGray: ThemeColorPicker = ["#E3E3E3", "#3E3E3E"]
    
    convenience init(_ versionNumber: String, isLatest: Bool) {
        self.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = false
        layoutMargins.left = 0
        addSeparator(full: true)
        
        contentView.theme_backgroundColor = backgroundGray
        
        version = UILabel()
        version.font = UIFont.systemFont(ofSize: (17~~16))
        version.numberOfLines = 1
        version.theme_textColor = Color.title
        version.text = versionNumber

        contentView.addSubview(version)
        
        constrain(version) { version in
            version.left == version.superview!.left + Featured.size.margin.value
            version.centerY == version.superview!.centerY
        }
    }
    
}
