//
//  UpdatesSectionHeaderView.swift
//  appdb
//
//  Created by ned on 13/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class UpdatesSectionHeader: UITableViewHeaderFooterView {
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.theme_textColor = Color.copyrightText
        title.font = .systemFont(ofSize: 14~~13)
        title.numberOfLines = 1
        title.makeDynamicFont()
        return title
    }()
    
    lazy var helpButton: UIButton = {
        let why = UIButton(type: .system)
        why.setImage(UIImage(named: "question")?.withRenderingMode(.alwaysTemplate), for: .normal)
        why.theme_tintColor = Color.copyrightText
        return why
    }()
    
    func configure(with text: String) {
        titleLabel.text = text.uppercased()
    }
    
    convenience init(showsButton: Bool) {
        self.init(frame: .zero)
        
        contentView.backgroundColor = .clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        backgroundView = bgColorView

        contentView.addSubview(titleLabel)
        
        if showsButton {
            contentView.addSubview(helpButton)
            constrain(titleLabel, helpButton) { title, why in
                title.left ~== title.superview!.layoutMarginsGuide.left
                title.bottom ~== title.superview!.bottom ~- (9~~7)
                
                why.height ~== (20~~18)
                why.width ~== why.height
                why.right ~== why.superview!.layoutMarginsGuide.right
                why.centerY ~== title.centerY
            }
        } else {
            constrain(titleLabel) { title in
                title.left ~== title.superview!.layoutMarginsGuide.left
                title.bottom ~== title.superview!.bottom ~- (7~~5)
            }
        }
    }
}
