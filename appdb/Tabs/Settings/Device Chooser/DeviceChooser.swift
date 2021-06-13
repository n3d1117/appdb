//
//  DeviceChooser.swift
//  appdb
//
//  Created by ned on 13/06/21.
//  Copyright © 2021 ned. All rights reserved.
//

import UIKit

class DeviceChooser: LoadingTableView {

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    private var devices: [LinkedDevice] = [] {
        didSet {
            tableView.spr_endRefreshing()
            state = .done
        }
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

        title = "Choose Device".localized() // todo localize

        tableView.register(SimpleSubtitleCell.self, forCellReuseIdentifier: "device")
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.fetchDevices()
        }

        tableView.spr_beginRefreshing()
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    fileprivate func fetchDevices() {
        API.getAllLinkedDevices { [weak self] devices in
            guard let self = self else { return }

            self.devices = devices.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } fail: { [weak self] error in
            guard let self = self else { return }

            self.devices = []
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localized(), animated: false)
        }
    }

    // MARK: - Table View data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath) as? SimpleSubtitleCell {
            guard devices.indices.contains(indexPath.row) else { return UITableViewCell() }
            let device = devices[indexPath.row]
            let proString = device.isPro ? Global.bulletPoint + "PRO" : ""
            cell.textLabel?.text = device.name + proString
            cell.detailTextLabel?.text = device.niceIdeviceModel + " (" + device.iosVersion + ")"
            cell.textLabel?.theme_textColor = Color.title
            cell.textLabel?.makeDynamicFont()
            cell.detailTextLabel?.theme_textColor = Color.darkGray
            cell.detailTextLabel?.makeDynamicFont()
            cell.accessoryType = (device.linkToken == Preferences.linkToken) ? .checkmark : .none
            cell.setBackgroundColor(Color.veryVeryLightGray)
            cell.theme_backgroundColor = Color.veryVeryLightGray
            cell.selectedBackgroundView = bgColorView
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard devices.indices.contains(indexPath.row) else { return }
        let device = devices[indexPath.row]
        if device.linkToken == Preferences.linkToken {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        switchToDevice(name: device.name, linkToken: device.linkToken)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        devices.isEmpty ? nil : "Available Devices".localized() // todo localize
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 20
        } else {
            return 40
        }
    }

    // MARK: - Switch device

    fileprivate func switchToDevice(name: String, linkToken: String) {

        // Save token
        Preferences.set(.token, to: linkToken)
        tableView.reloadData()

        // Update link code
        API.getLinkCode(success: {

            // Update configuration
            API.getConfiguration(success: { [weak self] in
                guard let self = self else { return }

                // todo localize
                Messages.shared.hideAll()
                Messages.shared.showSuccess(
                    message: "Switched to \"\(name)\"".localized(),
                    context: .viewController(self)
                )
                NotificationCenter.default.post(name: .RefreshSettings, object: self)
            }, fail: { _ in })
        }, fail: { _ in })
    }
}
