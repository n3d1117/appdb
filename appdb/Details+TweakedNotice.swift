//
//  Details+TweakedNotice.swift
//  appdb
//
//  Created by ned on 26/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

protocol DynamicContentRedirection {
    func dynamicContentSelected(type: ItemType, id: String)
}

class DetailsTweakedNotice: DetailsCell {
    
    var trackid: String!
    var section: String!
    
    var title: UILabel!
    var content: UILabel!
    var seeOriginal: UIButton!
    
    override var height: CGFloat { return (trackid.isEmpty || trackid == "0") ? 0 : UITableViewAutomaticDimension }
    override var identifier: String { return "tweakednotice" }
    
    var delegate: DynamicContentRedirection? = nil
    
    convenience init(originalTrackId: String, originalSection: String, delegate: DynamicContentRedirection) {
        self.init(style: .default, reuseIdentifier: "tweakednotice")
        
        self.trackid = originalTrackId
        self.section = originalSection
        self.delegate = delegate
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()
        
        if !trackid.isEmpty, trackid != "0" {
            
            theme_backgroundColor = Color.veryVeryLightGray
            contentView.theme_backgroundColor = Color.veryVeryLightGray
            
            title = UILabel()
            title.theme_textColor = Color.title
            title.text = "Tweaked Version Notice".localized()
            title.font = .systemFont(ofSize: (17~~16))
            
            content = UILabel()
            content.theme_textColor = Color.darkGray
            content.text = "This app was tweaked to provide additional features. Be sure to download it from verified crackers only, because no one except them can guarantee that it doesn't contain any malicious code.".localized()
            content.font = .systemFont(ofSize: (13~~12))
            content.numberOfLines = 0
            
            seeOriginal = ButtonFactory.createChevronButton(text: "See Original".localized(), color: Color.darkGray, bold: false)
            seeOriginal.addTarget(self, action: #selector(self.originalSelected), for: .touchUpInside)
            
            contentView.addSubview(title)
            contentView.addSubview(content)
            contentView.addSubview(seeOriginal)
            
            setConstraints()
            
        }
    }
    
    func originalSelected() {
        var type: ItemType?
        if section == "ios" { type = .ios }
        else if section == "cydia" { type = .cydia }
        if let type = type { delegate?.dynamicContentSelected(type: type, id: trackid) }
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(title, content, seeOriginal) { title, content, seeOriginal in
                
                title.top == title.superview!.top + 12
                title.left == title.superview!.left + Featured.size.margin.value
                title.right == title.superview!.right - Featured.size.margin.value
                
                content.top == title.bottom + 8
                content.left == title.left
                content.right == title.right
                content.bottom == content.superview!.bottom - 15
                
                seeOriginal.right == seeOriginal.superview!.right - Featured.size.margin.value
                seeOriginal.centerY == title.centerY
                
            }
        }
    }
}
