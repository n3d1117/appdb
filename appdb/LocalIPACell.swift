//
//  LocalIPACell.swift
//  appdb
//
//  Created by ned on 28/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class LocalIPACell: UICollectionViewCell {
    
    var filename: UILabel!
    var size: UILabel!
    var moreImageButton: UIImageView!
    var dummy: UIView!
    
    func configure(with app: LocalIPAFile) {
        filename.text = app.filename
        size.text = app.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        // Filename
        filename = UILabel()
        filename.theme_textColor = Color.title
        filename.font = .systemFont(ofSize: 17~~16)
        filename.numberOfLines = 1
        filename.makeDynamicFont()
        
        // Info
        size = UILabel()
        size.theme_textColor = Color.darkGray
        size.font = .systemFont(ofSize: 14~~13)
        size.numberOfLines = 1
        size.makeDynamicFont()
        
        // More image button
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.9
        
        dummy = UIView()
        
        contentView.addSubview(filename)
        contentView.addSubview(size)
        contentView.addSubview(moreImageButton)
        contentView.addSubview(dummy)
        
        constrain(filename, size, moreImageButton, dummy) { name, size, moreButton, d in
            
            moreButton.centerY == moreButton.superview!.centerY
            moreButton.right == moreButton.superview!.right - Global.size.margin.value
            moreButton.width == (22~~20)
            moreButton.height == moreButton.width
            
            d.height == 1
            d.centerY == d.superview!.centerY
            
            name.left == name.superview!.left + Global.size.margin.value
            name.right == moreButton.left - Global.size.margin.value
            name.bottom == d.top + 2
            
            size.left == name.left
            size.right == name.right
            size.top == d.bottom + 3
        }
    }
}
