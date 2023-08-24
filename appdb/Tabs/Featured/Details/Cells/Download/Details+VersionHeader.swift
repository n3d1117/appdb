//
//  Details+VersionHeader.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

class DetailsVersionHeader: TableViewHeader {

    var version: UILabel!
    static var height: CGFloat { 25 }
    private let backgroundGray: ThemeColorPicker = ["#E3E3E3", "#3E3E3E", "#313131"]

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
            version.leading ~== version.superview!.leading ~+ Global.Size.margin.value
            version.centerY ~== version.superview!.centerY
        }
    }
}
