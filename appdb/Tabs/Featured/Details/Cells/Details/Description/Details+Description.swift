//
//  Details+Description.swift
//  appdb
//
//  Created by ned on 23/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class DetailsDescription: DetailsCell {

    var title: UILabel!
    var desc: ElasticLabel!

    var descriptionText: String! = ""

    override var height: CGFloat { descriptionText.isEmpty ? 0 : UITableView.automaticDimension }
    override var identifier: String { "description" }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with description: String) {
        descriptionText = description
        desc.text = descriptionText.decoded
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        title = UILabel()
        title.theme_textColor = Color.title
        title.text = "Description".localized()
        title.font = .systemFont(ofSize: (16 ~~ 15))
        title.makeDynamicFont()

        desc = ElasticLabel()
        desc.theme_textColor = Color.darkGray
        desc.theme_backgroundColor = Color.veryVeryLightGray
        desc.makeDynamicFont()

        contentView.addSubview(title)
        contentView.addSubview(desc)

        setConstraints()
    }

    override func setConstraints() {
        constrain(title, desc) { title, desc in
            title.top ~== title.superview!.top ~+ 12
            title.left ~== title.superview!.left ~+ Global.Size.margin.value
            title.right ~== title.superview!.right ~- Global.Size.margin.value

            (desc.top ~== title.bottom ~+ 8) ~ Global.notMaxPriority
            desc.left ~== title.left
            desc.right ~== title.right
            desc.bottom ~== desc.superview!.bottom ~- 15
        }
    }

    // Just a placeholder
    convenience init() { self.init(style: .default, reuseIdentifier: "description") }
}
