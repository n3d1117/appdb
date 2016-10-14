//
//  Copyright.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class Copyright: FeaturedTableViewCell {
    
    var copyrightNotice : UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: CellType.copyright.rawValue)
        
        selectionStyle = .none
        separatorInset.left = 10000
        backgroundColor = Color.tableViewBackgroundColor
        contentView.backgroundColor = Color.tableViewBackgroundColor
        
        // Hide ugly white line on iOS 8
        layer.borderColor = Color.tableViewBackgroundColor.cgColor
        layer.borderWidth = 1.0
        
        copyrightNotice = UILabel()
        copyrightNotice.textColor = Color.copyrightText
        copyrightNotice.font = UIFont.systemFont(ofSize: 11.3)
        let newLine = " " ~~ "\n"
        copyrightNotice.text = "© 2012-\(getCurrentYear()) appdb.cc.\(newLine)" +
        "We do not host any prohibited content. All data is publicly available via iTunes API."
        copyrightNotice.numberOfLines = 0
        copyrightNotice.sizeToFit()
        
        contentView.addSubview(copyrightNotice)
        
        constrain(copyrightNotice) { notice in
            notice.left == notice.superview!.left + common.size.margin.value
            notice.right == notice.superview!.right - common.size.margin.value
            notice.top == notice.superview!.top + 15.0
        }
    }
    
    private func getCurrentYear() -> String {
        let components = NSCalendar.current.dateComponents([.year], from: NSDate() as Date)
        return "\(components.year!)"
    }

}
