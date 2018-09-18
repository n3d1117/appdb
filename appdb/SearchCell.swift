//
//  SearchCell.swift
//  appdb
//
//  Created by ned on 11/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class SearchCell: UICollectionViewCell {
    
    func setConstraints() {}
    
    var magic: CGFloat { return 0 }

    var identifier: String { return "" }
    var height: CGFloat { return 0 }
    
    var compactPortraitSize: CGFloat { return 0 }
    var portraitSize: CGFloat { return 0 }
    var mixedPortraitSize: CGFloat { return 0 }
    
    var landscapeSize: CGFloat = (150~~140)
    var iconSize: CGFloat = (85~~70)
    var spaceFromIcon: CGFloat = (15~~12)
    
    var margin: CGFloat = Global.size.margin.value
    
    var name: UILabel!
    var icon: UIImageView!
    var seller: UILabel!
    
    func sharedSetup() {
        theme_backgroundColor = Color.softGreen
        contentView.theme_backgroundColor = Color.softGreen
        
        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18.5~~16.5)
        name.numberOfLines = 3
        name.text = "fuck"
        name.makeDynamicFont()
        
        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.image = #imageLiteral(resourceName: "placeholderIcon")
        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)
        
        // Seller
        seller = UILabel()
        seller.theme_textColor = Color.darkGray
        seller.font = .systemFont(ofSize: 15~~13)
        seller.numberOfLines = 1
        seller.text = "fuck2"
        seller.makeDynamicFont()
        
        contentView.addSubview(name)
        contentView.addSubview(icon)
        contentView.addSubview(seller)
        
        constrain(name, seller, icon) { name, seller, icon in
            icon.height == iconSize
            icon.width == icon.height
            icon.left == icon.superview!.left + margin
            icon.top == icon.superview!.top + margin
            
            name.left == icon.right + (15~~12) ~ Global.notMaxPriority
            name.right == name.superview!.right - margin
            name.top == icon.top + 3
            
            seller.left == name.left
            seller.top == name.bottom + 3
            seller.right <= seller.superview!.right - margin
            
        }
    }
}
