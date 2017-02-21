//
//  DetailsHeader.swift
//  appdb
//
//  Created by ned on 20/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift
import AlamofireImage

class DetailsHeader: DetailsCell {
    
    var name : UILabel!
    var icon : UIImageView!
    var seller : UIButton!
    var tweaked: UILabel?
    
    private var _height = (130~~100) + Featured.size.margin.value
    private var _heightBooks = ((130~~100) * 1.542) + Featured.size.margin.value
    override var height: CGFloat {
        switch type {
            case .ios, .cydia: return _height
            case .books: return _heightBooks
        }
    }
    
    override var identifier: String { return "header" }
    
    convenience init(type: ItemType, content: Object) {
        self.init(style: .default, reuseIdentifier: "header")

        self.type = type
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset.left = 10000
        layoutMargins = UIEdgeInsets.zero
        
        //UI
        theme_backgroundColor = Color.veryVeryLightGray
        
        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = UIFont.systemFont(ofSize: 18~~16)
        name.numberOfLines = 3
        
        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        
        switch type {
            case .ios: if let app = content as? App {
                name.text = app.name
                seller = ButtonFactory.createChevronButton(text: app.seller, color: Color.darkGray, size: 15~~14, bold: false)
                icon.layer.cornerRadius = cornerRadius(fromWidth: 130~~100)
                if let url = URL(string: app.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.getFilter(from: 100),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
            case .cydia: if let cydiaApp = content as? CydiaApp {
                name.text = cydiaApp.name
                seller = ButtonFactory.createChevronButton(text: cydiaApp.developer, color: Color.darkGray, size: 15~~13, bold: false)
                
                if cydiaApp.isTweaked {
                    tweaked  = PaddingLabel()
                    tweaked!.theme_textColor = Color.invertedTitle
                    tweaked!.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia).uppercased()
                    tweaked!.font = UIFont.boldSystemFont(ofSize: 10.0)
                    tweaked!.layer.backgroundColor = UIColor.gray.cgColor
                    tweaked!.layer.cornerRadius = 6
                    tweaked!.isHidden = false
                } else {
                    tweaked = nil
                }
                
                icon.layer.cornerRadius = cornerRadius(fromWidth: 130~~100)
                if let url = URL(string: cydiaApp.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.getFilter(from: 100),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
            case .books: if let book = content as? Book {
                name.text = book.name
                seller = ButtonFactory.createChevronButton(text: book.author, color: Color.darkGray, size: 15~~14, bold: false)
                icon.layer.cornerRadius = 0
                if let url = URL(string: book.image) {
                    icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"),
                                 imageTransition: .crossDissolve(0.2))
                }
            }
        }
        
        contentView.addSubview(name)
        contentView.addSubview(seller)
        contentView.addSubview(icon)
        if let tweaked = tweaked { contentView.addSubview(tweaked) }
        
        setConstraints()
        
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(name, seller, icon) { name, seller, icon in
                
                icon.width == 130~~100
                
                switch type {
                    case .ios, .cydia: icon.height == icon.width
                    case .books: icon.height == icon.width * 1.542
                }
                
                icon.left == icon.superview!.left + Featured.size.margin.value
                icon.top == icon.superview!.top + Featured.size.margin.value
                
                name.left == icon.right + 12
                name.right == name.superview!.right - Featured.size.margin.value
                name.top == icon.top + 3
                
                seller.left == name.left
                seller.right == seller.superview!.right - Featured.size.margin.value
                seller.top == name.bottom + 3
            }
            
            if let tweaked = tweaked, type == .cydia {
                constrain(tweaked, seller) { tweaked, seller in
                    tweaked.left == seller.left
                    tweaked.right <= tweaked.superview!.right - Featured.size.margin.value
                    tweaked.top == seller.bottom + (7~~6)+
                }
            }
        }
    }

}
