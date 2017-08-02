//
//  Details+Changelog.swift
//  appdb
//
//  Created by ned on 26/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class DetailsChangelog: DetailsCell {
    
    var changelog: String! = ""
    
    var title: UILabel!
    var date: UILabel!
    var desc: ElasticLabel!
    
    override var height: CGFloat { return changelog.isEmpty ? 0 : UITableViewAutomaticDimension }
    override var identifier: String { return "changelog" }
    
    convenience init(type: ItemType, changelog: String, updated: String, delegate: ElasticLabelDelegate) {
        self.init(style: .default, reuseIdentifier: "changelog")
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        self.type = type
        self.changelog = changelog
        
        if !changelog.isEmpty {
            theme_backgroundColor = Color.veryVeryLightGray
            contentView.theme_backgroundColor = Color.veryVeryLightGray
        
            title = UILabel()
            title.theme_textColor = Color.title
            title.text = "What's New".localized()
            title.font = .systemFont(ofSize: (17~~16))
            
            date = UILabel()
            date.theme_textColor = Color.copyrightText
            date.text = type == .cydia ? updated.unixToString : updated
            date.font = .systemFont(ofSize: (14~~13))
            
            desc = ElasticLabel(text: changelog.decoded, delegate: delegate)
            desc.theme_textColor = Color.darkGray
            desc.theme_backgroundColor = Color.veryVeryLightGray
            desc.collapsed = true
        
            contentView.addSubview(title)
            contentView.addSubview(date)
            contentView.addSubview(desc)
        
            setConstraints()
        }
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(title, date, desc) { title, date, desc in
                
                title.top == title.superview!.top + 12
                title.left == title.superview!.left + Global.size.margin.value
                title.right == title.superview!.right - Global.size.margin.value
                
                date.top == title.bottom - 1
                date.left == title.left
                date.right == title.right
                
                desc.top == date.bottom + 8 ~ 999.0
                desc.left == title.left
                desc.right == title.right
                desc.bottom == desc.superview!.bottom - 15
                
            }
        }
    }
}
