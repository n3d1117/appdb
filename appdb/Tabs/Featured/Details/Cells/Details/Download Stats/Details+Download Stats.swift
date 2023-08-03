//
//  Details+Download Stats.swift
//  appdb
//
//  Created by stev3fvcks on 05.04.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit

class DetailsDownloadStats: DetailsCell {

    var title: UILabel!

    var downloadStats: UILabel!

    override var height: CGFloat { UITableView.automaticDimension }
    override var identifier: String { "downloads" }

    convenience init(content: Item) {
        self.init(style: .default, reuseIdentifier: "downloads")

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        title = UILabel()
        title.theme_textColor = Color.title
        title.text = "Downloads".localized()
        title.font = .systemFont(ofSize: (16 ~~ 15))
        title.makeDynamicFont()
        contentView.addSubview(title)

        var statsText = ""

        statsText += "%@ today".localizedFormat(content.downloadsDay)
        statsText += Global.bulletPoint + "%@ this week".localizedFormat(content.downloadsWeek)
        statsText += Global.bulletPoint + "%@ this month".localizedFormat(content.downloadsMonth)
        statsText += "\n" + "%@ this year".localizedFormat(content.downloadsYear)
        statsText += Global.bulletPoint + "%@ total".localizedFormat(content.downloadsAll)

        downloadStats = UILabel()
        downloadStats.theme_textColor = Color.darkGray
        downloadStats.text = statsText
        downloadStats.font = .systemFont(ofSize: (13.5 ~~ 12.5))
        downloadStats.makeDynamicFont()
        downloadStats.setLineSpacing(lineHeightMultiple: 1.5)
        downloadStats.textAlignment = (Global.isRtl ? .right : .left)
        downloadStats.numberOfLines = 10

        contentView.addSubview(downloadStats)

        setConstraints()
    }

    override func setConstraints() {
        constrain(title) { title in
            title.top ~== title.superview!.top ~+ 12
            title.leading ~== title.superview!.leading ~+ Global.Size.margin.value

            constrain(downloadStats) { downloadStats in
                (downloadStats.top ~== title.bottom) ~ Global.notMaxPriority
                downloadStats.leading ~== title.leading
                downloadStats.trailing ~== downloadStats.superview!.trailing ~- Global.Size.margin.value
                downloadStats.bottom ~== downloadStats.superview!.bottom ~- 15
            }
        }
    }
}
