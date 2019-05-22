//
//  Details+DownloadEmptyCell.swift
//  appdb
//
//  Created by ned on 30/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift

class DetailsDownloadEmptyCell: DetailsCell {
    
    static var height: CGFloat { return 170 }
    override var identifier: String { return "downloademptycell" }
    
    var error: UILabel!

    convenience init(_ message: String) {
        self.init(style: .default, reuseIdentifier: "downloademptycell")
        
        preservesSuperviewLayoutMargins = false
        accessoryType = .none
        selectionStyle = .none
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        error = UILabel()
        error.font = .systemFont(ofSize: (23~~22))
        error.makeDynamicFont()
        error.numberOfLines = 0
        error.theme_textColor = Color.darkGray
        error.text = message.localized()
        
        contentView.addSubview(error)
        
        setConstraints()
    }
    
    override func setConstraints() {
        constrain(error) { error in
            error.center ~== error.superview!.center
        }
    }
}
