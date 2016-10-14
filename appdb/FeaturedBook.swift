//
//  FeaturedBook.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class FeaturedBook: UICollectionViewCell {
   
    var title : UILabel!
    var author : UILabel!
    var cover : UIImageView!
    
    var didSetupConstraints = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        cover = UIImageView()
        cover.layer.borderWidth = (1.0 / UIScreen.main.scale)
        cover.layer.borderColor = UIColor.lightGray.cgColor
        
        title = UILabel()
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.text = "A Game Of Thrones"
        title.numberOfLines = 2
        title.sizeToFitHeight()
        
        author = UILabel()
        author.textColor = Color.darkGray
        author.font = UIFont.systemFont(ofSize: 11.5)
        author.lineBreakMode = .byTruncatingTail
        author.text = "J. J. Abrams"
        author.numberOfLines = 1
        author.sizeToFitHeight()
        
        addSubview(cover)
        addSubview(title)
        addSubview(author)
        
        setConstraints()
    }
    
    func setConstraints() {        
        if !didSetupConstraints { didSetupConstraints = true
            constrain(cover, title, author) { cover, title, author in
                cover.left == cover.superview!.left
                cover.top == cover.superview!.top
                cover.right == cover.superview!.right
                cover.width == self.frame.size.width
                cover.height == cover.width * 1.542
                
                title.left == title.superview!.left
                title.right == title.superview!.right
                title.top == cover.bottom + (4~~7)
                
                author.left == author.superview!.left
                author.right == author.superview!.right
                author.top == title.bottom
            }
        }
    }
}
