//
//  News+Detail+HTMLCell.swift
//  appdb
//
//  Created by ned on 07/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class NewsDetailHTMLCell: UITableViewCell {
    
    var htmlText: AttributedLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        selectionStyle = .none
        
        // HTML Text
        htmlText = AttributedLabel()
        htmlText.font = .systemFont(ofSize: (17~~16))
        htmlText.theme_textColor = Color.title
        htmlText.numberOfLines = 0
        
        contentView.addSubview(htmlText)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        let pad = Global.size.margin.value + 5
        constrain(htmlText) { text in
            text.edges ~== inset(text.superview!.edges, pad, pad, pad, pad)
        }
    }
}
