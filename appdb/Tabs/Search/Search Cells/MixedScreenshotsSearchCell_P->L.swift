//
//  MixedScreenshotsSearchCell_P->L.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class MixedScreenshotsSearchCellTwo: SearchCell {

    override var height: CGFloat { round(iconSize + mixedPortraitSize + margin * 2 + spaceFromIcon) }

    var screenshotOne: UIImageView!
    var screenshotTwo: UIImageView!

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
        contentView.addSubview(screenshotTwo)

        setConstraints()
    }

    // MARK: - Additional Configuration

    override func configure(with item: Item) {
        super.configure(with: item)
        guard item.itemFirstTwoScreenshotsUrls.count > 1 else { return }
        if let url1 = URL(string: item.itemFirstTwoScreenshotsUrls[0]), let url2 = URL(string: item.itemFirstTwoScreenshotsUrls[1]) {
            let filter1 = Global.screenshotRoundedFilter(size: screenshotOne.frame.size, radius: 5)
            let filter2 = Global.screenshotRoundedFilter(size: screenshotTwo.frame.size, radius: 5)
            screenshotOne.af.setImage(withURL: url1, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter1, imageTransition: .crossDissolve(0.2))
            screenshotTwo.af.setImage(withURL: url2, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), filter: filter2, imageTransition: .crossDissolve(0.2))
        }
    }

    // MARK: - Constraints

    override func setConstraints() {
        constrain(screenshotOne, screenshotTwo, icon) { sOne, sTwo, icon in
            (icon.height ~== iconSize) ~ Global.notMaxPriority

            (sOne.height ~== mixedPortraitSize) ~ Global.notMaxPriority
            sOne.width ~== sOne.height ~/ magic
            sOne.leading ~== sOne.superview!.leading ~+ margin + 10
            sOne.top ~== icon.bottom ~+ spaceFromIcon
            (sOne.bottom ~== sOne.superview!.bottom ~- margin) ~ Global.notMaxPriority

            (sTwo.height ~== sOne.height) ~ Global.notMaxPriority
            sTwo.width ~== sTwo.height ~* magic
            sTwo.trailing ~== sTwo.superview!.trailing ~- margin - 10
            (sTwo.bottom ~== sOne.bottom) ~ Global.notMaxPriority
            sTwo.top ~== sOne.top

            distribute(by: 15, horizontally: sOne, sTwo)
        }
    }
}
