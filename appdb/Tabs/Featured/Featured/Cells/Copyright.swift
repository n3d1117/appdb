//
//  Copyright.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

class Copyright: FeaturedCell {

    var copyrightNotice: UILabel!

    override var height: CGFloat { UITableView.automaticDimension }

    convenience init() {
        self.init(style: .default, reuseIdentifier: Featured.CellType.copyright.rawValue)

        selectionStyle = .none
        separatorInset.left = 10000
        layoutMargins = .zero
        theme_backgroundColor = Color.tableViewBackgroundColor
        setBackgroundColor(Color.tableViewBackgroundColor)

        // Hide ugly white line on iOS 8
        layer.theme_borderColor = Color.tableViewCGBackgroundColor
        layer.borderWidth = 1.0

        copyrightNotice = UILabel()
        copyrightNotice.theme_textColor = Color.copyrightText
        copyrightNotice.font = .systemFont(ofSize: 12)
        let newLine = " " ~~ "\n"
        let siteName = Global.mainSite.components(separatedBy: "https://")[1].components(separatedBy: "/")[0]
        copyrightNotice.text = "© 2012-\(currentYear) \(siteName).\(newLine)" +
        "We do not host any prohibited content. All data is publicly available via iTunes API.".localized()
        copyrightNotice.numberOfLines = 0
        copyrightNotice.makeDynamicFont()

        contentView.addSubview(copyrightNotice)

        constrain(copyrightNotice) { notice in
            if #available(iOS 11.0, *) {
                notice.left ~== notice.superview!.safeAreaLayoutGuide.left ~+ Global.Size.margin.value
            } else {
                notice.left ~== notice.superview!.left ~+ Global.Size.margin.value
            }
            notice.right ~== notice.superview!.right ~- Global.Size.margin.value
            notice.top ~== notice.superview!.top ~+ 15
            (notice.bottom ~== notice.superview!.bottom ~- (25 ~~ 15)) ~ Global.notMaxPriority
        }
    }

    private var currentYear: String {
        let components = NSCalendar.current.dateComponents([.year], from: Date())
        guard let year = components.year else { return "???" }
        return "\(year)"
    }
}
