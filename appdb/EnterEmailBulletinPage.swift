//
//  EnterEmailBulletinPage.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BulletinBoard

/**
 * An item that displays a text field.
 *
 * This item demonstrates how to create a bulletin item with a text field and how it will behave
 * when the keyboard is visible.
 */

class EnterEmailBulletinPage: PageBulletinItem {
    
    @objc public var textField: UITextField!
    
    @objc public var textInputHandler: ((ActionBulletinItem, String?) -> Void)? = nil
    
    override func viewsUnderDescription(_ interfaceBuilder: BulletinInterfaceBuilder) -> [UIView]? {
        textField = interfaceBuilder.makeTextField(placeholder: "name@example.com", returnKey: .done, delegate: self)
        return [textField]
    }
    
    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        if textFieldShouldReturn(self.textField) {
            textInputHandler?(self, textField.text)
            super.actionButtonTapped(sender: sender)
        }
        
    }
    
}

// MARK: - UITextFieldDelegate

extension EnterEmailBulletinPage: UITextFieldDelegate {
    
    @objc open func isEmailValid(text: String?) -> Bool {
        // Email validation is done server side, yay
        return text != nil && !text!.isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isEmailValid(text: textField.text) {
            textField.resignFirstResponder()
            return true
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "Please enter a valid email address.".localized()
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.2)
            return false
        }
        
    }
    
}

