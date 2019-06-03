//
//  Credits+Views.swift
//  appdb
//
//  Created by ned on 30/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Static
import UIKit
import Cartography

protocol Easter: class {
    func easterTime()
}

final class CreditsStaticCell: SimpleStaticCell {

    var primaryLabel: UILabel!
    var secondaryLabel: UILabel!
    var icon: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        icon = UIImageView()
        icon.layer.cornerRadius = 19
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.clipsToBounds = true

        primaryLabel = UILabel()
        primaryLabel.font = .systemFont(ofSize: (17 ~~ 16))
        primaryLabel.makeDynamicFont()
        primaryLabel.theme_textColor = Color.title

        secondaryLabel = UILabel()
        secondaryLabel.font = .systemFont(ofSize: (13 ~~ 12))
        secondaryLabel.makeDynamicFont()
        secondaryLabel.theme_textColor = Color.darkGray

        contentView.addSubview(icon)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: Row) {

        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView

        accessoryType = row.accessory.type

        if let base64ImageString = row.context?["base64Image"] as? String {
            icon.image = base64ImageString.imageFromBase64()
        }

        primaryLabel.text = row.text

        if let detail = row.detailText {
            secondaryLabel.text = detail
            constrain(icon, primaryLabel, secondaryLabel) { icon, primary, secondary in
                icon.leading ~== icon.superview!.leadingMargin
                icon.centerY ~== icon.superview!.centerY
                icon.width ~== 38
                icon.height ~== icon.width

                primary.leading ~== icon.trailing ~+ (15 ~~ 12)
                primary.trailing ~== primary.superview!.trailingMargin ~- Global.Size.margin.value
                primary.centerY ~== icon.centerY ~- 8

                secondary.leading ~== primary.leading
                secondary.trailing ~== primary.trailing
                secondary.top ~== primary.bottom ~+ 1
            }
        } else {
            constrain(icon, primaryLabel) { icon, primary in
                icon.leading ~== icon.superview!.leadingMargin
                icon.centerY ~== icon.superview!.centerY
                icon.width ~== 38
                icon.height ~== icon.width

                primary.leading ~== icon.trailing ~+ (15 ~~ 12)
                primary.trailing ~== primary.superview!.trailingMargin ~- Global.Size.margin.value
                primary.centerY ~== icon.centerY
            }
        }
    }
}

class CreditsIconView: UIView {

    weak var easterDelegate: Easter?

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: (15 ~~ 14))
        label.makeDynamicFont()
        label.theme_textColor = Color.darkGray
        label.textAlignment = .center
        return label
    }()

    lazy var shrug: UILabel = {
        let shrug = UILabel()
        shrug.font = .systemFont(ofSize: (12 ~~ 11))
        shrug.makeDynamicFont()
        shrug.theme_textColor = Color.copyrightText
        shrug.textAlignment = .center
        shrug.text = "¯\\_(ツ)_/¯"
        return shrug
    }()

    lazy var icon: UIImageView = {
        let icon = UIImageView()
        icon.layer.cornerRadius = Global.cornerRadius(from: 80)
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.clipsToBounds = true
        return icon
    }()

    /*lazy var githubButton: UIButton = {
        let button = UIButton(type: .system)
        button.theme_setTitleColor(Color.mainTint, forState: .normal)
        button.theme_tintColor = Color.mainTint
        button.titleLabel?.font = .systemFont(ofSize: (14 ~~ 13), weight: .semibold)
        button.setTitle("GitHub", for: .normal)
        button.makeDynamicFont()
        button.contentHorizontalAlignment = .center
        return button
    }()*/

    init(text: String, base64Image: String, easterDelegate: Easter) {
        super.init(frame: .zero)

        self.easterDelegate = easterDelegate

        icon.isUserInteractionEnabled = true
        icon.image = base64Image.imageFromBase64()
        label.text = text

        let gesture = UITapGestureRecognizer(target: self, action: #selector(animate))
        icon.addGestureRecognizer(gesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressGesture.minimumPressDuration = 10
        icon.addGestureRecognizer(longPressGesture)

        addSubview(icon)
        addSubview(label)
        addSubview(shrug)

        constrain(icon, label, shrug) { icon, label, shrug in
            icon.center ~== icon.superview!.center
            icon.width ~== 80
            icon.height ~== icon.width

            label.leading ~== label.superview!.leadingMargin ~+ Global.Size.margin.value
            label.trailing ~== label.superview!.trailingMargin ~- Global.Size.margin.value
            label.centerX ~== label.superview!.centerX
            label.top ~== icon.bottom ~+ 8

            shrug.leading ~== label.leading
            shrug.trailing ~== label.trailing
            shrug.centerX ~== label.centerX
            shrug.top ~== label.bottom ~+ 8
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func longPressed(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {

            easterDelegate?.easterTime()

            UIView.animate(withDuration: 0.08) {
                self.transform = .identity
            }
        }
    }

    @objc private func animate() {
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }, completion: { _ in
            UIView.animate(withDuration: 0.08) {
                self.transform = .identity
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if let touch = touches.first, touch.view is UIImageView {
            UIView.animate(withDuration: 0.08) {
                self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        UIView.animate(withDuration: 0.08) {
            self.transform = .identity
        }
    }
}
