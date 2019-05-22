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
        
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        detailTextLabel?.makeDynamicFont()
        detailTextLabel?.theme_textColor = Color.darkGray
    }
    
    func configure(row: Row) {
        textLabel?.theme_textColor = Color.title
        detailTextLabel?.theme_textColor = Color.darkGray
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
        
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        detailTextLabel?.makeDynamicFont()
        detailTextLabel?.theme_textColor = Color.darkGray
    }
    
    func configure(row: Row) {
        
        accessoryType = row.accessory.type
        
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text
        
        detailTextLabel?.text = row.detailText
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
        
        textLabel?.font = .boldSystemFont(ofSize: (15.5~~14.5))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = ["#F8F8F8", "#F8F8F8"]
        textLabel?.textAlignment = .center
    }
    
    func configure(row: Row) {
        textLabel?.theme_textColor = ["#F8F8F8", "#F8F8F8"]
        textLabel?.textAlignment = .center
        
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
    
    fileprivate var dummy: UIView!
    fileprivate var activeLabel: UILabel!
    fileprivate var expirationLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        activeLabel = UILabel()
        activeLabel.font = .systemFont(ofSize: (15~~14))
        activeLabel.makeDynamicFont()
        activeLabel.textAlignment = .right
        
        expirationLabel = UILabel()
        expirationLabel.theme_textColor = Color.darkGray
        expirationLabel.font = .systemFont(ofSize: (13~~12))
        expirationLabel.makeDynamicFont()
        expirationLabel.textAlignment = .right
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        dummy = UIView()
        dummy.isHidden = true
        
        contentView.addSubview(activeLabel)
        contentView.addSubview(expirationLabel)
        contentView.addSubview(dummy)
    }
    
    func configure(row: Row) {
        
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text
        
        guard let pro = row.context?["active"] as? Bool else { return }
        guard let proExpirationDate = (row.context?["expire"] as? String)?.rfc2822decodedShort else { return }
        guard let proDisabled = row.context?["disabled"] as? Bool else { return }
        guard let proRevoked = row.context?["revoked"] as? Bool else { return }
        guard let proRevokedOn = (row.context?["revokedOn"] as? String)?.rfc2822decodedShort else { return }
        
        if proRevoked {
            activeLabel.theme_textColor = Color.softRed
            expirationLabel.text = "Revoked on %@".localizedFormat(proRevokedOn)
            activeLabel.text = "Revoked".localized()
            selectionStyle = .none
        } else if proDisabled {
            activeLabel.theme_textColor = Color.softRed
            activeLabel.text = "Disabled".localized()
            selectionStyle = .none
        } else {
            if pro {
                activeLabel.theme_textColor = Color.softGreen
                expirationLabel.text = "Expires on %@".localizedFormat(proExpirationDate)
                activeLabel.text = "Active".localized()
                selectionStyle = .none
            } else {
                activeLabel.theme_textColor = Color.softRed
                expirationLabel.text = "Tap to know more".localized()
                activeLabel.text = "Inactive".localized()
                accessoryType = .disclosureIndicator
                let bgColorView = UIView()
                bgColorView.theme_backgroundColor = Color.cellSelectionColor
                selectedBackgroundView = bgColorView
            }
        }
        
        if proDisabled {
            expirationLabel.isHidden = true
            
            constrain(activeLabel) { active in
                active.centerY ~== active.superview!.centerY
                active.trailing ~== active.superview!.trailingMargin
            }
            
        } else {
            
            constrain(activeLabel, expirationLabel, dummy) { active, expiration, d in
                
                d.height ~== 1
                d.centerY ~== d.superview!.centerY
                
                active.bottom ~== d.top ~+ 1
                active.trailing ~== active.superview!.trailingMargin
                
                expiration.top ~== d.bottom ~+ 2
                expiration.trailing ~== active.trailing
            }
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
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text

        if let vc = row.context?["valueChange"] as? ValueChange {
            self.valueChange = vc
        }
        guard let pref = (try? Realm())?.objects(Preferences.self).first else { return }
        guard let keyPath = row.context?["keyPath"] as? WritableKeyPath<Preferences, Bool> else { return }
        toggle.isOn = pref[keyPath: keyPath]
    }
}

final class StaticTextFieldCell: SimpleStaticCell, UITextFieldDelegate {

    var textfieldDidEndEditing: ((String) -> ())?
    
    var textField: UITextField!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textAlignment = .right
        textField.theme_textColor = Color.title
        textField.theme_keyboardAppearance = [.light, .dark]
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        contentView.addSubview(textField)
        
        constrain(textField) { textField in
            textField.right ~== textField.superview!.layoutMarginsGuide.right ~- 3
            textField.top ~== textField.superview!.top
            textField.bottom ~== textField.superview!.bottom
            textField.left ~== textField.superview!.centerX
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(row: Row) {
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text
        if let placeholder = row.context?["placeholder"] as? String {
            textField.placeholder = placeholder
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [.foregroundColor: UIColor(rgba: "#8D8D8D"), .font: UIFont.systemFont(ofSize: (15.5~~14.5))])
        }
        if let callback = row.context?["callback"] as? (String) -> () {
            self.textfieldDidEndEditing = callback
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        textfieldDidEndEditing?(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
