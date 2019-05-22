//
//  PortraitScreenshotSearchCell.swift
//  appdb
//
//  Created by ned on 12/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage
import RealmSwift

class PortraitScreenshotSearchCell: SearchCell {
    
    override var height: CGFloat { return round(iconSize + portraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.sharedSetup()
        
        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)
        
        screenshot = UIImageView()
        screenshot.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot.layer.cornerRadius = 5
        screenshot.layer.theme_borderColor = Color.borderCgColor
        screenshot.layer.masksToBounds = true
        contentView.addSubview(screenshot)
        
        setConstraints()
    }
    
    // MARK: - Additional Configuration
    
    override func configure(with item: Object) {
        super.configure(with: item)
        
        if let url = URL(string: item.itemFirstScreenshotUrl) {
            let filter = Global.screenshotRoundedFilter(size: screenshot.frame.size, radius: 5)
            screenshot.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
        }
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot, icon) { s, icon in
            ((icon.height ~== iconSize) ~ Global.notMaxPriority) ~ Global.notMaxPriority
            (s.height ~== portraitSize) ~ Global.notMaxPriority
            s.width ~== s.height ~/ magic
            s.top ~== icon.bottom ~+ spaceFromIcon
            s.centerX ~== s.superview!.centerX
            s.bottom ~== s.superview!.bottom ~- margin
        }
    }
}
