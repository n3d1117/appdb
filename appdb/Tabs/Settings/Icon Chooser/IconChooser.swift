//
//  IconChooser.swift
//  appdb
//
//  Created by ned on 23/03/22.
//  Copyright © 2022 ned. All rights reserved.
//

import UIKit

class IconChooser: UITableViewController {

    struct IconOption {
        let filename: String
        let previewImageName: String
        let label: String
    }

    let icons: [IconOption] = [
        .init(filename: "icon", previewImageName: "icon", label: "Main (by aesign)".localized()),
        .init(filename: "Dark", previewImageName: "icon-dark", label: "Dark (by stayxnegative)".localized()),
        .init(filename: "Green", previewImageName: "icon-green", label: "Green".localized()),
        .init(filename: "Purple", previewImageName: "icon-purple", label: "Purple".localized()),
        .init(filename: "Yellow", previewImageName: "icon-yellow", label: "Yellow".localized()),
        .init(filename: "Pink", previewImageName: "icon-pink", label: "Pink".localized()),
        .init(filename: "Red", previewImageName: "icon-red", label: "Red".localized()),
        .init(filename: "Aqua", previewImageName: "icon-aqua", label: "Aqua".localized()),
            .init(filename: "Black", previewImageName: "icon-black", label: "Black".localized())
    ]

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIApplication.shared.supportsAlternateIcons {
            title = "Choose Icon".localized()

            tableView.register(IconChooserCell.self, forCellReuseIdentifier: "cell")
            tableView.rowHeight = 70

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
                    self.navigationItem.rightBarButtonItems = [dismissButton]
                }
            }
        } else {
            Messages.shared.showError(message: "Alternate icons seem to not work on this device".localized())
            self.dismissAnimated()
        }
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        icons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? IconChooserCell else {
            fatalError()
        }
        let iconValue = indexPath.row == 0 ? nil : icons[indexPath.row].filename
        cell.configure(with: icons[indexPath.row].label, value: iconValue, image: icons[indexPath.row].previewImageName)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        changeIcon(iconName: indexPath.row == 0 ? nil : icons[indexPath.row].filename) { result in
            switch result {
            case .success(_):
                Messages.shared.showSuccess(message: "App icon was set to '%@'".localizedFormat(self.icons[indexPath.row].label.localized()))
            case .failure(let error):
                Messages.shared.showError(message: error.localizedDescription)
            }
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Available Icons".localized()
    }

    func changeIcon(iconName: String?, completion: @escaping (Result<String?, Error>) -> Void) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(iconName))
            }
        }
    }
}
