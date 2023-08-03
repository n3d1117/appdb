//
//  NoScreenshotsSearchCell~Book+Stars.swift
//  appdb
//
//  Created by ned on 06/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

import Cosmos

class NoScreenshotsSearchCellBookWithStars: SearchCell {

    override var identifier: String { "noscreenshotscellbookstars" }
    override var height: CGFloat { coverHeight + margin * 2 }
    var stars: CosmosView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func configure(with item: Item) {
        self.name.text = item.itemName
        self.name.numberOfLines = 3
        self.seller.text = item.itemSeller
        self.stars.rating = item.itemNumberOfStars
        self.stars.text = item.itemRating
        guard let url = URL(string: item.itemIconUrl) else { return }
        icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.sharedSetup()

        stars = buildStars()

        contentView.addSubview(stars)

        constrain(icon, seller, stars) { icon, seller, stars in
            icon.height ~== coverHeight
            icon.bottom ~== icon.superview!.bottom ~- margin

            stars.leading ~== seller.leading
            stars.trailing ~<= stars.superview!.trailing ~- Global.Size.margin.value
            stars.top ~== seller.bottom ~+ (7 ~~ 6)
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
