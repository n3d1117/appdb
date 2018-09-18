//
//  ThreePortraitScreenshotsSearchCell.swift
//  appdb
//
//  Created by ned on 15/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class ThreePortraitScreenshotsSearchCell: SearchCell {
    
    override var height: CGFloat { return round(iconSize + compactPortraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot_one: UIImageView!
    var screenshot_two: UIImageView!
    var screenshot_three: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.sharedSetup()
        
        screenshot_one = UIImageView()
        screenshot_one.image = #imageLiteral(resourceName: "placeholderCover")
        
        screenshot_two = UIImageView()
        screenshot_two.image = #imageLiteral(resourceName: "placeholderCover")
        
        screenshot_three = UIImageView()
        screenshot_three.image = #imageLiteral(resourceName: "placeholderCover")
        
        contentView.addSubview(screenshot_one)
        contentView.addSubview(screenshot_two)
        contentView.addSubview(screenshot_three)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, screenshot_three, icon) { s_one, s_two, s_three, icon in
            s_one.height == compactPortraitSize ~ Global.notMaxPriority
            s_one.width == s_one.height / magic
            s_one.top == icon.bottom + spaceFromIcon
            s_one.bottom == s_one.superview!.bottom - Global.size.margin.value
            
            s_two.height == s_one.height
            s_two.width == s_one.width
            s_two.top == s_one.top
            s_two.bottom == s_one.bottom
            
            s_three.height == s_one.height
            s_three.width == s_one.width
            s_three.top == s_one.top
            s_three.bottom == s_one.bottom
            
            distribute(by: 15, horizontally: s_one, s_two, s_three)
            s_two.centerX == s_two.superview!.centerX
        }
    }
}
