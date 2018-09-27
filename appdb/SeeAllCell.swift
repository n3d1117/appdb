//
//  SeeAllCell.swift
//  appdb
//
//  Created by ned on 21/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cosmos
import Cartography
import RealmSwift

class SeeAllCell: UITableViewCell {
    
    // UI objects
    var nameLabel: UILabel!
    var infoLabel: UILabel!
    var icon: UIImageView!
    
    // iOS
    func configure(name: String, category: String, version: String, iconUrl: String, size: String) {
        nameLabel.text = name
        infoLabel.text = category + Global.bulletPoint + version + (!size.isEmpty ? Global.bulletPoint + size : "")
        if let url = URL(string: iconUrl) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80~~60),
                             imageTransition: .crossDissolve(0.2))
        }
    }
    
    // Cydia
    func configure(name: String, categoryId: String, version: String, iconUrl: String, tweaked: Bool) {
        nameLabel.text = name
        nameLabel.theme_textColor = tweaked ? Color.mainTint : Color.title
        let cat = API.categoryFromId(id: categoryId, type: .cydia)
        infoLabel.text = cat + Global.bulletPoint + version
        if let url = URL(string: iconUrl) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80~~60),
                             imageTransition: .crossDissolve(0.2))
        }
    }
    
    // Book
    func configure(name: String, author: String, language: String, categoryId: String, coverUrl: String) {
        nameLabel.text = name
        if !language.isEmpty {
            infoLabel.text = author + Global.bulletPoint + language
        } else if !categoryId.isEmpty {
            infoLabel.text = author + Global.bulletPoint + API.categoryFromId(id: categoryId, type: .books)
        } else {
            infoLabel.text = author
        }
        if let url = URL(string: coverUrl) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        sharedInit()
        setConstraints()
        
    }
    
    // Shared initializer
    fileprivate func sharedInit() {
        
        //UI
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        
        accessoryType = .disclosureIndicator
        
        // Name
        nameLabel = UILabel()
        nameLabel.theme_textColor = Color.title
        nameLabel.font = .systemFont(ofSize: 15~~14)
        nameLabel.numberOfLines = reuseIdentifier == "seeallcell_book" ? 3 : 2
        nameLabel.makeDynamicFont()
        
        // Info Label
        infoLabel = UILabel()
        infoLabel.theme_textColor = Color.darkGray
        infoLabel.font = .systemFont(ofSize: 13~~12)
        infoLabel.numberOfLines = 1
        infoLabel.makeDynamicFont()
        
        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        
        if reuseIdentifier != "seeallcell_book" {
            icon.layer.cornerRadius = Global.cornerRadius(from: (80~~60))
        }
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(icon)
        
    }
    
    // Set constraints
    fileprivate func setConstraints() {
        constrain(icon, nameLabel, infoLabel) { icon, name, info in
            icon.width == ((reuseIdentifier == "seeallcell_book" ? 70 : 80)~~60)
            
            if reuseIdentifier == "seeallcell_book" {
                icon.height == icon.width * 1.542
            } else {
                icon.height == icon.width
            }
            icon.left == icon.superview!.left + Global.size.margin.value
            icon.centerY == icon.superview!.centerY
            
            name.left == icon.right + (15~~12)
            name.right == name.superview!.right - Global.size.margin.value
            name.centerY == name.superview!.centerY - (12~~10)
            
            info.top == name.bottom + (5~~4)
            info.left == name.left
            info.right == name.right
        }
    }
    
}

