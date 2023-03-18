//
//  AltStoreRepoAppCell.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import Cosmos
import Cartography

class AltStoreRepoAppCell: UITableViewCell {

    // UI objects
    var nameLabel: UILabel!
    var infoLabel: UILabel!
    var icon: UIImageView!

    // iOS
    func configure(app: AltStoreApp) {
        nameLabel.text = app.name
        infoLabel.text = (app.subtitle.isEmpty ? "" : app.subtitle + Global.bulletPoint) + app.version + Global.bulletPoint + app.formattedSize
        if let url = URL(string: app.image) {
            icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80 ~~ 60),
                             imageTransition: .crossDissolve(0.2))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        sharedInit()
        setConstraints()
    }

    // Shared initializer
    private func sharedInit() {
        // UI
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
        nameLabel.numberOfLines = 2
        nameLabel.makeDynamicFont()

        // Info Label
        infoLabel = UILabel()
        infoLabel.theme_textColor = Color.darkGray
        infoLabel.font = .systemFont(ofSize: 13 ~~ 12)
        infoLabel.numberOfLines = 3
        infoLabel.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor

        icon.layer.cornerRadius = Global.cornerRadius(from: (80 ~~ 60))

        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(icon)
    }

    // Set constraints
    private func setConstraints() {
        constrain(icon, nameLabel, infoLabel) { icon, name, info in
            icon.width ~== (80 ~~ 60)

            icon.height ~== icon.width

            icon.leading ~== icon.superview!.layoutMarginsGuide.leading
            icon.centerY ~== icon.superview!.centerY

            name.leading ~== icon.trailing ~+ (15 ~~ 12)
            name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
            name.top ~== name.superview!.top ~+ (20 ~~ 18)

            info.top ~== name.bottom ~+ (5 ~~ 4)
            info.leading ~== name.leading
            info.trailing ~== name.trailing
        }
    }
}
