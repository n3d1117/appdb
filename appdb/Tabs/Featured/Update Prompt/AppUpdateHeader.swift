//
//  AppUpdateHeader.swift
//  appdb
//
//  Created by ned on 28/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class AppUpdateHeader: UITableViewCell {

    static var height: CGFloat = (100 ~~ 80) + Global.Size.margin.value * 2

    var name: UILabel!
    var icon: UIImageView!
    var yourVersion: UILabel!
    var newVersion: UILabel!
    var updateButton: RoundedButton!

    func configure(with app: CydiaApp, linkId: String) {
        name.text = app.name.decoded
        updateButton.linkId = linkId
        if Global.isIpad {
            yourVersion.text = "Your version: %@".localizedFormat(Global.appVersion)
            newVersion.text = "New version: %@".localizedFormat(app.version)
        } else {
            yourVersion.text = Global.isRtl ?
                (app.version + " ← " + Global.appVersion) :
                (Global.appVersion + " → " + app.version)
            newVersion.text = ""
        }
        if let url = URL(string: app.image) {
            icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: (100 ~~ 80)), imageTransition: .crossDissolve(0.2))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        layoutMargins.left = 0
        separatorInset.left = 0

        // UI
        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18.5 ~~ 16.5)
        name.numberOfLines = 3
        name.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.layer.cornerRadius = Global.cornerRadius(from: (100 ~~ 80))

        // Update button
        updateButton = RoundedButton()
        updateButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        updateButton.makeDynamicFont()
        updateButton.setTitle("Update".localized().uppercased(), for: .normal)
        updateButton.theme_tintColor = Color.softGreen

        // Your version
        yourVersion = UILabel()
        yourVersion.theme_textColor = Color.darkGray
        yourVersion.font = .systemFont(ofSize: 15 ~~ 14)
        yourVersion.numberOfLines = 1
        yourVersion.makeDynamicFont()

        // New version
        newVersion = UILabel()
        newVersion.theme_textColor = Color.darkGray
        newVersion.font = .systemFont(ofSize: 15 ~~ 14)
        newVersion.numberOfLines = 1
        newVersion.makeDynamicFont()

        contentView.addSubview(name)
        contentView.addSubview(icon)
        contentView.addSubview(updateButton)
        contentView.addSubview(yourVersion)
        contentView.addSubview(newVersion)

        setConstraints()
    }

    private func setConstraints() {
        constrain(name, icon, updateButton, yourVersion, newVersion) { name, icon, button, your, new in
            icon.width ~== (100 ~~ 80)
            icon.height ~== icon.width

            icon.leading ~== icon.superview!.leading ~+ Global.Size.margin.value
            icon.top ~== icon.superview!.top ~+ Global.Size.margin.value

            name.leading ~== icon.trailing ~+ (15 ~~ 12)
            name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
            name.top ~== icon.top ~+ 3

            button.trailing ~== button.superview!.trailing ~- Global.Size.margin.value
            button.bottom ~== icon.bottom ~- 3

            your.leading ~== name.leading
            your.top ~== name.bottom ~+ 4
            your.trailing ~== name.trailing

            new.leading ~== your.leading
            new.top ~== your.bottom ~+ 3
            new.trailing ~== your.trailing
        }
    }
}
