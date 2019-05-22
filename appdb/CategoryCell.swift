//
//  CategoryCell.swift
//  appdb
//
//  Created by ned on 23/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class CategoryCell: UITableViewCell {
    
    var name: UILabel!
    var icon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Margins
        contentView.preservesSuperviewLayoutMargins = false
        preservesSuperviewLayoutMargins = false
        layoutMargins.left = Global.size.margin.value
        separatorInset.left = Global.size.margin.value
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
  
        // Icon
        icon = UIImageView()
        if reuseIdentifier == "category_ios" {
            icon.layer.cornerRadius = Global.cornerRadius(from: 30)
            icon.image = #imageLiteral(resourceName: "placeholderIcon")
        } else {
            icon.layer.cornerRadius = 0
            icon.image = #imageLiteral(resourceName: "placeholderCover")
        }
        icon.layer.borderWidth = 0.5
        icon.layer.theme_borderColor = Color.borderCgColor
        
        // Name
        name = UILabel()
        name.font = .systemFont(ofSize: (17~~16))
        name.numberOfLines = 1
        name.makeDynamicFont()
        
        contentView.addSubview(icon)
        contentView.addSubview(name)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        constrain(icon, name) { icon, name in
            
            icon.width ~== 30
            
            if reuseIdentifier == "category_ios" { icon.height ~== icon.width }
            else if reuseIdentifier == "category_books" { icon.height ~== icon.width ~* 1.542 }
            
            icon.left ~== icon.superview!.left ~+ Global.size.margin.value
            icon.centerY ~== icon.superview!.centerY
            
            name.left ~== icon.right ~+ 10
            name.centerY ~== icon.centerY
            
        }
    }

}
