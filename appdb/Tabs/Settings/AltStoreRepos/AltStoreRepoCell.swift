//
//  AltStoreRepoCell.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit

class AltStoreRepoCell: UITableViewCell {

    var name: UILabel!
    var identifier: UILabel!
    var lastChecked: UILabel!
    var totalApps: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with repo: AltStoreRepo) {
        name.text = repo.name
        identifier.text = repo.identifier
        lastChecked.text = "Last update " + repo.lastCheckedAt
        totalApps.text = repo.totalApps.description + " Apps"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray
        selectionStyle = .none

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 15 ~~ 14)
        name.numberOfLines = 2
        name.makeDynamicFont()

        // Identifier
        identifier = UILabel()
        identifier.theme_textColor = Color.darkGray
        identifier.font = .systemFont(ofSize: 13 ~~ 12)
        identifier.numberOfLines = 1
        identifier.makeDynamicFont()

        // Last checked
        lastChecked = UILabel()
        lastChecked.theme_textColor = Color.copyrightText
        lastChecked.font = .systemFont(ofSize: 11 ~~ 10)

        // Total apps
        totalApps = UILabel()
        totalApps.theme_textColor = Color.copyrightText
        totalApps.font = .systemFont(ofSize: 14 ~~ 13)

        contentView.addSubview(name)
        contentView.addSubview(identifier)
        contentView.addSubview(lastChecked)
        contentView.addSubview(totalApps)

        setConstraints()
    }

    private func setConstraints() {
        constrain(name, identifier, lastChecked, totalApps) { name, identifier, lastChecked, totalApps in

            name.leading ~== name.superview!.layoutMarginsGuide.leading
            name.trailing ~== name.superview!.layoutMarginsGuide.trailing
            name.top ~== name.superview!.top ~+ (15 ~~ 13)

            identifier.top ~== name.bottom ~+ (5 ~~ 4)
            identifier.leading ~== name.leading
            identifier.trailing ~== name.trailing

            lastChecked.top ~== lastChecked.superview!.top ~+ (12 ~~ 10)
            lastChecked.trailing ~== lastChecked.superview!.trailing ~- 15

            totalApps.top ~== lastChecked.bottom ~+ (14 ~~ 11)
            totalApps.trailing ~== lastChecked.trailing
        }
    }
}
