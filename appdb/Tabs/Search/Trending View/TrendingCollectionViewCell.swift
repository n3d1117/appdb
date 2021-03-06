//
//  TrendingCollectionViewCell.swift
//  appdb
//
//  Created by ned on 10/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class TrendingCollectionViewCell: UICollectionViewCell {

    lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: (22 ~~ 20), weight: .bold)
        label.makeDynamicFont()
        label.textAlignment = .natural
        label.theme_textColor = Color.title
        return label
    }()

    lazy var tagView: TagListView = {
        let tagView = TagListView()
        tagView.paddingX = 10 ~~ 8
        tagView.paddingX = 10 ~~ 8
        tagView.marginX = 10 ~~ 8
        tagView.marginY = 10 ~~ 8
        tagView.textFont = UIFont.systemFont(ofSize: (18 ~~ 16))
        return tagView
    }()

    func configure(with title: String, delegate: TagListViewDelegate, tags: [String]) {
        self.title.text = title
        self.title.addCharactersSpacing(1)
        tagView.delegate = delegate
        tagView.removeAllTags()
        tagView.addTags(tags)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(title)
        contentView.addSubview(tagView)

        constrain(title, tagView) { title, tagView in
            title.leading ~== title.superview!.leading
            title.top ~== title.superview!.top ~+ 5

            tagView.top ~== title.bottom ~+ 15
            tagView.leading ~== tagView.superview!.leading
            tagView.trailing ~== tagView.superview!.trailing
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
