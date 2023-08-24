//
//  Details+Review.swift
//  appdb
//
//  Created by ned on 08/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

import Cosmos

class DetailsReview: DetailsCell {

    var title: UILabel!
    var stars: CosmosView!
    var desc: ElasticLabel!

    static var height: CGFloat { UITableView.automaticDimension }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(with review: Review) {
        title.text = review.title
        stars.rating = review.rating
        stars.text = review.author.replacingOccurrences(of: "by", with: "by".localized())
        desc.text = review.text.decoded
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = false
        selectionStyle = .none
        addSeparator()

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray

        // Name
        title = UILabel()
        title.font = .systemFont(ofSize: (15 ~~ 14))
        title.makeDynamicFont()
        title.numberOfLines = 0
        title.theme_textColor = Color.title

        // Rating
        stars = CosmosView()
        stars.settings.starSize = 11
        stars.isUserInteractionEnabled = false
        stars.settings.totalStars = 5
        stars.settings.fillMode = .full
        stars.settings.starMargin = 0
        // stars.settings.textSize = 11.5
        stars.settings.textMargin = 4

        // Desc
        desc = ElasticLabel()
        desc.theme_textColor = Color.darkGray
        desc.makeDynamicFont()

        contentView.addSubview(title)
        contentView.addSubview(stars)
        contentView.addSubview(desc)

        setConstraints()
    }

    override func setConstraints() {
        constrain(title, stars, desc) { title, stars, desc in
            title.top ~== title.superview!.top ~+ 15
            title.leading ~== title.superview!.leading ~+ Global.Size.margin.value
            title.trailing ~== title.superview!.trailing ~- Global.Size.margin.value

            stars.leading ~== title.leading
            stars.trailing ~<= stars.superview!.trailing ~- Global.Size.margin.value
            stars.top ~== title.bottom ~+ (5 ~~ 4)

            desc.leading ~== title.leading
            desc.trailing ~== title.trailing
            (desc.top ~== stars.bottom ~+ 8) ~ Global.notMaxPriority
            desc.bottom == desc.superview!.bottom ~- 15
        }
    }
}
