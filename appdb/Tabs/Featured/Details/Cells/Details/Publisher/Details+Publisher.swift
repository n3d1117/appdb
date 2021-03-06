//
//  Details+Publisher.swift
//  appdb
//
//  Created by ned on 05/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class DetailsPublisher: DetailsCell {

    override var height: CGFloat { UITableView.automaticDimension }
    override var identifier: String { "publisher" }

    var label: UILabel!

    convenience init(_ publisher: String, alignment: NSTextAlignment = .natural) {
        self.init(style: .default, reuseIdentifier: "publisher")

        selectionStyle = .none
        separatorInset.left = 10000
        layoutMargins = .zero
        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        label = UILabel()
        label.theme_textColor = Color.copyrightText
        label.font = .systemFont(ofSize: 12)
        label.makeDynamicFont()
        label.text = publisher
        label.numberOfLines = 0
        label.textAlignment = alignment

        contentView.addSubview(label)

        constrain(label) { label in
            label.leading ~== label.superview!.leading ~+ Global.Size.margin.value
            label.trailing ~== label.superview!.trailing ~- Global.Size.margin.value
            label.top ~== label.superview!.top ~+ 15
            label.bottom ~== label.superview!.bottom ~- (20 ~~ 15)
        }
    }
}
