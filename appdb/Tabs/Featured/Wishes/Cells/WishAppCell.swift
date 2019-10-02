//
//  WishAppCell.swift
//  appdb
//
//  Created by ned on 26/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class WishAppCell: UITableViewCell {

    var nameLabel: UILabel!
    var infoLabel: UILabel!
    var statusLabel: UILabel!
    var icon: UIImageView!

    func configure(with app: WishApp) {
        nameLabel.text = app.name
        infoLabel.text = "Price: %@".localizedFormat(app.price) + Global.bulletPoint + "Version: %@".localizedFormat(app.version)
        if app.status == .new {
            statusLabel.text = "↑\(app.requestersAmount)" + Global.bulletPoint + app.statusChangedAt
        } else {
            statusLabel.text = app.status.prettified + Global.bulletPoint + app.statusChangedAt
        }
        if let url = URL(string: app.image) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80 ~~ 60),
                             imageTransition: .crossDissolve(0.2))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setup()
        setConstraints()
    }

    private func setup() {

        //UI
        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        accessoryType = .disclosureIndicator

        // Name
        nameLabel = UILabel()
        nameLabel.theme_textColor = Color.title
        nameLabel.font = .systemFont(ofSize: 15 ~~ 14)
        nameLabel.numberOfLines = 1
        nameLabel.makeDynamicFont()

        // Info Label
        infoLabel = UILabel()
        infoLabel.theme_textColor = Color.darkGray
        infoLabel.font = .systemFont(ofSize: 13 ~~ 12)
        infoLabel.numberOfLines = 1
        infoLabel.makeDynamicFont()

        // Status Label
        statusLabel = UILabel()
        statusLabel.theme_textColor = Color.darkGray
        statusLabel.font = .systemFont(ofSize: 13 ~~ 12)
        statusLabel.numberOfLines = 1
        statusLabel.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor

        icon.layer.cornerRadius = Global.cornerRadius(from: (80 ~~ 60))

        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(icon)
    }

    // Set constraints
    private func setConstraints() {
        constrain(icon, nameLabel, infoLabel, statusLabel) { icon, name, info, status in
            icon.width ~== (80 ~~ 60)
            icon.height ~== icon.width
            icon.leading ~== icon.superview!.layoutMarginsGuide.leading
            icon.centerY ~== icon.superview!.centerY

            name.leading ~== icon.trailing ~+ (15 ~~ 12)
            name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
            name.centerY ~== name.superview!.centerY ~- (22 ~~ 20)

            info.top ~== name.bottom ~+ (5 ~~ 4)
            info.leading ~== name.leading
            info.trailing ~== name.trailing

            status.leading ~== info.leading
            status.trailing ~<= status.superview!.trailing ~- Global.Size.margin.value
            status.top ~== info.bottom ~+ (5 ~~ 4)
        }
    }
}
