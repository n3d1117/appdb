//
//  AdvancedOptions.swift
//  appdb
//
//  Created by ned on 13/10/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Static
import TelemetryClient

class AdvancedOptions: TableViewController {

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
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

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        if #available(iOS 13.0, *) {} else {
            if Global.isIpad {
                // Add 'Dismiss' button for iPad
                let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
                self.navigationItem.rightBarButtonItems = [dismissButton]
            }
        }

        var sections = [
            Section(rows: [
                Row(text: "Patch in-app Purchases".localized(), accessory: .switchToggle(value: Preferences.enableIapPatch) { newValue in
                    API.setConfiguration(params: [.enableIapPatch: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                Row(text: "Enable Game Trainer".localized(), accessory: .switchToggle(value: Preferences.enableTrainer) { newValue in
                    API.setConfiguration(params: [.enableTrainer: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                Row(text: "Preserve Entitlements Comments".localized(), detailText: "For Psychic Paper exploit".localized(), accessory: .switchToggle(value: Preferences.preserveEntitlements) { newValue in
                    API.setConfiguration(params: [.preserveEntitlements: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleSubtitleCell.self),
                Row(text: "Disable Revocation Checks".localized(), accessory: .switchToggle(value: Preferences.disableRevocationChecks) { newValue in
                    API.setConfiguration(params: [.disableProtectionChecks: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                Row(text: "Force Disable PRO".localized(), accessory: .switchToggle(value: Preferences.forceDisablePRO) { newValue in
                    API.setConfiguration(params: [.forceDisablePRO: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self)
            ]),
            Section(rows: [
                Row(text: "Check Revocation".localized(), selection: { [unowned self] _ in
                    self.checkProRevocationStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Validate PRO Voucher".localized(), selection: { [unowned self] _ in
                    self.validateVoucher()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Activate PRO Voucher".localized(), selection: { [unowned self] _ in
                    self.activateVoucher()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Email Link Code".localized(), selection: { [unowned self] _ in
                    self.emailLinkCode()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "List apps managed by appdb".localized(), selection: { [unowned self] _ in
                    self.listAppsManagedByAppdb()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            Section(rows: [
                Row(text: "Change bundle id before upload".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.changeBundleBeforeUpload, to: new)
                }, "value": Preferences.changeBundleBeforeUpload])
            ], footer: .title("Changing bundle identifier before uploading to MyAppStore might be useful when working with multiple versions of the same app.".localized())),
            Section(rows: [
                Row(text: "Clear developer identity".localized(), selection: { _ in }, cellClass: ClearIdentityStaticCell.self, context: ["bgColor": Color.softRed, "bgHover": Color.darkRed])
            ])
        ]
        if #available(iOS 13.0, *) {} else { sections.insert(Section(), at: 0) }
        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = sections

        TelemetryManager.send(Global.Telemetry.openedAdvancedOptions.rawValue)
    }

    @objc func dismissAnimated() { dismiss(animated: true) }
}

extension AdvancedOptions: UITableViewDelegate {

    // Call clearDeveloperIdentity() on cell tap, I do this here because I need the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ClearIdentityStaticCell {
            clearDeveloperIdentity(indexPath: indexPath)
        }
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
                if Preferences.usesCustomDeveloperIdentity {
                    Messages.shared.showSuccess(message: "Your Custom Developer Identity has not been revoked!".localized(), context: .viewController(self))
                } else {
                    Messages.shared.showSuccess(message: "Your PRO has not been revoked!".localized(), context: .viewController(self))
                }
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

    fileprivate func clearDeveloperIdentity(indexPath: IndexPath) {
        let title = "Are you sure you want to clear developer identity?".localized()
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet, adaptive: true)
        alertController.addAction(UIAlertAction(title: "Clear developer identity".localized(), style: .destructive) { _ in
            API.setConfiguration(params: [.clearDevEntity: "yes"], success: { [weak self] in
                guard let self = self else { return }
                Messages.shared.showSuccess(message: "Identity cleared!".localized(), context: .viewController(self))
            }, fail: { _ in })
        })
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if let presenter = alertController.popoverPresentationController {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = tableView
            presenter.sourceRect = tableView.rectForRow(at: indexPath)
            presenter.permittedArrowDirections = [.up, .down]
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
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
