//
//  NoScreenshotsSearchCell.swift
//  appdb
//
//  Created by ned on 11/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class NoScreenshotsSearchCell: SearchCell {

    override var identifier: String { return "noscreenshotscell" }
    override var height: CGFloat { return iconSize + margin * 2 }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.sharedSetup()

        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)

        constrain(icon) { icon in
            icon.bottom ~== icon.superview!.bottom ~- margin
        }
    }
}
