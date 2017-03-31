//
//  Details+ExternalLink.swift
//  appdb
//
//  Created by ned on 05/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DetailsExternalLink: DetailsCell {
    
    override var height: CGFloat { return 45 }
    override var identifier: String { return "link" }
    
    convenience init(text: String) {
        self.init(style: .default, reuseIdentifier: "link")

        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        accessoryType = .disclosureIndicator
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        
        textLabel?.text = text.localized()
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.theme_textColor = Color.title
    
    }
    
}
