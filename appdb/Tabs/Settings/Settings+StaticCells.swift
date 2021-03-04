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

// A simple cell for the 'Static' framework that adapts to theme changes
// and has has dynamic text font size. Used for Settings cells.

class SimpleStaticCell: UITableViewCell, Cell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

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
        setBackgroundColor(Color.veryVeryLightGray)

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

        accessoryType = row.accessory.type
        accessoryView = row.accessory.view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Simple cell that shows a button in center

class SimpleStaticButtonCell: UITableViewCell, Cell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        textLabel?.font = .boldSystemFont(ofSize: (15.5 ~~ 14.5))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.dirtyWhite
        textLabel?.textAlignment = .center
    }

    func configure(row: Row) {
        textLabel?.theme_textColor = Color.dirtyWhite
        textLabel?.textAlignment = .center

        textLabel?.text = row.text?.uppercased()
        if let color = row.context?["bgColor"] as? ThemeColorPicker {
            theme_backgroundColor = color
            setBackgroundColor(color)
        }

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
    private var dummy: UIView!
    private var activeLabel: UILabel!
    private var expirationLabel: UILabel!

    private var constraintGroup = ConstraintGroup()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true

        activeLabel = UILabel()
        activeLabel.font = .systemFont(ofSize: (15 ~~ 14))
        activeLabel.makeDynamicFont()
        activeLabel.textAlignment = .right

        expirationLabel = UILabel()
        expirationLabel.theme_textColor = Color.darkGray
        expirationLabel.font = .systemFont(ofSize: (13 ~~ 12))
        expirationLabel.makeDynamicFont()
        expirationLabel.textAlignment = .right

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

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
        guard let proRevoked = row.context?["revoked"] as? Bool else { return }
        guard let proRevokedOn = (row.context?["revokedOn"] as? String)?.revokedDateDecoded else { return }
        guard let usesCustomDeveloperIdentity = row.context?["usesCustomDevIdentity"] as? Bool else { return }

        if usesCustomDeveloperIdentity {
            activeLabel.theme_textColor = Color.softGreen
            activeLabel.text = "Custom Developer Identity".localized()
            selectionStyle = .none
            accessoryType = .none
            if proRevoked {
                expirationLabel.text = "Revoked on %@".localizedFormat(proRevokedOn)
            }
        } else if proRevoked {
            activeLabel.theme_textColor = Color.softRed
            expirationLabel.text = "Revoked on %@".localizedFormat(proRevokedOn)
            activeLabel.text = "Revoked".localized()
            accessoryType = .disclosureIndicator
            let bgColorView = UIView()
            bgColorView.theme_backgroundColor = Color.cellSelectionColor
            selectedBackgroundView = bgColorView
        } else {
            if pro {
                activeLabel.theme_textColor = Color.softGreen
                expirationLabel.text = "Expires on %@".localizedFormat(proExpirationDate)
                activeLabel.text = "Active".localized()
                selectionStyle = .none
                accessoryType = .none
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

        expirationLabel.isHidden = usesCustomDeveloperIdentity && !proRevoked

        if usesCustomDeveloperIdentity && !proRevoked {
            constrain(activeLabel, replace: constraintGroup) { active in
                active.centerY ~== active.superview!.centerY
                active.trailing ~== active.superview!.trailingMargin
            }
        } else {
            constrain(activeLabel, expirationLabel, dummy, replace: constraintGroup) { active, expiration, dummy in
                dummy.height ~== 1
                dummy.centerY ~== dummy.superview!.centerY

                active.bottom ~== dummy.top ~+ 1
                active.trailing ~== active.superview!.trailingMargin

                expiration.top ~== dummy.bottom ~+ 2
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
        guard let value = row.context?["value"] as? Bool else { return }
        toggle.isOn = value
    }
}

class StaticTextFieldCell: SimpleStaticCell, UITextFieldDelegate {
    var textfieldDidEndEditing: ((String) -> Void)?

    var textField: UITextField!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textAlignment = .right
        textField.theme_textColor = Color.title
        textField.theme_keyboardAppearance = [.light, .dark, .dark]
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        contentView.addSubview(textField)

        constrain(textField) { textField in
            textField.right ~== textField.superview!.layoutMarginsGuide.right// ~- 3
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
        if let initialText = row.context?["initialText"] as? String {
            textField.text = initialText
        }
        if let placeholder = row.context?["placeholder"] as? String {
            textField.placeholder = placeholder
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [.foregroundColor: UIColor(rgba: "#8D8D8D"), .font: UIFont.systemFont(ofSize: textLabel?.font?.pointSize ?? (17 ~~ 16))])
        }
        if let callback = row.context?["callback"] as? (String) -> Void {
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

final class StaticSubtitleTextFieldCell: StaticTextFieldCell {

    private var title: UILabel!
    private var subtitle: UILabel!

    private var dummy: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title = UILabel()
        title.font = .systemFont(ofSize: (17 ~~ 16))
        title.makeDynamicFont()
        title.textAlignment = .left

        subtitle = UILabel()
        subtitle.font = .systemFont(ofSize: (12 ~~ 11))
        subtitle.makeDynamicFont()
        subtitle.textAlignment = .left

        dummy = UIView()
        dummy.isHidden = true

        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(dummy)

        constrain(title, subtitle, dummy) { title, subtitle, dummy in

            dummy.height ~== 1
            dummy.centerY ~== dummy.superview!.centerY

            title.leading == title.superview!.leadingMargin
            subtitle.leading == title.leading

            title.bottom ~== dummy.top ~+ 4
            subtitle.top ~== dummy.bottom ~+ 3
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: Row) {
        super.configure(row: row)

        selectionStyle = .none

        title.text = row.context?["title"] as? String
        title.theme_textColor = Color.title

        subtitle.text = row.context?["subtitle"] as? String
        subtitle.theme_textColor = Color.darkGray
    }
}

final class ContactDevStaticCell: SimpleStaticCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: Row) {
        super.configure(row: row)
    }
}

final class ClearIdentityStaticCell: SimpleStaticButtonCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: Row) {
        super.configure(row: row)
    }
}
