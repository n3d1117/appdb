//
//  MyAppstoreCell.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class MyAppstoreCell: UICollectionViewCell {

    var name: UILabel!
    var bundleId: UILabel!
    var installButton: RoundedButton!
    
    func configure(with app: MyAppstoreApp) {
        name.text = app.name + " (\(app.version))"
        bundleId.text = app.bundleId
        installButton.linkId = app.id
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18.5~~16.5)
        name.numberOfLines = 1
        name.makeDynamicFont()
        
        // Bundle id
        bundleId = UILabel()
        bundleId.theme_textColor = Color.darkGray
        bundleId.font = .systemFont(ofSize: 14~~13)
        bundleId.numberOfLines = 1
        bundleId.makeDynamicFont()
        
        // Install button
        installButton = RoundedButton()
        installButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        installButton.setTitle("Install".localized().uppercased(), for: .normal)
        installButton.theme_tintColor = Color.softGreen
        installButton.makeDynamicFont()
        
        contentView.addSubview(name)
        contentView.addSubview(bundleId)
        contentView.addSubview(installButton)
        
        constrain(name, bundleId, installButton) { name, bundleId, button in
            
            button.right == button.superview!.right - Global.size.margin.value
            button.centerY == button.superview!.centerY

            name.left == name.superview!.left + Global.size.margin.value
            name.right == name.superview!.right - 110 - Global.size.margin.value
            name.top == name.superview!.top + (18~~15)
            
            bundleId.left == name.left
            bundleId.right == name.right
            bundleId.bottom == bundleId.superview!.bottom - (18~~15)
            
        }
    }
}
