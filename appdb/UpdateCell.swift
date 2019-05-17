
//
//  UpdateCell.swift
//  appdb
//
//  Created by ned on 12/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class UpdateCell: UITableViewCell {
    
    var name: UILabel!
    var info: UILabel!
    var whatsnew: ElasticLabel!
    var icon: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with title: String, versionOld: String, versionNew: String, changelog: String, image: String) {
        name.text = title
        info.text = versionOld + " → " + versionNew
        whatsnew.text = changelog.decoded
        if let url = URL(string: image) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80~~60),
                             imageTransition: .crossDissolve(0.2))
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        selectionStyle = .none

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 15~~14)
        name.numberOfLines = 2
        name.makeDynamicFont()
        
        // Info
        info = UILabel()
        info.theme_textColor = Color.darkGray
        info.font = .systemFont(ofSize: 13~~12)
        info.numberOfLines = 1
        info.makeDynamicFont()
        
        // Whatsnew
        whatsnew = ElasticLabel()
        whatsnew.theme_textColor = Color.copyrightText
        whatsnew.font = .systemFont(ofSize: 14~~13)
        whatsnew.maxNumberOfCollapsedLines = 3
        whatsnew.makeDynamicFont()
        
        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.layer.cornerRadius = Global.cornerRadius(from: (80~~60))
        
        contentView.addSubview(icon)
        contentView.addSubview(name)
        contentView.addSubview(info)
        contentView.addSubview(whatsnew)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        constrain(name, info, icon, whatsnew) { name, info, icon, whatsnew in
            
            icon.width == (80~~60)
            icon.height == icon.width ~ Global.notMaxPriority
            icon.top == icon.superview!.top + (15~~10)
            
            icon.left == icon.superview!.layoutMarginsGuide.left
            
            name.left == icon.right + (15~~12)
            name.right == name.superview!.layoutMarginsGuide.right
            name.centerY == icon.centerY - (12~~10)
            
            info.top == name.bottom + (5~~4)
            info.left == name.left
            info.right == name.right
            
            whatsnew.top == icon.bottom + (14~~11)
            whatsnew.left == icon.left
            whatsnew.right == name.right
            whatsnew.bottom == whatsnew.superview!.bottom - 15
            
        }
    }
    
}
