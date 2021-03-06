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

    override var height: CGFloat { 45 }
    override var identifier: String { "link" }

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
        setBackgroundColor(Color.veryVeryLightGray)

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
            label.leading ~== label.superview!.leading ~+ Global.Size.margin.value ~+ 5
            label.trailing ~== label.superview!.trailing ~- Global.Size.margin.value
        }
    }
}
