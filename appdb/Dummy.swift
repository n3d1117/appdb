//
//  Dummy.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class Dummy: FeaturedTableViewCell {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: CellType.dummy.rawValue)
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset.left = 0
        layoutMargins.left = 0
        contentView.backgroundColor = Color.tableViewBackgroundColor
    }

}
