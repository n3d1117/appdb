//
//  NewWishes.swift
//  appdb
//
//  Created by ned on 07/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class NewWishes: LoadingTableView {

    private var currentPage: Int = 1
    private var allLoaded = false
    private var items: [WishApp] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(WishAppCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = (105 ~~ 85)

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.currentPage = 1
            self?.items = []
            self?.loadContent()
        }

        setFooter()

        // Begin refresh
        tableView.spr_beginRefreshing()
    }

    // Called when user reaches bottom, loads 25 more
    private func setFooter() {
        tableView.spr_setIndicatorFooter { [weak self] in
            self?.currentPage += 1
            self?.loadContent()
        }
    }

    private func loadContent() {

        if self.allLoaded {
            allLoaded = false
            setFooter()
        }

        API.getPublishRequests(includeAll: false, page: currentPage, success: { [weak self] array in
            guard let self = self else { return }

            if array.isEmpty {
                self.allLoaded = true
                if self.currentPage == 1 {
                    delay(0.3) {
                        self.tableView.spr_endRefreshingWithNoMoreData()
                        self.showErrorMessage(text: "No new wishes to show".localized(), animated: false)
                    }
                } else {
                    self.tableView.spr_endRefreshingWithNoMoreData()
                    self.state = .done
                }
            } else {
                self.items += array
                if self.items.count < 25 {
                    self.tableView.spr_endRefreshingWithNoMoreData()
                } else {
                    self.tableView.spr_endRefreshing()
                }
                self.state = .done
            }
        }, fail: { error in
            self.tableView.spr_endRefreshing()
            self.items = []
            self.tableView.reloadData()
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: false)
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WishAppCell, items.indices.contains(indexPath.row) else { return UITableViewCell() }
        cell.configure(with: items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = Details(type: .ios, trackid: items[indexPath.row].trackid)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let upvote = UITableViewRowAction(style: .normal, title: "↑") { _, _ in
            API.createPublishRequest(appStoreUrl: "https://apps.apple.com/app/id\(self.items[indexPath.row].trackid)") { error in
                if let error = error {
                    Messages.shared.showError(message: error.prettified, context: .viewController(self))
                }
            }
        }
        upvote.backgroundColor = .systemOrange
        return [upvote]
    }
}
