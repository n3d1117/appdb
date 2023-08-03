//
//  SigningTypeChooser.swift
//  appdb
//
//  Created by ned on 05/01/22.
//  Copyright © 2022 ned. All rights reserved.
//

import Foundation
import UIKit

protocol ChangedSigningType: AnyObject {
    func changedSigningType()
}

class SigningTypeChooser: UITableViewController {

    weak var changedTypeDelegate: ChangedSigningType?

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    let availableOptions = ["auto", "development", "distribution"]

    static var currentType: String {
        Preferences.signingIdentityType
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

        title = "Signing Type".localized()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        tableView.cellLayoutMarginsFollowReadableWidth = true

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        if #available(iOS 13.0, *) {} else {
            if Global.isIpad {
                // Add 'Dismiss' button for iPad
                let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
                navigationItem.rightBarButtonItems = [dismissButton]
            }
        }
    }

    @objc private func dismissAnimated() { dismiss(animated: true) }

    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availableOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let type = availableOptions[indexPath.row]
        cell.textLabel?.text = type.capitalizingFirstLetter()
        cell.textLabel?.theme_textColor = Color.title
        cell.textLabel?.makeDynamicFont()
        cell.accessoryType = type == SigningTypeChooser.currentType ? .checkmark : .none
        cell.setBackgroundColor(Color.veryVeryLightGray)
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard availableOptions.indices.contains(indexPath.row) else { return }
        let type = availableOptions[indexPath.row]
        if SigningTypeChooser.currentType != type {
            change(with: type)
        }
    }

    fileprivate func change(with type: String) {
        Preferences.set(.signingIdentityType, to: type)
        changedTypeDelegate?.changedSigningType()
        tableView.reloadData()
    }
}
