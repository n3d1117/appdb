//
//  Details+Changelog.swift
//  appdb
//
//  Created by ned on 26/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class DetailsChangelog: DetailsCell {
    
    var changelog: String! = ""
    
    var title: UILabel!
    var date: UILabel!
    var desc: ElasticLabel!
    
    override var height: CGFloat { return changelog.isEmpty ? 0 : UITableView.automaticDimension }
    override var identifier: String { return "changelog" }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(type: ItemType, changelog: String, updated: String) {
        self.changelog = changelog
        date.text = type == .cydia ? updated.unixToString : updated
        desc.text = changelog.decoded
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        title = UILabel()
        title.theme_textColor = Color.title
        title.text = "What's New".localized()
        title.font = .systemFont(ofSize: (17~~16))
        title.makeDynamicFont()
        
        date = UILabel()
        date.theme_textColor = Color.copyrightText
        date.font = .systemFont(ofSize: (14~~13))
        date.makeDynamicFont()
        
        desc = ElasticLabel()
        desc.theme_textColor = Color.darkGray
        desc.theme_backgroundColor = Color.veryVeryLightGray
        desc.makeDynamicFont()
        
        contentView.addSubview(title)
        contentView.addSubview(date)
        contentView.addSubview(desc)
        
        setConstraints()
    }
    
    // Just a placeholder
    convenience init() { self.init(style: .default, reuseIdentifier: "changelog") }
    
    override func setConstraints() {
        constrain(title, date, desc) { title, date, desc in
            
            title.top == title.superview!.top + 12
            title.left == title.superview!.left + Global.size.margin.value
            title.right == title.superview!.right - Global.size.margin.value
            
            date.top == title.bottom - 1
            date.left == title.left
            date.right == title.right
            
            desc.top == date.bottom + 8 ~ Global.notMaxPriority
            desc.left == title.left
            desc.right == title.right
            desc.bottom == desc.superview!.bottom - 15
            
        }
    }
}
