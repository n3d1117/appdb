//
//  MyAppStoreCell.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class MyAppStoreCell: UICollectionViewCell {
    
    var name: UILabel!
    var bundleId: UILabel!
    var installButton: RoundedButton!
    var dummy: UIView!

    func configure(with app: MyAppStoreApp) {
        name.text = app.name + " (\(app.version))"
        bundleId.text = app.bundleId
        installButton.linkId = app.id
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    func setup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18 ~~ 16)
        name.numberOfLines = 1
        name.makeDynamicFont()

        // Bundle id
        bundleId = UILabel()
        bundleId.theme_textColor = Color.darkGray
        bundleId.font = .systemFont(ofSize: 14 ~~ 13)
        bundleId.numberOfLines = 1
        bundleId.makeDynamicFont()

        // Install button
        installButton = RoundedButton()
        installButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        installButton.setTitle("Install".localized().uppercased(), for: .normal)
        installButton.theme_tintColor = Color.softGreen
        installButton.makeDynamicFont()

        installButton.didSetTitle = { [unowned self] in
            self.installButton.sizeToFit()
            self.updateConstraintOnButtonSizeChange(width: self.installButton.bounds.size.width)
        }

        dummy = UIView()

        contentView.addSubview(name)
        contentView.addSubview(bundleId)
        contentView.addSubview(installButton)
        contentView.addSubview(dummy)

        constrain(name, bundleId, installButton, dummy) { name, bundleId, button, dummy in
            button.right ~== button.superview!.right ~- Global.Size.margin.value
            button.centerY ~== button.superview!.centerY

            dummy.height ~== 1
            dummy.centerY ~== dummy.superview!.centerY

            name.left ~== name.superview!.left ~+ Global.Size.margin.value
            name.bottom ~== dummy.top ~+ 2

            bundleId.left ~== name.left
            bundleId.top ~== dummy.bottom ~+ 3
        }

        installButton.sizeToFit()
        updateConstraintOnButtonSizeChange(width: installButton.bounds.size.width)
    }

    var group = ConstraintGroup()
    private func updateConstraintOnButtonSizeChange(width: CGFloat) {
        constrain(name, bundleId, replace: group) { name, bundle in
            name.right ~== name.superview!.right ~- width ~- (Global.Size.margin.value * 2)
            bundle.right ~== name.right
        }
    }

    // Hover animation
    override var isHighlighted: Bool {
        didSet {
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
