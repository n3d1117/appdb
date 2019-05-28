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
    
    override var height: CGFloat { return round(iconSize + compactPortraitSize + margin * 2 + spaceFromIcon) }

    var screenshotOne: UIImageView!
    var screenshotTwo: UIImageView!
    var screenshotThree: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.sharedSetup()

        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)

        screenshotOne = UIImageView()
        screenshotOne.image = #imageLiteral(resourceName: "placeholderCover")
        screenshotOne.layer.cornerRadius = 5
        screenshotOne.layer.borderWidth = 1 / UIScreen.main.scale
        screenshotOne.layer.theme_borderColor = Color.borderCgColor
        screenshotOne.layer.masksToBounds = true

        screenshotTwo = UIImageView()
        screenshotTwo.image = #imageLiteral(resourceName: "placeholderCover")
        screenshotTwo.layer.cornerRadius = 5
        screenshotTwo.layer.borderWidth = 1 / UIScreen.main.scale
        screenshotTwo.layer.theme_borderColor = Color.borderCgColor
        screenshotTwo.layer.masksToBounds = true

        screenshotThree = UIImageView()
        screenshotThree.image = #imageLiteral(resourceName: "placeholderCover")
        screenshotThree.layer.cornerRadius = 5
        screenshotThree.layer.borderWidth = 1 / UIScreen.main.scale
        screenshotThree.layer.theme_borderColor = Color.borderCgColor
        screenshotThree.layer.masksToBounds = true

        contentView.addSubview(screenshotOne)
        contentView.addSubview(screenshotTwo)
        contentView.addSubview(screenshotThree)

        setConstraints()
    }

    // MARK: - Additional Configuration

    override func configure(with item: Item) {
        super.configure(with: item)
        guard item.itemFirstThreeScreenshotsUrls.count > 2 else { return }
        let ssUrls = item.itemFirstThreeScreenshotsUrls
        if let url1 = URL(string: ssUrls[0]), let url2 = URL(string: ssUrls[1]), let url3 = URL(string: ssUrls[2]) {
            let filter = Global.screenshotRoundedFilter(size: screenshotOne.frame.size, radius: 5)
            screenshotOne.af_setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshotTwo.af_setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshotThree.af_setImage(withURL: url3, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
        }
    }

    // MARK: - Constraints

    override func setConstraints() {
        constrain(screenshotOne, screenshotTwo, screenshotThree, icon) { sOne, sTwo, sThree, icon in
            (icon.height ~== iconSize) ~ Global.notMaxPriority

            (sOne.height ~== compactPortraitSize) ~ Global.notMaxPriority
            sOne.width ~== sOne.height ~/ magic
            sOne.top ~== icon.bottom ~+ spaceFromIcon
            sOne.bottom ~== sOne.superview!.bottom ~- Global.Size.margin.value

            sTwo.height ~== sOne.height
            sTwo.width ~== sOne.width
            sTwo.top ~== sOne.top
            sTwo.bottom ~== sOne.bottom

            sThree.height ~== sOne.height
            sThree.width ~== sOne.width
            sThree.top ~== sOne.top
            sThree.bottom ~== sOne.bottom

            distribute(by: 15, horizontally: sOne, sTwo, sThree)
            sTwo.centerX ~== sTwo.superview!.centerX
        }
    }
}
