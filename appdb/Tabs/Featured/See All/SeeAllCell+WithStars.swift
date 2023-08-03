//
//  SeeAllCell+WithStars.swift
//  appdb
//
//  Created by ned on 22/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cosmos

class SeeAllCellWithStars: UITableViewCell {

    // UI objects
    var nameLabel: UILabel!
    var infoLabel: UILabel!
    var icon: UIImageView!
    var stars: CosmosView!

    // iOS
    func configure(name: String, category: String, version: String, iconUrl: String, size: String, rating: Double, num: String) {
        nameLabel.text = name
        infoLabel.text = category + Global.bulletPoint + version + Global.bulletPoint + size
        stars.rating = rating
        stars.text = num
        if let url = URL(string: iconUrl) {
            icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"),
                             filter: Global.roundedFilter(from: 80 ~~ 60),
                             imageTransition: .crossDissolve(0.2))
        }
    }

    // Book
    func configure(name: String, author: String, language: String, categoryId: String, coverUrl: String, rating: Double, num: String) {
        nameLabel.text = name
        if !language.isEmpty {
            infoLabel.text = author + Global.bulletPoint + language
        } else if !categoryId.isEmpty {
            infoLabel.text = author + Global.bulletPoint + API.categoryFromId(id: categoryId, type: .books)
        } else {
            infoLabel.text = author
        }
        stars.rating = rating
        stars.text = num
        if let url = URL(string: coverUrl) {
            icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
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
        infoLabel.numberOfLines = 1
        infoLabel.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor

        if reuseIdentifier != "seeallcellwithstars_book" {
            icon.layer.cornerRadius = Global.cornerRadius(from: (80 ~~ 60))
        }

        stars = buildStars()

        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(icon)
        contentView.addSubview(stars)
    }

    // Set constraints
    private func setConstraints() {
        constrain(icon, nameLabel, infoLabel, stars) { icon, name, info, stars in
            icon.width ~== ((reuseIdentifier == "seeallcellwithstars_book" ? 70 : 80) ~~ 60)

            if reuseIdentifier == "seeallcellwithstars_book" {
                icon.height ~== icon.width * 1.542
            } else {
                icon.height ~== icon.width
            }
            icon.leading ~== icon.superview!.layoutMarginsGuide.leading
            icon.centerY ~== icon.superview!.centerY

            name.leading ~== icon.trailing ~+ (15 ~~ 12)
            name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
            name.centerY ~== name.superview!.centerY ~- (22 ~~ 20)

            info.top ~== name.bottom ~+ (5 ~~ 4)
            info.leading ~== name.leading
            info.trailing ~== name.trailing

            stars.leading ~== info.leading
            stars.trailing ~<= stars.superview!.trailing ~- Global.Size.margin.value
            stars.top ~== info.bottom ~+ (7 ~~ 6)
        }
    }

    private func buildStars() -> CosmosView {
        let stars = CosmosView()
        stars.settings.starSize = 12
        stars.settings.updateOnTouch = false
        stars.settings.textFont = .systemFont(ofSize: 12 ~~ 11)
        stars.settings.totalStars = 5
        stars.settings.fillMode = .half
        stars.settings.textMargin = 2
        stars.settings.starMargin = 0
        return stars
    }
}
