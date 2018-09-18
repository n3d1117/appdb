//
//  PortraitScreenshotSearchCell.swift
//  appdb
//
//  Created by ned on 12/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class PortraitScreenshotSearchCell: SearchCell {
    
    override var height: CGFloat { return round(iconSize + portraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.sharedSetup()
        
        screenshot = UIImageView()
        screenshot.image = #imageLiteral(resourceName: "placeholderCover")
        contentView.addSubview(screenshot)
        
        setConstraints()
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot, icon) { s, icon in
            s.height == portraitSize ~ Global.notMaxPriority
            s.width == s.height / magic
            s.top == icon.bottom + spaceFromIcon
            s.centerX == s.superview!.centerX
            s.bottom == s.superview!.bottom - margin
        }
    }
}
