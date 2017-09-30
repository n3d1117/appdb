//
//  Details+Review.swift
//  appdb
//
//  Created by ned on 08/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import RealmSwift

class DetailsReview: DetailsCell {
    
    var title: UILabel!
    var stars: CosmosView!
    var desc: ElasticLabel!
    
    static var height: CGFloat { return UITableViewAutomaticDimension }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with review: Review) {
        title.text = review.title
        stars.rating = review.rating
        stars.text = review.author.removedEmoji.replacingOccurrences(of: "by", with: "by".localized())
        desc.text = review.text.decoded
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = false
        selectionStyle = .none
        addSeparator()
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        // Name
        title = UILabel()
        title.font = .systemFont(ofSize: (15~~14))
        title.makeDynamicFont()
        title.numberOfLines = 0
        title.theme_textColor = Color.title
        
        // Rating
        stars = CosmosView()
        stars.starSize = 11
        stars.isUserInteractionEnabled = false
        stars.settings.totalStars = 5
        stars.settings.fillMode = .full
        stars.starMargin = 0
        stars.textSize = 11.5
        stars.textMargin = 4
        
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
        if !didSetupConstraints { didSetupConstraints = true
            constrain(title, stars, desc) { title, stars, desc in
                title.top == title.superview!.top + 15
                title.left == title.superview!.left + Global.size.margin.value
                title.right == title.superview!.right - Global.size.margin.value
                
                stars.left == title.left
                stars.right <= stars.superview!.right - Global.size.margin.value
                stars.top == title.bottom + (5~~4)
                
                desc.left == title.left
                desc.right == title.right
                desc.top == stars.bottom + 8 ~ Global.notMaxPriority
                desc.bottom == desc.superview!.bottom - 15
            }
        }
    }
}
