//
//  AdvancedOptions.swift
//  appdb
//
//  Created by ned on 13/10/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Static

class AdvancedOptions: TableViewController {

    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Advanced Options".localized()

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.cellLayoutMarginsFollowReadableWidth = true

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView.rowHeight = 55

        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem

        let sections = [
            Section(),
            Section(rows: [
                Row(text: "Check PRO Revocation".localized(), selection: { [unowned self] _ in
                    self.checkProRevocationStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Validate PRO Voucher".localized(), selection: { [unowned self] _ in
                    self.validateVoucher()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Activate PRO Voucher".localized(), selection: { [unowned self] _ in
                    self.activateVoucher()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            Section(rows: [
                Row(text: "Email Link Code".localized(), selection: { [unowned self] _ in
                    self.emailLinkCode()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            Section(rows: [
                Row(text: "List apps managed by appdb".localized(), selection: { [unowned self] _ in
                    self.listAppsManagedByAppdb()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            Section(rows: [
                Row(text: "Change bundle id before upload".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.changeBundleBeforeUpload, to: new)
                }, "value": Preferences.changeBundleBeforeUpload])
            ], footer: .title("Changing bundle identifier before uploading to MyAppStore might be useful when working with multiple versions of the same app.".localized()))
        ]
        dataSource.sections = sections
    }
}

extension AdvancedOptions {
    fileprivate func checkProRevocationStatus() {
        API.checkRevocation(completion: { isRevoked, revokedOn in
            if isRevoked {
                var message: String = "Revoked on %@".localizedFormat(revokedOn.revokedDateDecoded)
                if Preferences.usesCustomDeveloperIdentity {
                    message = "Custom Developer Identity".localized() + "\n" + message
                }
                Messages.shared.showError(message: message, duration: 4, context: .viewController(self))
            } else {
                Messages.shared.showSuccess(message: "Your PRO has not been revoked!".localized(), context: .viewController(self))
            }
        }, fail: { error in
            Messages.shared.showError(message: error.prettified, context: .viewController(self))
        })
    }

    fileprivate func activateVoucher() {
        let title = "Enter Voucher".localized()
        let message = "Paste here the PRO voucher obtained by a reseller:".localized()
        let placeholder = "x:xxxx:xxxx"
        presentVoucherTextInputAlertController(title: title, message: message, placeholder: placeholder, actionTitle: "Activate".localized(), action: { voucher in
            API.activateVoucher(voucher: voucher, success: {
                API.getConfiguration(success: { [weak self] in
                    guard let self = self else { return }
                    Messages.shared.showSuccess(message: "Your PRO has been activated successfully!".localized(), context: .viewController(self))
                    NotificationCenter.default.post(name: .RefreshSettings, object: self)
                }, fail: { _ in })
            }, fail: { error in
                Messages.shared.showError(message: error.prettified, context: .viewController(self))
            })
        })
    }

    fileprivate func validateVoucher() {
        let title = "Enter Voucher".localized()
        let message = "Paste here the PRO voucher obtained by a reseller:".localized()
        let placeholder = "x:xxxx:xxxx"
        presentVoucherTextInputAlertController(title: title, message: message, placeholder: placeholder, actionTitle: "Validate".localized(), action: { voucher in
            API.validateVoucher(voucher: voucher, success: {
                Messages.shared.showSuccess(message: "Your PRO voucher is valid and can be activated!".localized(), context: .viewController(self))
            }, fail: { error in
                Messages.shared.showError(message: error.prettified, context: .viewController(self))
            })
        })
    }

    fileprivate func emailLinkCode() {
        let title = "Enter Email".localized()
        let message = "Enter below the email address where the link code will be sent:".localized()
        let placeholder = "name@example.com".localized()
        presentVoucherTextInputAlertController(title: title, message: message, placeholder: placeholder, actionTitle: "Send".localized(), action: { email in
            API.emailLinkCode(email: email, success: {
                Messages.shared.showSuccess(message: "Email was sent successfully!".localized(), context: .viewController(self))
            }, fail: { error in
                Messages.shared.showError(message: error.prettified, context: .viewController(self))
            })
        })
    }

    fileprivate func listAppsManagedByAppdb() {
        let listAppsManagedByAppdbViewController = ListAppsManagedByAppdb()
        self.navigationController?.pushViewController(listAppsManagedByAppdbViewController, animated: true)
    }
}

extension AdvancedOptions {
    func presentVoucherTextInputAlertController(title: String, message: String, placeholder: String, actionTitle: String, action: @escaping (_ text: String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, adaptive: true)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.voucherTextChanged), for: .editingChanged)
            textField.placeholder = placeholder
            textField.keyboardType = .URL
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let load = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            guard let text = alert.textFields?[0].text else { return }
            action(text)
        })

        alert.addAction(load)
        load.isEnabled = false

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    @objc func voucherTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            if let text = sender.text, !text.isEmpty {
                (alert.actions[1] as UIAlertAction).isEnabled = true
            } else {
                (alert.actions[1] as UIAlertAction).isEnabled = false
            }
        }
    }
}
