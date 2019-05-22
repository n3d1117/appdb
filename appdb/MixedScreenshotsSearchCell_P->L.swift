//
//  MixedScreenshotsSearchCell_P->L.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift

class MixedScreenshotsSearchCellTwo: SearchCell {
    
    override var height: CGFloat { return round(iconSize + mixedPortraitSize + margin*2 + spaceFromIcon) }
    
    var screenshot_one: UIImageView!
    var screenshot_two: UIImageView!
    
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
        contentView.addSubview(screenshot_two)
        
        setConstraints()
    }
    
    // MARK: - Additional Configuration
    
    override func configure(with item: Object) {
        super.configure(with: item)
        guard item.itemFirstTwoScreenshotsUrls.count > 1 else { return }
        if let url1 = URL(string: item.itemFirstTwoScreenshotsUrls[0]), let url2 = URL(string: item.itemFirstTwoScreenshotsUrls[1]) {
            let filter1 = Global.screenshotRoundedFilter(size: screenshot_one.frame.size, radius: 5)
            let filter2 = Global.screenshotRoundedFilter(size: screenshot_two.frame.size, radius: 5)
            screenshot_one.af_setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter1, imageTransition: .crossDissolve(0.2))
            screenshot_two.af_setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter2, imageTransition: .crossDissolve(0.2))
        }
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, icon) { s_one, s_two, icon in
            
            (icon.height ~== iconSize) ~ Global.notMaxPriority
            
            (s_one.height ~== mixedPortraitSize) ~ Global.notMaxPriority
            s_one.width ~== s_one.height ~/ magic
            s_one.left ~== s_one.superview!.left ~+ margin + 10
            s_one.top ~== icon.bottom ~+ spaceFromIcon
            (s_one.bottom ~== s_one.superview!.bottom ~- margin) ~ Global.notMaxPriority
            
            (s_two.height ~== s_one.height) ~ Global.notMaxPriority
            s_two.width ~== s_two.height ~* magic
            s_two.right ~== s_two.superview!.right ~- margin - 10
            (s_two.bottom ~== s_one.bottom) ~ Global.notMaxPriority
            s_two.top ~== s_one.top
            
            distribute(by: 15, horizontally: s_one, s_two)
        }
    }
}
