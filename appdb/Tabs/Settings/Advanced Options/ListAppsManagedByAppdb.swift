//
//  ListAppsManagedByAppdb.swift
//  appdb
//
//  Created by ned on 14/10/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class ListAppsManagedByAppdb: LoadingTableView {

    private var retryCount: Int = 0
    private var maxRetryLimit: Int = 10

    private var bundleIds: [String] = [] {
        didSet {
            self.tableView.spr_endRefreshing()
            self.state = .done
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

        title = "Apps managed by appdb".localized()

        tableView.register(SimpleStaticCell.self, forCellReuseIdentifier: "app")
        tableView.estimatedRowHeight = 50

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.fetchBundleIds()
        }

        tableView.spr_beginRefreshing()
    }

    private func fetchBundleIds() {
        API.getAppdbAppsBundleIdsTicket(success: { [weak self] ticket in
            guard let self = self else { return }

            API.getAppdbAppsBundleIds(ticket: ticket, success: { [weak self] bundleIds in
                guard let self = self else { return }
                self.retryCount = 0
                self.bundleIds = bundleIds.sorted { $0.lowercased() < $1.lowercased() }
            }, fail: { [weak self] error in
                guard let self = self else { return }

                if error == "NOT_READY" && self.retryCount < self.maxRetryLimit {
                    delay(1) {
                        self.retryCount += 1
                        self.fetchBundleIds()
                    }
                } else {
                    self.retryCount = 0
                    self.bundleIds = []
                    self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error.prettified, animated: false)
                }
            })
        }, fail: { [weak self] error in
            guard let self = self else { return }
            self.bundleIds = []
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error.prettified, animated: false)
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bundleIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "app", for: indexPath) as? SimpleStaticCell {
            cell.textLabel?.text = bundleIds[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        bundleIds.isEmpty ? nil : "Bundle IDs".localized()
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        bundleIds.isEmpty ? nil : "Only apps that are managed by appdb will appear here.".localized()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 20
        } else {
            return 40
        }
    }
}
