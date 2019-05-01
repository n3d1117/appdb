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
   
    var title: UILabel!
    var author: UILabel!
    var cover: UIImageView!
    var dim: UIView = DimmableView.get()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        cover = UIImageView()
        cover.layer.borderWidth = 0.5
        cover.layer.theme_borderColor = Color.borderCgColor
        cover.image = #imageLiteral(resourceName: "placeholderCover")
        
        title = UILabel()
        title.theme_textColor = Color.title
        title.font = .systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 2
        title.makeDynamicFont()
        
        author = UILabel()
        author.theme_textColor = Color.darkGray
        author.font = .systemFont(ofSize: 11.5)
        author.lineBreakMode = .byTruncatingTail
        author.numberOfLines = 1
        author.makeDynamicFont()
        
        contentView.addSubview(cover)
        contentView.addSubview(title)
        contentView.addSubview(author)
        contentView.addSubview(dim)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {        
        constrain(cover, title, author, dim) { cover, title, author, dim in
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
            
            dim.edges == cover.edges
        }
    }
    
    // Hover cover
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.cover.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    self.dim.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    self.dim.isHidden = false
                    self.dim.layer.opacity = DimmableView.opacity
                }
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: { [unowned self] in
                    self.cover.transform = .identity
                    self.dim.transform = .identity
                    self.dim.layer.opacity = 0
                }, completion: { _ in
                    self.dim.isHidden = true
                })
            }
        }
    }
}
