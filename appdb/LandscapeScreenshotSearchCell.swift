//
//  LandscapeScreenshotSearchCell.swift
//  appdb
//
//  Created by ned on 12/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import Cartography

class LandscapeScreenshotSearchCell: SearchCell {
    
    override var height: CGFloat { return round(iconSize + landscapeSize + margin*2 + spaceFromIcon) }
    
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
            s.height == landscapeSize ~ Global.notMaxPriority
            s.width == s.height * magic
            s.top == icon.bottom + spaceFromIcon
            s.centerX == s.superview!.centerX
            s.bottom == s.superview!.bottom - margin
            s.left >= s.superview!.left + margin + 5
            s.right <= s.superview!.right - margin - 5
        }
    }
}
