//
//  LibrarySectionHeaderView.swift
//  appdb
//
//  Created by ned on 27/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class LibrarySectionHeaderView: UICollectionReusableView {

    lazy var label: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.copyrightText
        label.font = .systemFont(ofSize: (18.5 ~~ 17.5), weight: .semibold)
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.makeDynamicFont()
        return label
    }()

    lazy var helpButton: UIButton = {
        let why = UIButton(type: .system)
        why.setImage(UIImage(named: "question")?.withRenderingMode(.alwaysTemplate), for: .normal)
        why.theme_tintColor = Color.copyrightText
        return why
    }()

    lazy var trashButton: UIButton = {
        let trash = UIButton(type: .system)
        trash.setImage(UIImage(named: "trash")?.withRenderingMode(.alwaysTemplate), for: .normal)
        trash.theme_tintColor = Color.copyrightText
        trash.isHidden = true
        trash.alpha = 0.9
        return trash
    }()

    func configure(_ text: String, showsTrash: Bool = false) {
        label.text = text
        trashButton.isHidden = !showsTrash
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        addSubview(helpButton)
        addSubview(trashButton)

        constrain(label, helpButton, trashButton) { label, help, more in
            label.leading ~== label.superview!.leading ~+ Global.Size.margin.value
            label.trailing ~== label.superview!.trailing
            label.centerY ~== label.superview!.centerY

            help.height ~== (22 ~~ 20)
            help.width ~== help.height
            help.trailing ~== help.superview!.trailing ~- Global.Size.margin.value
            help.centerY ~== label.centerY

            more.height ~== (22 ~~ 20)
            more.width ~== more.height
            more.trailing ~== help.leading ~- (12 ~~ 10)
            more.centerY ~== help.centerY
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
