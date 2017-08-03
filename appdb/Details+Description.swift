//
//  Details+Description.swift
//  appdb
//
//  Created by ned on 23/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class DetailsDescription: DetailsCell {
    
    var title: UILabel!
    var desc: ElasticLabel!
    
    var descriptionText: String! = ""
    
    override var height: CGFloat { return descriptionText.isEmpty ? 0 : UITableViewAutomaticDimension }
    override var identifier: String { return "description" }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with description: String) {
        descriptionText = description
        desc.text = descriptionText.decoded
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        title = UILabel()
        title.theme_textColor = Color.title
        title.text = "Description".localized()
        title.font = .systemFont(ofSize: (17~~16))
        
        desc = ElasticLabel()
        desc.theme_textColor = Color.darkGray
        desc.theme_backgroundColor = Color.veryVeryLightGray
        desc.collapsed = true
        
        contentView.addSubview(title)
        contentView.addSubview(desc)
        
        setConstraints()
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(title, desc) { title, desc in
                
                title.top == title.superview!.top + 12
                title.left == title.superview!.left + Global.size.margin.value
                title.right == title.superview!.right - Global.size.margin.value
                
                desc.top == title.bottom + 8 ~ 999.0
                desc.left == title.left
                desc.right == title.right
                desc.bottom == desc.superview!.bottom - 15
                
            }
        }
    }
    
    // Just a placeholder
    convenience init() { self.init(style: .default, reuseIdentifier: "description") }
}
