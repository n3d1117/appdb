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
        UIView.animate(withDuration: 0.2, animations: view.superview!.layoutIfNeeded)
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

    var onCompletion: ((Bool, String, String) -> Void)?

    private var duplicateApp = true
    private var newId: String = ""
    private var newName: String = ""

    var cancelled = true

    private let placeholder: String = Global.randomString(length: 4).lowercased()

    private let rowHeight: CGFloat = 50
    var height: CGFloat {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0
        return navbarHeight + rowHeight * CGFloat(duplicateApp ? 3 : 2)
    }

    lazy var sections: [Static.Section] = [
        Section(rows: [
            Row(text: "Duplicate app".localized(), accessory: .switchToggle(value: duplicateApp) { [unowned self] newValue in
                self.duplicateApp = newValue
                self.setInstallButtonEnabled()
                self.switchMode()
            }, cellClass: SimpleStaticCell.self),
            Row(text: "New display name".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": "Use Original".localized(), "callback": { [unowned self] (newName: String) in
                    self.newName = newName
                    self.setInstallButtonEnabled()
                }]
            ),
            Row(text: "New ID".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": placeholder, "callback": { [unowned self] (newId: String) in
                    self.newId = newId.isEmpty ? self.placeholder : newId
                    self.setInstallButtonEnabled()
                }]
            )
        ])
    ]

    lazy var compactSections: [Static.Section] = [
        Section(rows: [
            Row(text: "Duplicate app".localized(), accessory: .switchToggle(value: duplicateApp) { [unowned self] newValue in
                self.duplicateApp = newValue
                self.setInstallButtonEnabled()
                self.switchMode()
            }, cellClass: SimpleStaticCell.self),
            Row(text: "New display name".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": "Use Original".localized(), "callback": { [unowned self] (newName: String) in
                    self.newName = newName
                    self.setInstallButtonEnabled()
                }]
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

        tableView.rowHeight = rowHeight
        tableView.isScrollEnabled = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dismissAnimated))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Install".localized(), style: .done, target: self, action: #selector(proceedWithInstall))
        navigationItem.rightBarButtonItem?.isEnabled = true

        newId = placeholder
        dataSource.sections = sections
    }

    private func switchMode() {
        heightDelegate?.updateHeight()
        dataSource.sections = duplicateApp ? sections : compactSections
    }

    @objc private func dismissAnimated() {
        cancelled = true
        dismiss(animated: true)
    }

    @objc private func proceedWithInstall() {
        onCompletion?(self.duplicateApp, self.newId, self.newName)
        cancelled = false
        dismiss(animated: true)
    }

    private func setInstallButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = !newId.contains(" ")
    }
}
