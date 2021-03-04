//
//  SystemStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class SystemStatus: LoadingTableView {

    var checkedAt: String?

    var services: [ServiceStatus] = [] {
        didSet {
            self.tableView.spr_endRefreshing()
            self.state = .done
        }
    }

    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "System Status".localized()

        tableView.register(SimpleStaticCell.self, forCellReuseIdentifier: "service")
        tableView.estimatedRowHeight = 50

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
            self?.fetchStatus()
        }

        tableView.spr_beginRefreshing()
    }

    private func fetchStatus() {
        API.getSystemStatus(success: { [weak self] checkedAt, services in
            guard let self = self else { return }
            self.checkedAt = checkedAt
            self.services = services.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }, fail: { [weak self] error in
            guard let self = self else { return }
            self.services = []
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error.localizedDescription, animated: false)
        })
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "service", for: indexPath) as? SimpleStaticCell {
            cell.textLabel?.text = services[indexPath.row].name
            cell.accessoryView = UIImageView(image: services[indexPath.row].isOnline ? #imageLiteral(resourceName: "online") : #imageLiteral(resourceName: "offline"))
            cell.accessoryView?.frame.size.width = 24
            cell.accessoryView?.frame.size.height = 24
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        services.isEmpty ? nil : checkedAt
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 20
        } else {
            return 40
        }
    }
}
