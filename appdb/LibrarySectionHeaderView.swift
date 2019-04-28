//
//  LibrarySectionHeaderView.swift
//  appdb
//
//  Created by ned on 27/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class LibrarySectionHeaderView: UICollectionReusableView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.copyrightText
        label.font = .systemFont(ofSize: (22~~20), weight: UIFont.Weight.semibold)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.makeDynamicFont()
        return label
    }()
    
    func configure(_ text: String) {
        label.text = text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        addSubview(label)
        
        constrain(label) { label in
            label.left == label.superview!.left + Global.size.margin.value
            label.right == label.superview!.right
            label.centerY == label.superview!.centerY
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
