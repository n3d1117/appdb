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

    fileprivate func getSections() -> [Static.Section] {
        var sections = [Section(rows: [
            Row(text: "Signing Type".localized(),
                detailText: Preferences.signingIdentityType.capitalizingFirstLetter(), selection: { [unowned self] _ in
                    self.push(SigningTypeChooser())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
            Row(text: "Disable Revocation Checks".localized(), accessory: .switchToggle(value: Preferences.disableRevocationChecks) { newValue in
                API.setConfiguration(params: [.disableProtectionChecks: newValue ? "yes" : "no"], success: {}, fail: { _ in })
            }, cellClass: SimpleStaticCell.self),
            Row(text: "Force Disable PRO".localized(), accessory: .switchToggle(value: Preferences.forceDisablePRO) { newValue in
                API.setConfiguration(params: [.forceDisablePRO: newValue ? "yes" : "no"], success: {}, fail: { _ in })
            }, cellClass: SimpleStaticCell.self),
            Row(text: "Opt-out from emails".localized(), accessory: .switchToggle(value: Preferences.optedOutFromEmails) { newValue in
                API.setConfiguration(params: [.optedOutFromEmails: newValue ? "yes" : "no"], success: {}, fail: { _ in })
            }, cellClass: SimpleStaticCell.self)
        ]),
        Section(rows: [
            Row(text: "Check Revocation".localized(), selection: { [unowned self] _ in
                            self.checkRevocationStatus()
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
        return sections
    }

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

        dataSource = DataSource(tableViewDelegate: self)
        dataSource.sections = getSections()

        TelemetryManager.send(Global.Telemetry.openedAdvancedOptions.rawValue)
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    func push(_ viewController: UIViewController) {

        // Set delegates for view controllers that require one
        if let typeChooser = viewController as? SigningTypeChooser {
            typeChooser.changedTypeDelegate = self
        }

        // Show view controller
        if Global.isIpad {
            if (viewController is SigningTypeChooser), #available(iOS 13.0, *) {
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let nav = DismissableModalNavController(rootViewController: viewController)
                nav.modalPresentationStyle = .formSheet
                self.navigationController?.present(nav, animated: true)
            }
        } else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
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
    
    fileprivate func checkRevocationStatus() {
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
    
    fileprivate func emailLinkCode() {
        let title = "Enter Email".localized()
        let message = "Enter below the email address where the link code will be sent:".localized()
        let placeholder = "name@example.com".localized()
        presentEmailInputAlertController(title: title, message: message, placeholder: placeholder, actionTitle: "Send".localized(), action: { email in
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
    func presentEmailInputAlertController(title: String, message: String, placeholder: String, actionTitle: String, action: @escaping (_ text: String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, adaptive: true)
        alert.addTextField(configurationHandler: { textField in
            //textField.addTarget(self, action: #selector(self.voucherTextChanged), for: .editingChanged)
            textField.placeholder = placeholder
            textField.keyboardType = .emailAddress
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let load = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            guard let text = alert.textFields?[0].text else { return }
            action(text)
        })

        alert.addAction(load)
        //load.isEnabled = false

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    /*@objc func voucherTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            if let text = sender.text, !text.isEmpty {
                (alert.actions[1] as UIAlertAction).isEnabled = true
            } else {
                (alert.actions[1] as UIAlertAction).isEnabled = false
            }
        }
    }*/
}

extension AdvancedOptions: ChangedSigningType {
    func changedSigningType() {
        API.setConfiguration(params: [.signingIdentityType: Preferences.signingIdentityType], success: {}, fail: { _ in })
        dataSource.sections = getSections()
    }
}
