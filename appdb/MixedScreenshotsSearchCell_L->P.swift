//
//  MixedScreenshotsSearchCell_L->P.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class MixedScreenshotsSearchCellOne: SearchCell {
    
    override var height: CGFloat { return round(iconSize + mixedPortraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot_one: UIImageView!
    var screenshot_two: UIImageView!

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
        
        contentView.addSubview(screenshot_one)
        contentView.addSubview(screenshot_two)
        
        setConstraints()
    }
    
    // MARK: - Constraints

    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, icon) { s_one, s_two, icon in
            s_one.height == mixedPortraitSize ~ Global.notMaxPriority
            s_one.width == s_one.height * magic
            s_one.left == s_one.superview!.left + margin + 10
            
            s_two.height == s_one.height ~ Global.notMaxPriority
            s_two.width == s_two.height / magic
            s_two.top == icon.bottom + spaceFromIcon
            s_two.right == s_two.superview!.right - margin - 10
            
            s_two.bottom == s_two.superview!.bottom - margin ~ Global.notMaxPriority
            s_one.bottom == s_two.bottom ~ Global.notMaxPriority
            s_one.top == s_two.top

            distribute(by: 15, horizontally: s_one, s_two)
        }
    }
}
