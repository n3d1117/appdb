//
//  IconChooserCell.swift
//  appdb
//
//  Created by ned on 24/03/22.
//  Copyright © 2022 ned. All rights reserved.
//

import UIKit

class IconChooserCell: UITableViewCell {

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    var label: UILabel!
    var icon: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with label: String, value: String?, image: String) {
        self.label.text = label
        icon.image = UIImage(named: image)
        self.accessoryType = UIApplication.shared.alternateIconName == value ? .checkmark : .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Margins
        contentView.preservesSuperviewLayoutMargins = false
        preservesSuperviewLayoutMargins = false
        layoutMargins.left = 0
        separatorInset.left = 0

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray
        selectedBackgroundView = bgColorView

        // Icon
        icon = UIImageView()
        icon.layer.cornerRadius = Global.cornerRadius(from: 46)
        icon.layer.masksToBounds = true
        icon.image = #imageLiteral(resourceName: "placeholderIcon")
        icon.layer.borderWidth = 0.5
        icon.layer.theme_borderColor = Color.borderCgColor

        // Label
        label = UILabel()
        label.font = .systemFont(ofSize: (16 ~~ 15))
        label.numberOfLines = 1
        label.theme_textColor = Color.title
        label.makeDynamicFont()

        contentView.addSubview(icon)
        contentView.addSubview(label)

        setConstraints()
    }

    private func setConstraints() {
        constrain(icon, label) { icon, label in
            icon.width ~== 46
            icon.height ~== icon.width

            icon.leading ~== icon.superview!.leading ~+ Global.Size.margin.value
            icon.centerY ~== icon.superview!.centerY

            label.leading ~== icon.trailing ~+ (15 ~~ 12)
            label.trailing ~== label.superview!.trailing ~- Global.Size.margin.value
            label.centerY ~== icon.centerY
        }
    }
}
