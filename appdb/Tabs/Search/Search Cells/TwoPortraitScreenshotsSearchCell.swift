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

    override var height: CGFloat { return round(iconSize + portraitSize + margin * 2 + spaceFromIcon) }

    var screenshotOne: UIImageView!
    var screenshotTwo: UIImageView!

    var dummyView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.sharedSetup()

        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)

        screenshotOne = UIImageView()
        screenshotOne.image = #imageLiteral(resourceName: "placeholderCover")
        screenshotOne.layer.borderWidth = 1 / UIScreen.main.scale
        screenshotOne.layer.cornerRadius = 5
        screenshotOne.layer.theme_borderColor = Color.borderCgColor
        screenshotOne.layer.masksToBounds = true

        screenshotTwo = UIImageView()
        screenshotTwo.image = #imageLiteral(resourceName: "placeholderCover")
        screenshotTwo.layer.borderWidth = 1 / UIScreen.main.scale
        screenshotTwo.layer.cornerRadius = 5
        screenshotTwo.layer.theme_borderColor = Color.borderCgColor
        screenshotTwo.layer.masksToBounds = true

        contentView.addSubview(screenshotOne)
        contentView.addSubview(dummyView)
        contentView.addSubview(screenshotTwo)

        setConstraints()
    }

    // MARK: - Additional Configuration

    override func configure(with item: Item) {
        super.configure(with: item)
        guard item.itemFirstTwoScreenshotsUrls.count > 1 else { return }
        if let url1 = URL(string: item.itemFirstTwoScreenshotsUrls[0]), let url2 = URL(string: item.itemFirstTwoScreenshotsUrls[1]) {
            let filter = Global.screenshotRoundedFilter(size: screenshotOne.frame.size, radius: 5)
            screenshotOne.af_setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
            screenshotTwo.af_setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter, imageTransition: .crossDissolve(0.2))
        }
    }

    // MARK: - Constraints

    override func setConstraints() {
        constrain(screenshotOne, screenshotTwo, dummyView, icon) { sOne, sTwo, dummy, icon in
            (icon.height ~== iconSize) ~ Global.notMaxPriority

            (sOne.height ~== portraitSize) ~ Global.notMaxPriority
            sOne.width ~== sOne.height ~/ magic
            sOne.top ~== icon.bottom ~+ spaceFromIcon
            sOne.bottom ~== sOne.superview!.bottom ~- Global.Size.margin.value

            (sTwo.height ~== portraitSize) ~ Global.notMaxPriority
            sTwo.width ~== sTwo.height ~/ magic
            sTwo.top ~== sOne.top
            sTwo.bottom ~== sOne.bottom

            dummy.height ~== sOne.height
            dummy.width ~== 15
            distribute(horizontally: sOne, dummy, sTwo)
            dummy.centerX ~== dummy.superview!.centerX
        }
    }
}
