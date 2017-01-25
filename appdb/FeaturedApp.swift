//
//  FeaturedApp.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage
import RealmSwift

class FeaturedApp: UICollectionViewCell {
    
    var title : UILabel!
    var category : UILabel!
    var icon : UIImageView!
    
    var didSetupConstraints = false
    
    var tweaked : Bool = false {
        didSet { title.textColor = tweaked ? Color.mainTint : .black }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        icon = UIImageView()
        icon.layer.cornerRadius = cornerRadius(fromWidth: self.frame.size.width)
        icon.layer.masksToBounds = true
        icon.layer.borderWidth = 0.5
        icon.layer.borderColor = Color.borderColor.cgColor
        icon.image = #imageLiteral(resourceName: "placeholderIcon")
        
        title = UILabel()
        title.textColor = .black
        title.font = UIFont.systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 2
        
        category = UILabel()
        category.textColor = Color.darkGray
        category.font = UIFont.systemFont(ofSize: 11.5)
        category.lineBreakMode = .byTruncatingTail
        category.numberOfLines = 1
        
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
                title.top == icon.bottom + 5
                
                category.left == category.superview!.left
                category.right == category.superview!.right
                category.top == title.bottom + (2~~1)
            }
        }
    }
}
