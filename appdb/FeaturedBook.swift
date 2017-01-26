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
        cover.layer.borderWidth = 0.5
        cover.layer.borderColor = Color.borderColor.cgColor
        cover.image = #imageLiteral(resourceName: "placeholderCover")
        
        title = UILabel()
        title.textColor = .black
        title.font = UIFont.systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 2
        
        author = UILabel()
        author.textColor = Color.darkGray
        author.font = UIFont.systemFont(ofSize: 11.5)
        author.lineBreakMode = .byTruncatingTail
        author.numberOfLines = 1
        
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
                cover.width == frame.size.width
                cover.height == cover.width * 1.542
                
                title.left == title.superview!.left
                title.right == title.superview!.right
                title.top == cover.bottom + (4~~7)
                
                author.left == author.superview!.left
                author.right == author.superview!.right
                author.top == title.bottom + 2
            }
        }
    }
}
