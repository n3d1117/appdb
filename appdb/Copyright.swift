//
//  Copyright.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class Copyright: FeaturedCell {
    
    var copyrightNotice: UILabel!
    
    override var height: CGFloat { return UITableViewAutomaticDimension }
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: Featured.CellType.copyright.rawValue)
        
        selectionStyle = .none
        separatorInset.left = 10000
        layoutMargins = .zero
        theme_backgroundColor = Color.tableViewBackgroundColor
        contentView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        // Hide ugly white line on iOS 8
        layer.theme_borderColor = Color.tableViewCGBackgroundColor
        layer.borderWidth = 1.0
        
        copyrightNotice = UILabel()
        copyrightNotice.theme_textColor = Color.copyrightText
        copyrightNotice.font = .systemFont(ofSize: 12)
        let newLine = " " ~~ "\n"
        copyrightNotice.text = "© 2012-\(currentYear) appdb.store.\(newLine)" +
        "We do not host any prohibited content. All data is publicly available via iTunes API.".localized()
        copyrightNotice.numberOfLines = 0
        
        contentView.addSubview(copyrightNotice)
        
        constrain(copyrightNotice) { notice in
            notice.left == notice.superview!.left + Global.size.margin.value
            notice.right == notice.superview!.right - Global.size.margin.value
            notice.top == notice.superview!.top + 15
            notice.bottom == notice.superview!.bottom - (25~~15) ~ 999.0
        }
    }
    
    private var currentYear: String {
        let components = NSCalendar.current.dateComponents([.year], from: Date())
        guard let year = components.year else { return "???" }
        return "\(year)"
    }

}
