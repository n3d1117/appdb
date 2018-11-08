//
//  EnterEmailBulletinPage.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BLTNBoard

class EnterEmailBulletinPage: BLTNPageItem {
    
    @objc public var textField: UITextField!
    
    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: "name@example.com".localized(), returnKey: .done, delegate: self)
        textField.theme_backgroundColor = Color.invertedTitle
        textField.theme_textColor = Color.title
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgba: "#AAAAAA")])
        textField.theme_keyboardAppearance = [.light, .dark]
        descriptionLabel?.theme_textColor = Color.title
        return [textField]
    }
    
    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
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

extension EnterEmailBulletinPage: UITextFieldDelegate {
    
    @objc open func isEmailValid(text: String?) -> Bool {
        // Email validation is done server side, yay
        return text != nil && !text!.isEmpty
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isEmailValid(text: textField.text) {
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "Please enter a valid email address.".localized()
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        }
        
    }
    
}

