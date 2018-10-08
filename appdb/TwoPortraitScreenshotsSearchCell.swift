//
//  TwoPortraitScreenshotsSearchCell.swift
//  appdb
//
//  Created by ned on 12/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography
import RealmSwift

class TwoPortraitScreenshotsSearchCell: SearchCell {
    
    override var height: CGFloat { return round(iconSize + portraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot_one: UIImageView!
    var screenshot_two: UIImageView!
    
    var dummyView: UIView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.sharedSetup()
        
        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)
        
        screenshot_one = UIImageView()
        screenshot_one.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot_one.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot_one.layer.cornerRadius = 5
        screenshot_one.layer.theme_borderColor = Color.borderCgColor
        screenshot_one.layer.masksToBounds = true
        
        screenshot_two = UIImageView()
        screenshot_two.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot_two.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot_two.layer.cornerRadius = 5
        screenshot_two.layer.theme_borderColor = Color.borderCgColor
        screenshot_two.layer.masksToBounds = true
        
        contentView.addSubview(screenshot_one)
        contentView.addSubview(dummyView)
        contentView.addSubview(screenshot_two)
        
        setConstraints()
    }
    
    // MARK: - Additional Configuration
    
    override func configure(with item: Object) {
        super.configure(with: item)
        guard item.itemFirstTwoScreenshotsUrls.count > 1 else { return }
        if let url1 = URL(string: item.itemFirstTwoScreenshotsUrls[0]), let url2 = URL(string: item.itemFirstTwoScreenshotsUrls[1]) {
            let filter = Global.screenshotRoundedFilter(size: screenshot_one.frame.size, radius: 5)
            screenshot_one.af_setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshot_two.af_setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
        }
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, dummyView, icon) { s_one, s_two, dummy, icon in
            icon.height == iconSize
            
            s_one.height == portraitSize ~ Global.notMaxPriority
            s_one.width == s_one.height / magic
            s_one.top == icon.bottom + spaceFromIcon
            s_one.bottom == s_one.superview!.bottom - Global.size.margin.value

            s_two.height == portraitSize ~ Global.notMaxPriority
            s_two.width == s_two.height / magic
            s_two.top == s_one.top
            s_two.bottom == s_one.bottom

            dummy.height == s_one.height
            dummy.width == 15
            distribute(horizontally: s_one, dummy, s_two)
            dummy.centerX == dummy.superview!.centerX
        }
    }
}
