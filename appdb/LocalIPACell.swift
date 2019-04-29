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
    var moreImageButton: UIImageView!
    
    func configure(with app: LocalIPAFile) {
        filename.text = app.filename
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
        
        // More image button
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.9
        
        contentView.addSubview(filename)
        contentView.addSubview(moreImageButton)
        
        constrain(filename, moreImageButton) { name, moreButton in
            
            moreButton.centerY == moreButton.superview!.centerY
            moreButton.right == moreButton.superview!.right - Global.size.margin.value
            moreButton.width == (22~~20)
            moreButton.height == moreButton.width
            
            name.left == name.superview!.left + Global.size.margin.value
            name.right == moreButton.left - Global.size.margin.value
            name.centerY == name.superview!.centerY
        }
    }
}
