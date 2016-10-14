//
//  Banner.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class Banner: FeaturedTableViewCell {

    var testLabel : UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: CellType.banner.rawValue)
        
        backgroundColor = Color.tableViewBackgroundColor
        contentView.backgroundColor = Color.tableViewBackgroundColor
        
        testLabel = UILabel()
        testLabel.text = "wake_me_up_inside.jpg"
        testLabel.textColor = Color.copyrightText
        testLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        testLabel.numberOfLines = 0
        testLabel.sizeToFit()
        
        contentView.addSubview(testLabel)
        
        constrain(testLabel) { label in
            label.center == label.superview!.center
        }
    }

}
