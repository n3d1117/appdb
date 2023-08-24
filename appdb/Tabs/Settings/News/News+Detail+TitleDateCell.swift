//
//  News+Detail+TitleDateCell.swift
//  appdb
//
//  Created by ned on 07/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class NewsDetailTitleDateCell: UITableViewCell {

    var title: UILabel!
    var date: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray

        selectionStyle = .none

        // Title
        title = UILabel()
        title.font = .boldSystemFont(ofSize: (24 ~~ 23))
        title.theme_textColor = Color.title
        title.numberOfLines = 0
        title.makeDynamicFont()

        // Date
        date = UILabel()
        date.font = .systemFont(ofSize: (15 ~~ 14))
        date.theme_textColor = Color.copyrightText
        date.numberOfLines = 1
        date.makeDynamicFont()

        // Add separator
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height ~== 1 / UIScreen.main.scale
            line.leading ~== line.superview!.leading ~+ Global.Size.margin.value ~+ 5
            line.trailing ~== line.superview!.trailing
            line.top ~== line.superview!.bottom ~- (1 / UIScreen.main.scale)
        }

        contentView.addSubview(title)
        contentView.addSubview(date)

        setConstraints()
    }

    private func setConstraints() {
        constrain(title, date) { title, date in
            title.top ~== title.superview!.top ~+ Global.Size.margin.value ~+ 5
            title.leading ~== title.superview!.leading ~+ Global.Size.margin.value ~+ 5
            title.trailing ~== title.superview!.trailing ~- Global.Size.margin.value ~- 5

            date.top ~== title.bottom ~+ 7
            date.leading ~== title.leading
            date.trailing ~== title.trailing
            date.bottom ~== date.superview!.bottom ~- Global.Size.margin.value ~- 5
        }
    }
}
