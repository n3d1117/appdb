//
//  Settings+StaticCells.swift
//  appdb
//
//  Created by ned on 16/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Static
import SwiftTheme
import Cartography
import RealmSwift

// A simple cell for the 'Static' framework that adapts to theme changes
// and has has dynamic text font size. Used for Settings cells.

class SimpleStaticCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
    }
    
    func configure(row: Row) {
        textLabel?.text = row.text
        detailTextLabel?.text = row.detailText
        imageView?.image = row.image
        accessoryType = row.accessory.type
        accessoryView = row.accessory.view
        if let disableSelection = row.context?["disableSelection"] as? Bool, disableSelection {
            selectionStyle = .none
        } else {
            let bgColorView = UIView()
            bgColorView.theme_backgroundColor = Color.cellSelectionColor
            selectedBackgroundView = bgColorView
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Simple Subtitle cell

final class SimpleSubtitleCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        detailTextLabel?.makeDynamicFont()
        detailTextLabel?.theme_textColor = Color.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Simple cell that shows a button in center

final class SimpleStaticButtonCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = .boldSystemFont(ofSize: (16~~15))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = ["#F8F8F8", "#F8F8F8"]
        textLabel?.textAlignment = .center
    }
    
    func configure(row: Row) {
        textLabel?.text = row.text?.uppercased()
        theme_backgroundColor = row.context?["bgColor"] as? ThemeColorPicker
        contentView.theme_backgroundColor = row.context?["bgColor"] as? ThemeColorPicker
        
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = row.context?["bgHover"] as? ThemeColorPicker
        selectedBackgroundView = bgColorView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// PRO status cell

final class SimpleStaticPROStatusCell: UITableViewCell, Cell {
    
    private lazy var activeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: (15~~14))
        label.makeDynamicFont()
        label.textAlignment = .right
        return label
    }()
    
    private lazy var expirationLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.darkGray
        label.font = .systemFont(ofSize: (13~~12))
        label.makeDynamicFont()
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        contentView.addSubview(activeLabel)
    }
    
    func configure(row: Row) {
        
        textLabel?.text = row.text
        
        guard let pro = row.context?["active"] as? Bool else { return }
        guard let proExpirationDate = (row.context?["expire"] as? String)?.rfc2822decodedShort else { return }
        guard let proDisabled = row.context?["disabled"] as? Bool else { return }
        guard let proRevoked = row.context?["revoked"] as? Bool else { return }
        guard let proRevokedOn = (row.context?["revokedOn"] as? String)?.rfc2822decodedShort else { return }
        
        if (pro && !proExpirationDate.isEmpty) || (proRevoked && !proRevokedOn.isEmpty) {
            activeLabel.theme_textColor = Color.softGreen
            contentView.addSubview(expirationLabel)
            constrain(activeLabel, expirationLabel) { active, expiration in
                active.centerY == active.superview!.centerY - (8~~6)
                active.trailing == active.superview!.trailingMargin
                
                expiration.top == active.bottom
                expiration.trailing == active.trailing
            }
            if proRevoked {
                expirationLabel.text = "Revoked on %@".localizedFormat(proRevokedOn)
            } else {
                expirationLabel.text = "Expires on %@".localizedFormat(proExpirationDate)
            }
        } else {
            activeLabel.theme_textColor = Color.softRed
            constrain(activeLabel) { active in
                active.centerY == active.superview!.centerY
                active.trailing == active.superview!.trailingMargin
            }
        }
        
        if proDisabled {
            activeLabel.text = "Disabled".localized()
        } else if proRevoked {
            activeLabel.text = "Revoked".localized()
        } else {
            activeLabel.text = pro ? "Active".localized() : "Inactive".localized()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// No generic needed: i'm sure it will always be 'Preferences'
// Also don't need the cell to update the property, i'd rather do that in 'valueChange' callback
// https://github.com/venmo/Static/issues/135

final class SwitchCell: SimpleStaticCell {
    
    var valueChange: ValueChange?
    private let toggle = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = toggle
        toggle.addTarget(self, action: #selector(change), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func change() {
        valueChange?(toggle.isOn)
    }
    
    override func configure(row: Row) {
        textLabel?.text = row.text

        if let vc = row.context?["valueChange"] as? ValueChange {
            self.valueChange = vc
        }
        guard let pref = (try? Realm())?.objects(Preferences.self).first else { return }
        guard let keyPath = row.context?["keyPath"] as? WritableKeyPath<Preferences, Bool> else { return }
        toggle.isOn = pref[keyPath: keyPath]
    }
}
