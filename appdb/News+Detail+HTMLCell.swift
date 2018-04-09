//
//  News+Detail+HTMLCell.swift
//  appdb
//
//  Created by ned on 07/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class NewsDetailHTMLCell: UITableViewCell {
    
    var htmlText: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        selectionStyle = .none
        
        // Title
        htmlText = UILabel()
        htmlText.font = .systemFont(ofSize: (17~~16))
        htmlText.theme_textColor = Color.title
        htmlText.numberOfLines = 0
        htmlText.makeDynamicFont()
        
        contentView.addSubview(htmlText)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        let pad = Global.size.margin.value + 5
        constrain(htmlText) { text in
            text.edges == inset(text.superview!.edges, pad, pad, pad, pad)
        }
    }
}
