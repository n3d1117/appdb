//
//  ThreePortraitScreenshotsSearchCell.swift
//  appdb
//
//  Created by ned on 15/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift

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
        
        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)
        
        screenshot_one = UIImageView()
        screenshot_one.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot_one.layer.cornerRadius = 5
        screenshot_one.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot_one.layer.theme_borderColor = Color.borderCgColor
        screenshot_one.layer.masksToBounds = true

        screenshot_two = UIImageView()
        screenshot_two.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot_two.layer.cornerRadius = 5
        screenshot_two.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot_two.layer.theme_borderColor = Color.borderCgColor
        screenshot_two.layer.masksToBounds = true
        
        screenshot_three = UIImageView()
        screenshot_three.image = #imageLiteral(resourceName: "placeholderCover")
        screenshot_three.layer.cornerRadius = 5
        screenshot_three.layer.borderWidth = 1 / UIScreen.main.scale
        screenshot_three.layer.theme_borderColor = Color.borderCgColor
        screenshot_three.layer.masksToBounds = true
        
        contentView.addSubview(screenshot_one)
        contentView.addSubview(screenshot_two)
        contentView.addSubview(screenshot_three)
        
        setConstraints()
    }
    
    // MARK: - Additional Configuration
    
    override func configure(with item: Object) {
        super.configure(with: item)
        guard item.itemFirstThreeScreenshotsUrls.count > 2 else { return }
        let ssUrls = item.itemFirstThreeScreenshotsUrls
        if let url1 = URL(string: ssUrls[0]), let url2 = URL(string: ssUrls[1]), let url3 = URL(string: ssUrls[2]) {
            let filter = Global.screenshotRoundedFilter(size: screenshot_one.frame.size, radius: 5)
            screenshot_one.af_setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshot_two.af_setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshot_three.af_setImage(withURL: url3, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
        }
    }
    
    // MARK: - Constraints
    
    override func setConstraints() {
        constrain(screenshot_one, screenshot_two, screenshot_three, icon) { s_one, s_two, s_three, icon in
            
            (icon.height ~== iconSize) ~ Global.notMaxPriority
            
            (s_one.height ~== compactPortraitSize) ~ Global.notMaxPriority
            s_one.width ~== s_one.height ~/ magic
            s_one.top ~== icon.bottom ~+ spaceFromIcon
            s_one.bottom ~== s_one.superview!.bottom ~- Global.size.margin.value
            
            s_two.height ~== s_one.height
            s_two.width ~== s_one.width
            s_two.top ~== s_one.top
            s_two.bottom ~== s_one.bottom
            
            s_three.height ~== s_one.height
            s_three.width ~== s_one.width
            s_three.top ~== s_one.top
            s_three.bottom ~== s_one.bottom
            
            distribute(by: 15, horizontally: s_one, s_two, s_three)
            s_two.centerX ~== s_two.superview!.centerX
        }
    }
}
