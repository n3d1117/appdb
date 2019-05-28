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
    
    override var height: CGFloat { return UITableView.automaticDimension }
    override var identifier: String { return "publisher" }

    var label: UILabel!

    convenience init(_ publisher: String, alignment: NSTextAlignment = .left) {
        self.init(style: .default, reuseIdentifier: "publisher")

        selectionStyle = .none
        separatorInset.left = 10000
        layoutMargins = .zero
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        label = UILabel()
        label.theme_textColor = Color.copyrightText
        label.font = .systemFont(ofSize: 12)
        label.makeDynamicFont()
        label.text = publisher
        label.numberOfLines = 0
        label.textAlignment = alignment

        contentView.addSubview(label)

        constrain(label) { label in
            label.left ~== label.superview!.left ~+ Global.Size.margin.value
            label.right ~== label.superview!.right ~- Global.Size.margin.value
            label.top ~== label.superview!.top ~+ 15
            label.bottom ~== label.superview!.bottom ~- (20 ~~ 15)
        }
    }
}
