//
//  LibrarySectionFooterView.swift
//  appdb
//
//  Created by ned on 01/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class LibrarySectionFooterView: UICollectionReusableView {

    lazy var primaryLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.lightErrorMessage
        label.font = .systemFont(ofSize: (20 ~~ 18), weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.makeDynamicFont()
        return label
    }()

    lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.lightErrorMessage
        label.font = .systemFont(ofSize: (17 ~~ 15))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.makeDynamicFont()
        return label
    }()

    func configure(_ primaryText: String, secondaryText: String = "") {
        if primaryText.isEmpty {
            primaryLabel.removeFromSuperview()
            secondaryLabel.removeFromSuperview()
        } else {
            if !primaryLabel.isDescendant(of: self) {
                addSubview(primaryLabel)
                if !secondaryLabel.isDescendant(of: self) {
                    addSubview(secondaryLabel)
                }
                setupConstraints()
            }
            primaryLabel.text = primaryText
            secondaryLabel.text = secondaryText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        constrain(primaryLabel, secondaryLabel) { primary, secondary in
            primary.centerY ~== primary.superview!.centerY ~- 20
            primary.centerX ~== primary.superview!.centerX
            primary.leading ~== primary.superview!.leading ~+ (130 ~~ 50)
            primary.trailing ~== primary.superview!.trailing ~- (130 ~~ 50)

            secondary.top ~== primary.bottom ~+ 5
            secondary.centerX ~== secondary.superview!.centerX
            secondary.leading ~== primary.leading
            secondary.trailing ~== primary.trailing
        }
    }
}
