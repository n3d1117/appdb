//
//  TwoPortraitScreenshotsSearchCell.swift
//  appdb
//
//  Created by ned on 12/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

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
        
        screenshot_one = UIImageView()
        screenshot_one.image = #imageLiteral(resourceName: "placeholderCover")
        
        screenshot_two = UIImageView()
        screenshot_two.image = #imageLiteral(resourceName: "placeholderCover")
        
        contentView.addSubview(screenshot_one)
        contentView.addSubview(dummyView)
        contentView.addSubview(screenshot_two)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, dummyView, icon) { s_one, s_two, dummy, icon in
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
