//
//  Details+TweakedNotice.swift
//  appdb
//
//  Created by ned on 26/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

protocol DynamicContentRedirection: AnyObject {
    func dynamicContentSelected(type: ItemType, id: String)
}

class DetailsTweakedNotice: DetailsCell {

    var trackid: String!
    var section: String!

    var title: UILabel!
    var content: UILabel!
    var seeOriginal: UIButton!

    override var height: CGFloat { (trackid.isEmpty || trackid == "0") ? 0 : UITableView.automaticDimension }
    override var identifier: String { "tweakednotice" }

    weak var delegate: DynamicContentRedirection?

    convenience init(originalTrackId: String, originalSection: String, delegate: DynamicContentRedirection) {
        self.init(style: .default, reuseIdentifier: "tweakednotice")

        self.trackid = originalTrackId
        self.section = originalSection
        self.delegate = delegate

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        if !trackid.isEmpty, trackid != "0" {
            theme_backgroundColor = Color.veryVeryLightGray
            setBackgroundColor(Color.veryVeryLightGray)

            title = UILabel()
            title.theme_textColor = Color.title
            title.text = "Tweaked Version Notice".localized()
            title.font = .systemFont(ofSize: (16 ~~ 15))
            title.makeDynamicFont()

            content = UILabel()
            content.theme_textColor = Color.darkGray
            content.text = "This app was tweaked to provide additional features. Be sure to download it from verified crackers only, because no one except them can guarantee that it doesn't contain any malicious code.".localized()
            content.font = .systemFont(ofSize: (13.5 ~~ 12.5))
            content.numberOfLines = 0
            content.makeDynamicFont()

            seeOriginal = ButtonFactory.createChevronButton(text: "See Original".localized(), color: Color.darkGray, bold: false)
            seeOriginal.addTarget(self, action: #selector(self.originalSelected), for: .touchUpInside)

            contentView.addSubview(title)
            contentView.addSubview(content)
            contentView.addSubview(seeOriginal)

            setConstraints()
        }
    }

    @objc func originalSelected() {
        var type: ItemType?
        if section == "ios" {
            type = .ios
        } else if section == "cydia" {
            type = .cydia
        }
        if let type = type { delegate?.dynamicContentSelected(type: type, id: trackid) }
    }

    override func setConstraints() {
        constrain(title, content, seeOriginal) { title, content, seeOriginal in
            title.top ~== title.superview!.top ~+ 12
            title.leading ~== title.superview!.leading ~+ Global.Size.margin.value

            (content.top ~== title.bottom ~+ 8) ~ Global.notMaxPriority
            content.leading ~== title.leading
            content.trailing ~== content.superview!.trailing ~- Global.Size.margin.value
            content.bottom ~== content.superview!.bottom ~- 15

            seeOriginal.trailing ~== seeOriginal.superview!.trailing ~- Global.Size.margin.value
            seeOriginal.centerY ~== title.centerY
        }
    }
}
