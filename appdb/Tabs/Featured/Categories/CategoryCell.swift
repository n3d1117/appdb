//
//  CategoryCell.swift
//  appdb
//
//  Created by ned on 23/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    var name: UILabel!
    var amount: UILabel!
    var icon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Margins
        contentView.preservesSuperviewLayoutMargins = false
        preservesSuperviewLayoutMargins = false
        layoutMargins.left = Global.Size.margin.value
        separatorInset.left = Global.Size.margin.value

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView

        // Icon
        icon = UIImageView()
        if reuseIdentifier == "category_ios" {
            icon.layer.cornerRadius = Global.cornerRadius(from: 30)
            icon.image = #imageLiteral(resourceName: "placeholderIcon")
        } else {
            icon.layer.cornerRadius = 0
            icon.image = #imageLiteral(resourceName: "placeholderCover")
        }
        icon.layer.borderWidth = 0.5
        icon.layer.theme_borderColor = Color.borderCgColor

        // Name
        name = UILabel()
        name.font = .systemFont(ofSize: (16 ~~ 15))
        name.numberOfLines = 1
        name.makeDynamicFont()

        // Name
        amount = UILabel()
        amount.font = .systemFont(ofSize: (14 ~~ 13))
        amount.numberOfLines = 1
        amount.makeDynamicFont()

        // Amount
        contentView.addSubview(icon)
        contentView.addSubview(name)
        contentView.addSubview(amount)

        setConstraints()
    }

    private func setConstraints() {
        constrain(icon, name, amount) { icon, name, amount in
            icon.width ~== 30

            if reuseIdentifier == "category_ios" {
                icon.height ~== icon.width
            } else if reuseIdentifier == "category_books" {
                icon.height ~== icon.width ~* 1.542
            }

            icon.leading ~== icon.superview!.leading ~+ Global.Size.margin.value
            icon.centerY ~== icon.superview!.centerY

            name.leading ~== icon.trailing ~+ 10
            name.centerY ~== icon.centerY

            amount.trailing ~== amount.superview!.trailing ~- Global.Size.margin.value
            amount.centerY ~== name.centerY
        }
    }
}
