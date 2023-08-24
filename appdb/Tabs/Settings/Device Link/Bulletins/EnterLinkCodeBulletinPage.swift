//
//  EnterLinkCodeBulletinPage.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BLTNBoard
import SafariServices

class EnterLinkCodeBulletinPage: BLTNPageItem {

    @objc public var textField: UITextField!
    private var linkButton: UIButton!

    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)?

    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
        linkButton?.removeTarget(self, action: nil, for: .touchUpInside)
    }

    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        let button = UIButton(type: .system)
        button.setTitle("\(Global.mainSite)link", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.theme_setTitleColor(Color.mainTint, forState: .normal)
        button.addTarget(self, action: #selector(self.linkButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .center
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 15)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        self.linkButton = button

        textField = interfaceBuilder.makeTextField(placeholder: "Enter link code here".localized(), returnKey: .done, delegate: self)
        textField.theme_backgroundColor = Color.invertedTitle
        textField.theme_textColor = Color.title
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [.foregroundColor: UIColor(rgba: "#AAAAAA")])
        textField.theme_keyboardAppearance = [.light, .dark, .dark]

        descriptionLabel?.theme_textColor = Color.title

        return [linkButton, textField]
    }

    @objc private func linkButtonTapped(sender: UIButton) {
        guard let url = sender.titleLabel?.text else { return }
        NotificationCenter.default.post(name: .OpenSafari, object: self, userInfo: ["URLString": "\(url)?ref=\(Global.refCode)"])
    }

    override func actionButtonTapped(sender: UIButton) {
        textInputHandler?(self, textField.text)
        super.actionButtonTapped(sender: sender)
    }

    override func alternativeButtonTapped(sender: UIButton) {
        self.manager?.popItem()
    }
}

// MARK: - UITextFieldDelegate

extension EnterLinkCodeBulletinPage: UITextFieldDelegate {
    @objc open func isInputValid(text: String?) -> Bool {
        text != nil && !text!.isEmpty
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if isInputValid(text: textField.text) {
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "Link code cannot be empty.".localized()
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        }
    }
}
