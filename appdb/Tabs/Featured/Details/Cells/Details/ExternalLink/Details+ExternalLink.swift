//
//  Details+ExternalLink.swift
//  appdb
//
//  Created by ned on 05/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class DetailsExternalLink: DetailsCell {

    override var height: CGFloat { return 45 }
    override var identifier: String { return "link" }

    var label: UILabel!
    var url: String!
    var devId: String!
    var devName: String!

    convenience init(text: String, url: String = "", devId: String = "", devName: String = "") {
        self.init(style: .default, reuseIdentifier: "link")

        preservesSuperviewLayoutMargins = false
        addSeparator()

        accessoryType = .disclosureIndicator

        self.url = url
        self.devId = devId
        self.devName = devName

        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView

        label = UILabel()
        label.text = text.localized()
        label.font = .systemFont(ofSize: (16 ~~ 15))
        label.makeDynamicFont()
        label.theme_textColor = Color.title
        contentView.addSubview(label)

        constrain(label) { label in
            label.centerY ~== label.superview!.centerY
            label.left ~== label.superview!.left ~+ Global.Size.margin.value ~+ 5
            label.right ~== label.superview!.right ~- Global.Size.margin.value
        }
    }
}
