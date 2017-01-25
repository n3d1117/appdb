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
    
    var name : UILabel!
    var icon : UIImageView!
    
    var didSetupConstraints = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.preservesSuperviewLayoutMargins = false
        preservesSuperviewLayoutMargins = false
        
        layoutMargins.left = Featured.size.margin.value
        separatorInset.left = Featured.size.margin.value
        
        icon = UIImageView()
        
        if reuseIdentifier == "category_ios" {
            icon.layer.cornerRadius = cornerRadius(fromWidth: 30)
            icon.layer.masksToBounds = true
            icon.image = #imageLiteral(resourceName: "placeholderIcon")
        } else {
            icon.layer.cornerRadius = 0
            icon.layer.masksToBounds = true
            icon.image = #imageLiteral(resourceName: "placeholderCover")
        }
        
        icon.layer.borderWidth = 0.5
        icon.layer.borderColor = Color.borderColor.cgColor
        
        name = UILabel()
        name.textColor = .black
        name.font = UIFont.systemFont(ofSize: 17~~16)
        name.numberOfLines = 1
        
        addSubview(icon)
        addSubview(name)
        
        setConstraints()
    }
    
    func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(icon, name) { icon, name in
                
                icon.width == 30
                
                if reuseIdentifier == "category_ios" { icon.height == icon.width }
                else if reuseIdentifier == "category_books" { icon.height == icon.width * 1.542 }
                
                icon.left == icon.superview!.left + Featured.size.margin.value
                icon.centerY == icon.superview!.centerY
                
                name.left == icon.right + 10
                name.centerY == icon.centerY
                
            }
        }
    }

}
