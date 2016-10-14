//
//  FeaturedApp.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class FeaturedApp: UICollectionViewCell {
    
    var title : UILabel!
    var category : UILabel!
    var icon : UIImageView!
    
    var didSetupConstraints = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        icon = UIImageView()
        icon.layer.cornerRadius = icon.cornerRadius(fromWidth: self.frame.size.width)
        icon.layer.borderWidth = (1.0 / UIScreen.main.scale)
        icon.layer.masksToBounds = true
        icon.layer.borderColor = UIColor.lightGray.cgColor
        
        title = UILabel()
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.text = "Modern Combat 5"
        title.numberOfLines = 2
        title.sizeToFitHeight()
        
        category = UILabel()
        category.textColor = Color.darkGray
        category.font = UIFont.systemFont(ofSize: 11.5)
        category.lineBreakMode = .byTruncatingTail
        category.text = "Games"
        category.numberOfLines = 1
        category.sizeToFitHeight()
        
        addSubview(icon)
        addSubview(title)
        addSubview(category)
        
        setConstraints()
    }
    
    func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(icon, title, category) { icon, title, category in
                icon.left == icon.superview!.left
                icon.top == icon.superview!.top
                icon.right == icon.superview!.right
                icon.height == frame.size.width
                icon.width == frame.size.width
                
                title.left == title.superview!.left
                title.right == title.superview!.right
                title.top == icon.bottom + (4~~7)
                
                category.left == category.superview!.left
                category.right == category.superview!.right
                category.top == title.bottom
            }
        }
    }
}
