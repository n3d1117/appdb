//
//  AdditionalInstallOptionsViewController.swift
//  appdb
//
//  Created by ned on 13/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Static

protocol AdditionalInstallOptionsHeightDelegate: AnyObject {
    func updateHeight()
}

// A custom UINavigationController suited to wrap a AdditionalInstallOptionsViewController with variable height

class AdditionalInstallOptionsNavController: UINavigationController, AdditionalInstallOptionsHeightDelegate {

    var group = ConstraintGroup()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        setupConstraints()
    }

    // Setup constraints
    private func setupConstraints() {
        if let vc = self.viewControllers.first as? AdditionalInstallOptionsViewController {
            constrain(view, replace: group) { view in
                view.height ~== vc.height
                view.width ~<= 500
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.setupConstraints()
        }, completion: nil)
    }

    func updateHeight() {
        setupConstraints()
        if let sv = view.superview {
            UIView.animate(withDuration: 0.2, animations: sv.layoutIfNeeded)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AdditionalInstallOptionsViewController: TableViewController {

    weak var heightDelegate: AdditionalInstallOptionsHeightDelegate?

    var onCompletion: ((_ patchIap: Bool, _ enableGameTrainer: Bool, _ removePlugins: Bool, _ enablePushNotifications: Bool,
                        _ duplicateApp: Bool, _ newId: String, _ newName: String) -> Void)?

    private var newId: String = ""
    private var newName: String = ""

    var cancelled = true

    private let placeholder: String = Global.randomString(length: 5).lowercased()

    private let rowHeight: CGFloat = 50
    var height: CGFloat {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 44
        return navbarHeight + rowHeight * CGFloat(sections.first!.rows.count)
    }

    lazy var sections: [Static.Section] = [
        Section(rows: [
            Row(text: "New display name".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": "Use Original".localized(), "callback": { [unowned self] (newName: String) in
                    self.newName = newName
                    self.setInstallButtonEnabled()
                }]
            ),
            Row(text: "Patch in-app Purchases".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                Preferences.set(.enableIapPatch, to: new)
            }, "value": Preferences.enableIapPatch]),
            Row(text: "Enable Game Trainer".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                Preferences.set(.enableTrainer, to: new)
            }, "value": Preferences.enableTrainer]),
            Row(text: "Remove Plugins".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                Preferences.set(.removePlugins, to: new)
            }, "value": Preferences.removePlugins]),
            Row(text: "Enable Push Notifications".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                Preferences.set(.enablePushNotifications, to: new)
            }, "value": Preferences.enablePushNotifications]),
            Row(text: "Duplicate app".localized(), cellClass: SwitchCell.self, context: ["valueChange": { (new: Bool) in
                Preferences.set(.duplicateApp, to: new)
                self.setInstallButtonEnabled()
            }, "value": Preferences.duplicateApp]),
            Row(text: "New ID".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": placeholder, "callback": { [unowned self] (newId: String) in
                    self.newId = newId.isEmpty ? self.placeholder : newId
                    self.setInstallButtonEnabled()
                }, "forceLowercase": true, "characterLimit": 5]
            )
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Installation options".localized()

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.rowHeight = rowHeight
        tableView.isScrollEnabled = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dismissAnimated))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Install".localized(), style: .done, target: self, action: #selector(proceedWithInstall))
        navigationItem.rightBarButtonItem?.isEnabled = true

        newId = placeholder
        dataSource.sections = sections
    }

    @objc private func dismissAnimated() {
        cancelled = true
        dismiss(animated: true)
    }

    @objc private func proceedWithInstall() {
        onCompletion?(Preferences.enableIapPatch, Preferences.enableTrainer, Preferences.removePlugins, Preferences.enablePushNotifications, Preferences.duplicateApp, self.newId.lowercased(), self.newName)
        cancelled = false
        dismiss(animated: true)
    }

    private func setInstallButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = newId.count == 5 && !newId.contains(" ")
    }
}
