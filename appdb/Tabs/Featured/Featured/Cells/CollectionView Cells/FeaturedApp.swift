//
//  FeaturedApp.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class FeaturedApp: UICollectionViewCell {

    var title: UILabel!
    var category: UILabel!
    var icon: UIImageView!
    var dim: UIView = DimmableView.get()

    var tweaked = false {
        didSet { title.theme_textColor = tweaked ? Color.mainTint : Color.title }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        icon = UIImageView()
        icon.layer.cornerRadius = Global.cornerRadius(from: frame.size.width)
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = #imageLiteral(resourceName: "placeholderIcon")

        title = UILabel()
        title.theme_textColor = Color.title
        title.font = .systemFont(ofSize: 11.5)
        title.lineBreakMode = .byTruncatingTail
        title.numberOfLines = 2
        title.makeDynamicFont()

        category = UILabel()
        category.theme_textColor = Color.darkGray
        category.font = .systemFont(ofSize: 11.5)
        category.lineBreakMode = .byTruncatingTail
        category.numberOfLines = 1
        category.makeDynamicFont()

        dim.layer.cornerRadius = icon.layer.cornerRadius

        contentView.addSubview(icon)
        contentView.addSubview(title)
        contentView.addSubview(category)
        contentView.addSubview(dim)

        setConstraints()
    }

    private func setConstraints() {
        constrain(icon, title, category, dim) { icon, title, category, dim in
            icon.leading ~== icon.superview!.leading
            icon.top ~== icon.superview!.top
            icon.trailing ~== icon.superview!.trailing
            icon.height ~== frame.size.width
            icon.width ~== icon.height

            title.leading ~== title.superview!.leading
            title.trailing ~== title.superview!.trailing
            title.top ~== icon.bottom ~+ 5

            category.leading ~== category.superview!.leading
            category.trailing ~== category.superview!.trailing
            category.top ~== title.bottom ~+ (2 ~~ 1)

            dim.edges ~== icon.edges
        }
    }

    // Hover icon
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.icon.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                    self.dim.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                    self.dim.isHidden = false
                    self.dim.layer.opacity = DimmableView.opacity
                }
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: { [unowned self] in
                    self.icon.transform = .identity
                    self.dim.transform = .identity
                    self.dim.layer.opacity = 0
                }, completion: { _ in
                    self.dim.isHidden = true
                })
            }
        }
    }
}
