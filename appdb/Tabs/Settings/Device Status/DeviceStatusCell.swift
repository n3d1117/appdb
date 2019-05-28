//
//  DeviceStatusCell.swift
//  appdb
//
//  Created by ned on 22/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class DeviceStatusCell: UITableViewCell {

    var statusLeft, typeLeft, titleLeft, bundleLeft, purposeLeft, acknowledgedLeft, statusShortLeft, statusTextLeft: UILabel!
    var status, type, title, bundle, purpose, acknowledged, statusShort, statusText: UILabel!

    var timestamp: UILabel!

    var moreImageButton: UIImageView!

    func updateContent(with item: DeviceStatusItem) {
        timestamp.text = prettify(item.timestamp)
        status.text = prettify(item.status)
        type.text = prettify(item.type)
        title.text = prettify(item.title)
        bundle.text = prettify(item.bundleId)
        purpose.text = prettify(item.purpose)
        acknowledged.text = prettify(item.acknowledged)
        statusShort.text = prettify(item.statusShort)
        statusText.text = prettify(item.statusText)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray

        // Add separator
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height ~== 1 / UIScreen.main.scale
            line.left ~== line.superview!.left
            line.right ~== line.superview!.right
            line.top ~== line.superview!.bottom ~- (1 / UIScreen.main.scale)
        }

        selectionStyle = .none

        status = generateLabel(); statusLeft = generateLabel(text: "Status")
        type = generateLabel(); typeLeft = generateLabel(text: "Type")
        title = generateLabel(); titleLeft = generateLabel(text: "Title")
        bundle = generateLabel(); bundleLeft = generateLabel(text: "Bundle id")
        purpose = generateLabel(); purposeLeft = generateLabel(text: "Purpose")
        acknowledged = generateLabel(); acknowledgedLeft = generateLabel(text: "Acknowledged")
        statusShort = generateLabel(); statusShortLeft = generateLabel(text: "Status Short")
        statusText = generateLabel(); statusTextLeft = generateLabel(text: "Status Text")

        timestamp = UILabel()
        timestamp.theme_textColor = Color.timestampGray
        timestamp.font = .systemFont(ofSize: (11 ~~ 10))
        timestamp.makeDynamicFont()
        timestamp.numberOfLines = 1
        timestamp.textAlignment = .right

        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.8
        moreImageButton.isHidden = true

        contentView.addSubview(status); contentView.addSubview(statusLeft)
        contentView.addSubview(type); contentView.addSubview(typeLeft)
        contentView.addSubview(title); contentView.addSubview(titleLeft)
        contentView.addSubview(bundle); contentView.addSubview(bundleLeft)
        contentView.addSubview(purpose); contentView.addSubview(purposeLeft)
        contentView.addSubview(acknowledged); contentView.addSubview(acknowledgedLeft)
        contentView.addSubview(statusShort); contentView.addSubview(statusShortLeft)
        contentView.addSubview(statusText); contentView.addSubview(statusTextLeft)
        contentView.addSubview(timestamp); contentView.addSubview(moreImageButton)

        setConstraints()
    }

    private func setConstraints() {
        let space: CGFloat = (25 ~~ 15)
        let margin: CGFloat = (6 ~~ 4)

        constrain(moreImageButton) { more in
            more.centerY ~== more.superview!.centerY
            more.right ~== more.superview!.right ~- Global.Size.margin.value
            more.width ~== (22 ~~ 20)
            more.height ~== more.width
        }

        constrain(statusLeft, status, timestamp) { statusLeft, status, timestamp in
            timestamp.top ~== timestamp.superview!.top ~+ (12 ~~ 10)
            timestamp.right ~== timestamp.superview!.right ~- Global.Size.margin.value
            timestamp.height ~>= 16

            statusLeft.top ~== statusLeft.superview!.top ~+ (15 ~~ 12)
            statusLeft.left ~== statusLeft.superview!.left ~+ Global.Size.margin.value
            statusLeft.right ~== statusLeft.left ~+ (130 ~~ 95)

            status.left ~== statusLeft.right ~+ space
            status.right ~== status.superview!.right ~- Global.Size.margin.value ~- (60 ~~ 55)
            status.top ~== statusLeft.top

            constrain(typeLeft, type) { typeLeft, type in
                (typeLeft.top ~== status.bottom ~+ margin) ~ Global.notMaxPriority
                typeLeft.left ~== statusLeft.left
                typeLeft.right ~== statusLeft.right

                type.left ~== typeLeft.right ~+ space
                type.right ~== type.superview!.right ~- Global.Size.margin.value
                type.top ~== typeLeft.top

                constrain(titleLeft, title) { titleLeft, title in
                    (titleLeft.top ~== type.bottom ~+ margin) ~ Global.notMaxPriority
                    titleLeft.left ~== typeLeft.left
                    titleLeft.right ~== typeLeft.right

                    title.left ~== titleLeft.right ~+ space
                    title.right ~== title.superview!.right ~- Global.Size.margin.value
                    title.top ~== titleLeft.top

                    constrain(bundleLeft, bundle) { bundleLeft, bundle in
                        (bundleLeft.top ~== title.bottom ~+ margin) ~ Global.notMaxPriority
                        bundleLeft.left ~== titleLeft.left
                        bundleLeft.right ~== titleLeft.right

                        bundle.left ~== bundleLeft.right ~+ space
                        bundle.right ~== bundle.superview!.right ~- Global.Size.margin.value
                        bundle.top ~== bundleLeft.top

                        constrain(purposeLeft, purpose) { purposeLeft, purpose in
                            (purposeLeft.top ~== bundle.bottom ~+ margin) ~ Global.notMaxPriority
                            purposeLeft.left ~== bundleLeft.left
                            purposeLeft.right ~== bundleLeft.right

                            purpose.left ~== purposeLeft.right ~+ space
                            purpose.right ~== purpose.superview!.right ~- Global.Size.margin.value ~- (22 ~~ 20)
                            purpose.top ~== purposeLeft.top

                            constrain(acknowledgedLeft, acknowledged) { ackLeft, ack in
                                (ackLeft.top ~== purpose.bottom ~+ margin) ~ Global.notMaxPriority
                                ackLeft.left ~== purposeLeft.left
                                ackLeft.right ~== purposeLeft.right

                                ack.left ~== ackLeft.right ~+ space
                                ack.right ~== ack.superview!.right ~- Global.Size.margin.value
                                ack.top ~== ackLeft.top

                                constrain(statusShortLeft, statusShort) { statusShortLeft, statusShort in
                                    (statusShortLeft.top ~== ack.bottom ~+ margin) ~ Global.notMaxPriority
                                    statusShortLeft.left ~== ackLeft.left
                                    statusShortLeft.right ~== ackLeft.right

                                    statusShort.left ~== statusShortLeft.right ~+ space
                                    statusShort.right ~== statusShort.superview!.right ~- Global.Size.margin.value
                                    statusShort.top ~== statusShortLeft.top

                                    constrain(statusTextLeft, statusText) { statusTextLeft, statusText in
                                        (statusTextLeft.top ~== statusShort.bottom ~+ margin) ~ Global.notMaxPriority
                                        statusTextLeft.left ~== statusShortLeft.left
                                        statusTextLeft.right ~== statusShortLeft.right

                                        statusText.left ~== statusTextLeft.right ~+ space
                                        statusText.right ~== statusText.superview!.right ~- Global.Size.margin.value
                                        statusText.top ~== statusTextLeft.top
                                        statusText.bottom ~== statusText.superview!.bottom ~- 15
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension DeviceStatusCell {
    private func generateLabel(text: String = "") -> UILabel {
        let isContent: Bool = text.isEmpty
        let label = UILabel()
        label.text = text
        label.theme_textColor = isContent ? Color.darkGray : Color.title
        label.font = .systemFont(ofSize: (13.5 ~~ 12.5))
        label.makeDynamicFont()
        label.numberOfLines = isContent ? 0 : 1
        label.textAlignment = isContent ? .left : .right
        return label
    }

    private func prettify(_ text: String) -> String {
        return text.isEmpty ? "N/A" : text
    }
}
