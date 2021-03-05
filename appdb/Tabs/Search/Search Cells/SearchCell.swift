//
//  SearchCell.swift
//  appdb
//
//  Created by ned on 11/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage

class SearchCell: UICollectionViewCell {

    func setConstraints() {}

    var tweaked: Bool = false {
        didSet {
            if oldValue != tweaked {
                name.theme_textColor = tweaked ? Color.mainTint: Color.title
                if tweaked {
                    name.numberOfLines = 1
                    paddingLabel.isHidden = false
                    constrain(paddingLabel, seller) { tweaked, seller in
                        tweaked.left ~== seller.left
                        tweaked.right ~<= tweaked.superview!.right ~- Global.Size.margin.value
                        tweaked.top ~== seller.bottom ~+ (7 ~~ 6)
                    }
                } else {
                    paddingLabel.isHidden = true
                    name.numberOfLines = 2
                }
            }
        }
    }

    lazy var paddingLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.theme_textColor = Color.invertedTitle
        label.font = .systemFont(ofSize: 10.0, weight: .semibold)
        label.makeDynamicFont()
        label.layer.backgroundColor = UIColor.gray.cgColor
        label.layer.cornerRadius = 6
        label.isHidden = true
        return label
    }()

    var magic: CGFloat { 0 }

    var identifier: String { "" }
    var height: CGFloat { 0 }

    var compactPortraitSize: CGFloat { 0 }
    var portraitSize: CGFloat { 0 }
    var mixedPortraitSize: CGFloat { 0 }

    var landscapeSize: CGFloat = (150 ~~ 140)
    var iconSize: CGFloat = (80 ~~ 70)
    var coverHeight: CGFloat = (80 ~~ 70) * 1.542
    var spaceFromIcon: CGFloat = (15 ~~ 12)

    var margin: CGFloat = Global.Size.margin.value

    var name: UILabel!
    var icon: UIImageView!
    var seller: UILabel!

    func configure(with item: Item) {
        self.name.text = item.itemName
        self.seller.text = item.itemSeller
        self.tweaked = item.itemIsTweaked
        if self.tweaked { paddingLabel.text = API.categoryFromId(id: item.itemCydiaCategoryId, type: .cydia).uppercased() }
        guard let url = URL(string: item.itemIconUrl) else { return }
        icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: iconSize), imageTransition: .crossDissolve(0.2))
    }

    func sharedSetup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        if #available(iOS 13.0, *) {
            contentView.layer.cornerRadius = 10
        } else {
            contentView.layer.cornerRadius = 6
        }
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18.5 ~~ 16.5)
        name.numberOfLines = 2
        name.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.contentMode = .scaleToFill

        // Seller
        seller = UILabel()
        seller.theme_textColor = Color.darkGray
        seller.font = .systemFont(ofSize: 14 ~~ 13)
        seller.numberOfLines = 1
        seller.makeDynamicFont()

        contentView.addSubview(name)
        contentView.addSubview(icon)
        contentView.addSubview(seller)
        contentView.addSubview(paddingLabel)

        constrain(name, seller, icon) { name, seller, icon in
            icon.width ~== iconSize
            icon.left ~== icon.superview!.left ~+ margin
            icon.top ~== icon.superview!.top ~+ margin

            (name.left ~== icon.right ~+ (15 ~~ 12)) ~ Global.notMaxPriority
            name.right ~== name.superview!.right ~- margin
            name.top ~== icon.top ~+ 3

            seller.left ~== name.left
            seller.top ~== name.bottom ~+ 3
            seller.right ~<= seller.superview!.right ~- margin
        }
    }

    // Hover animation
    override var isHighlighted: Bool {
        didSet {
            if #available(iOS 13.0, *) { return } // iOS 13 Context Menus do this automatically
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                }
            }
        }
    }
}
