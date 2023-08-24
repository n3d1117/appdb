//
//  NoScreenshotsSearchCell~Book.swift
//  appdb
//
//  Created by ned on 05/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class NoScreenshotsSearchCellBook: SearchCell {

    override var identifier: String { "noscreenshotscellbook" }
    override var height: CGFloat { coverHeight + margin * 2 }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func configure(with item: Item) {
        self.name.text = item.itemName
        self.name.numberOfLines = 3
        self.seller.text = item.itemSeller
        guard let url = URL(string: item.itemIconUrl) else { return }
        icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.sharedSetup()

        constrain(icon) { icon in
            icon.height ~== coverHeight
            icon.bottom ~== icon.superview!.bottom ~- margin
        }
    }
}
