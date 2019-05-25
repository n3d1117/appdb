//
//  Details+VersionHeader.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import SwiftTheme

class DetailsVersionHeader: TableViewHeader {
    var version: UILabel!
    static var height: CGFloat { return 25 }
    private let backgroundGray: ThemeColorPicker = ["#E3E3E3", "#3E3E3E"]

    convenience init(_ versionNumber: String, isLatest: Bool) {
        self.init(frame: .zero)

        preservesSuperviewLayoutMargins = false
        layoutMargins.left = 0
        addSeparator(full: true)

        contentView.theme_backgroundColor = backgroundGray

        // Setting the background color on UITableViewHeaderFooterView has been deprecated.
        // So i set a custom UIView with desired background color to the backgroundView property.
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = backgroundGray
        backgroundView = bgColorView

        version = UILabel()
        version.font = UIFont.systemFont(ofSize: (16 ~~ 15))
        version.makeDynamicFont()
        version.numberOfLines = 1
        version.theme_textColor = Color.title
        version.text = versionNumber

        contentView.addSubview(version)

        constrain(version) { version in
            version.left ~== version.superview!.left ~+ Global.Size.margin.value
            version.centerY ~== version.superview!.centerY
        }
    }
}
