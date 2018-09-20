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

    var status_left, type_left, title_left, bundle_left, purpose_left, acknowledged_left, statusShort_left, statusText_left: UILabel!
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        // Add separator
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height == 1/UIScreen.main.scale
            line.left == line.superview!.left
            line.right == line.superview!.right
            line.top == line.superview!.bottom - 1/UIScreen.main.scale
        }
        
        selectionStyle = .none

        // todo localize?
        status = generateLabel(); status_left = generateLabel(text: "Status")
        type = generateLabel(); type_left = generateLabel(text: "Type")
        title = generateLabel(); title_left = generateLabel(text: "Title")
        bundle = generateLabel(); bundle_left = generateLabel(text: "Bundle id")
        purpose = generateLabel(); purpose_left = generateLabel(text: "Purpose")
        acknowledged = generateLabel(); acknowledged_left = generateLabel(text: "Acknowledged")
        statusShort = generateLabel(); statusShort_left = generateLabel(text: "Status Short")
        statusText = generateLabel(); statusText_left = generateLabel(text: "Status Text")
        
        timestamp = UILabel()
        timestamp.theme_textColor = Color.timestampGray
        timestamp.font = .systemFont(ofSize: (11~~10))
        timestamp.makeDynamicFont()
        timestamp.numberOfLines = 1
        timestamp.textAlignment = .right
        
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.8
        moreImageButton.isHidden = true
        
        contentView.addSubview(status); contentView.addSubview(status_left)
        contentView.addSubview(type); contentView.addSubview(type_left)
        contentView.addSubview(title); contentView.addSubview(title_left)
        contentView.addSubview(bundle); contentView.addSubview(bundle_left)
        contentView.addSubview(purpose); contentView.addSubview(purpose_left)
        contentView.addSubview(acknowledged); contentView.addSubview(acknowledged_left)
        contentView.addSubview(statusShort); contentView.addSubview(statusShort_left)
        contentView.addSubview(statusText); contentView.addSubview(statusText_left)
        contentView.addSubview(timestamp); contentView.addSubview(moreImageButton)
        
        setConstraints()
        
    }
    
    fileprivate func setConstraints() {
        
        let space: CGFloat = (25~~15)
        let margin: CGFloat = (6~~4)
        
        constrain(moreImageButton) { m in
            m.centerY == m.superview!.centerY
            m.right == m.superview!.right - Global.size.margin.value
            m.width == (22~~20)
            m.height == m.width
        }
        
        constrain(status_left, status, timestamp) { sl, s, ts in
            
            ts.top == ts.superview!.top + (12~~10)
            ts.right == ts.superview!.right - Global.size.margin.value
            ts.height >= 16
            
            sl.top == sl.superview!.top + (15~~12)
            sl.left == sl.superview!.left + Global.size.margin.value
            sl.right == sl.left + (130~~95)
            
            s.left == sl.right + space
            s.right == s.superview!.right - Global.size.margin.value
            s.top == sl.top
            
            constrain(type_left, type) { tl, t in
                tl.top == s.bottom + margin ~ Global.notMaxPriority
                tl.left == sl.left
                tl.right == sl.right
                
                t.left == tl.right + space
                t.right == t.superview!.right - Global.size.margin.value
                t.top == tl.top
                
                constrain(title_left, title) { til, ti in
                    til.top == t.bottom + margin ~ Global.notMaxPriority
                    til.left == tl.left
                    til.right == tl.right
                    
                    ti.left == til.right + space
                    ti.right == ti.superview!.right - Global.size.margin.value
                    ti.top == til.top
                    
                    constrain(bundle_left, bundle) { bl, b in
                        bl.top == ti.bottom + margin ~ Global.notMaxPriority
                        bl.left == til.left
                        bl.right == til.right
                        
                        b.left == bl.right + space
                        b.right == b.superview!.right - Global.size.margin.value
                        b.top == bl.top
                        
                        constrain(purpose_left, purpose) { pl, p in
                            pl.top == b.bottom + margin ~ Global.notMaxPriority
                            pl.left == bl.left
                            pl.right == bl.right
                            
                            p.left == pl.right + space
                            p.right == p.superview!.right - Global.size.margin.value - (22~~20)
                            p.top == pl.top
                            
                            constrain(acknowledged_left, acknowledged) { al, a in
                                al.top == p.bottom + margin ~ Global.notMaxPriority
                                al.left == pl.left
                                al.right == pl.right
                                
                                a.left == al.right + space
                                a.right == a.superview!.right - Global.size.margin.value
                                a.top == al.top
                            
                                constrain(statusShort_left, statusShort) { ssl, ss in
                                    ssl.top == a.bottom + margin ~ Global.notMaxPriority
                                    ssl.left == al.left
                                    ssl.right == al.right
                                    
                                    ss.left == ssl.right + space
                                    ss.right == ss.superview!.right - Global.size.margin.value
                                    ss.top == ssl.top
                                    
                                    constrain(statusText_left, statusText) { sl, s in
                                        sl.top == ss.bottom + margin ~ Global.notMaxPriority
                                        sl.left == ssl.left
                                        sl.right == ssl.right
                                        
                                        s.left == sl.right + space
                                        s.right == s.superview!.right - Global.size.margin.value
                                        s.top == sl.top
                                        s.bottom == s.superview!.bottom - 15
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
    fileprivate func generateLabel(text: String = "") -> UILabel {
        let isContent: Bool = text.isEmpty
        let label = UILabel()
        label.text = text
        label.theme_textColor = isContent ? Color.darkGray : Color.title
        label.font = .systemFont(ofSize: (13.5~~12.5))
        label.makeDynamicFont()
        label.numberOfLines = isContent ? 0 : 1
        label.textAlignment = isContent ? .left : .right
        return label
    }
    
    fileprivate func prettify(_ text: String) -> String {
        return text.isEmpty ? "N/A" : text
    }
}
