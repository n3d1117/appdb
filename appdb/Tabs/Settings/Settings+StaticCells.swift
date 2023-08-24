//
//  Settings+StaticCells.swift
//  appdb
//
//  Created by ned on 16/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

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

    func configure(row: StaticRow) {
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

    func configure(row: StaticRow) {
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

    func configure(row: StaticRow) {
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

// Signing Certificate cell

final class SimpleStaticSigningCertificateCell: UITableViewCell, Cell {
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
        activeLabel.textAlignment = Global.isRtl ? .left : .right

        expirationLabel = UILabel()
        expirationLabel.theme_textColor = Color.darkGray
        expirationLabel.font = .systemFont(ofSize: (13 ~~ 12))
        expirationLabel.makeDynamicFont()
        expirationLabel.textAlignment = Global.isRtl ? .left : .right

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

    func configure(row: StaticRow) {
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text

        guard let signingWith = row.context?["signingWith"] as? String else { return }
        guard let enterpriseCertId = row.context?["enterpriseCertId"] as? String else { return }
        guard let freeSignsLeft = row.context?["freeSignsLeft"] as? String else { return }
        guard let freeSignsLeftNumber = Int(freeSignsLeft) else { return }
        guard let freeSignsResetAt = row.context?["freeSignsResetAt"] as? String else { return }
        guard let plus = row.context?["isPlus"] as? Bool else { return }
        guard let plusUntil = (row.context?["plusUntil"] as? String)?.unixToString else { return }
        guard let plusAccountStatus = row.context?["plusAccountStatus"] as? String else { return }
        guard let revoked = row.context?["revoked"] as? Bool else { return }
        guard let revokedOn = (row.context?["revokedOn"] as? String)?.revokedDateDecoded else { return }
        guard let usesCustomDeveloperIdentity = row.context?["usesCustomDevIdentity"] as? Bool else { return }

        if usesCustomDeveloperIdentity {
            activeLabel.theme_textColor = Color.softGreen
            activeLabel.text = "Custom Developer Identity".localized()
            if revoked {
                expirationLabel.text = "Revoked on %@".localizedFormat(revokedOn)
            }
        } else if !plusAccountStatus.isEmpty {
            activeLabel.theme_textColor = Color.softGreen
            activeLabel.text = "Custom Developer Account".localized()
        } else if revoked {
            activeLabel.theme_textColor = Color.softRed
            expirationLabel.text = "Revoked on %@".localizedFormat(revokedOn)
            activeLabel.text = "Revoked".localized()
        } else if plus {
            activeLabel.theme_textColor = Color.softGreen
            expirationLabel.text = "Expires on %@".localizedFormat(plusUntil)
            activeLabel.text = "Unlimited signs left".localized()
        } else {
            activeLabel.theme_textColor = freeSignsLeftNumber > 0 ? Color.softGreen : Color.softRed
            expirationLabel.text = signingWith
            activeLabel.text = "%@ signs left until %@".localizedFormat(freeSignsLeft, freeSignsResetAt.unixToString)
        }

        selectionStyle = .default
        accessoryType = .disclosureIndicator

        expirationLabel.isHidden = usesCustomDeveloperIdentity && !revoked

        if usesCustomDeveloperIdentity && !revoked {
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

// PLUS status cell

final class SimpleStaticPLUSStatusCell: UITableViewCell, Cell {
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
        activeLabel.textAlignment = Global.isRtl ? .left : .right

        expirationLabel = UILabel()
        expirationLabel.theme_textColor = Color.darkGray
        expirationLabel.font = .systemFont(ofSize: (13 ~~ 12))
        expirationLabel.makeDynamicFont()
        expirationLabel.textAlignment = Global.isRtl ? .left : .right

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

    func configure(row: StaticRow) {
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text

        guard let isPlus = row.context?["active"] as? Bool else { return }
        guard let plusExpirationDate = (row.context?["expire"] as? String)?.unixToString else { return }

        if isPlus {
            activeLabel.theme_textColor = Color.softGreen
            expirationLabel.text = "Expires on %@".localizedFormat(plusExpirationDate)
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

       constrain(activeLabel, expirationLabel, dummy, replace: constraintGroup) { active, expiration, dummy in
            dummy.height ~== 1
            dummy.centerY ~== dummy.superview!.centerY

            active.bottom ~== dummy.top ~+ 1
            active.trailing ~== active.superview!.trailingMargin

            expiration.top ~== dummy.bottom ~+ 2
            expiration.trailing ~== active.trailing
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Installation Options Dylibs cell

final class SimpleStaticDylibsSelectionCell: UITableViewCell, Cell {
    private var titleLabel: UILabel!
    private var selectedDylibsLabel: UILabel!

    private var constraintGroup = ConstraintGroup()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true

        selectedDylibsLabel = UILabel()
        selectedDylibsLabel.theme_textColor = Color.darkGray
        selectedDylibsLabel.font = .systemFont(ofSize: (13 ~~ 12))
        selectedDylibsLabel.makeDynamicFont()
        selectedDylibsLabel.numberOfLines = 10
        selectedDylibsLabel.textAlignment = Global.isRtl ? .left : .right

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title

        contentView.addSubview(selectedDylibsLabel)
    }

    func configure(row: StaticRow) {
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text

        guard let selectedDylibs = row.context?["selectedDylibs"] as? [String] else { return }

        if !selectedDylibs.isEmpty {
            textLabel?.text = "Selected %i dylibs".localizedFormat(selectedDylibs.count)
        }

        selectedDylibsLabel.theme_textColor = Color.darkGray
        accessoryType = .disclosureIndicator
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
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

    override func configure(row: StaticRow) {
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
    var characterLimit: Int?
    var forceLowercase = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.textAlignment = Global.isRtl ? .left : .right
        textField.theme_textColor = Color.title
        textField.theme_keyboardAppearance = [.light, .dark, .dark]
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        contentView.addSubview(textField)

        constrain(textField) { textField in
            textField.trailing ~== textField.superview!.layoutMarginsGuide.trailing// ~- 3
            textField.top ~== textField.superview!.top
            textField.bottom ~== textField.superview!.bottom
            textField.leading ~== textField.superview!.centerX
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: StaticRow) {
        textLabel?.theme_textColor = Color.title
        textLabel?.text = row.text
        if let initialText = row.context?["initialText"] as? String {
            textField.text = initialText
        }
        if let placeholder = row.context?["placeholder"] as? String {
            textField.placeholder = placeholder
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(rgba: "#8D8D8D"), .font: UIFont.systemFont(ofSize: textLabel?.font?.pointSize ?? (17 ~~ 16))])
        }
        if let callback = row.context?["callback"] as? (String) -> Void {
            self.textfieldDidEndEditing = callback
        }
        if let limit = row.context?["characterLimit"] as? Int {
            characterLimit = limit
        }
        if let lower = row.context?["forceLowercase"] as? Bool {
            forceLowercase = lower
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        var adjustedText = text

        if forceLowercase {
            adjustedText = adjustedText.lowercased()
        }
        if let limit = characterLimit {
            adjustedText = String(adjustedText.prefix(limit))
        }

        textField.text = adjustedText
        textfieldDidEndEditing?(adjustedText)
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
        title.textAlignment = .natural

        subtitle = UILabel()
        subtitle.font = .systemFont(ofSize: (12 ~~ 11))
        subtitle.makeDynamicFont()
        subtitle.textAlignment = .natural

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

    override func configure(row: StaticRow) {
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

    override func configure(row: StaticRow) {
        super.configure(row: row)
    }
}

final class ClearCacheStaticCell: SimpleStaticCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(row: StaticRow) {
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

    override func configure(row: StaticRow) {
        super.configure(row: row)
    }
}
