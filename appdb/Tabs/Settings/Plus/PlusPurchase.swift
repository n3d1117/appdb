//
//  PlusPurchase.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import WebKit

class PlusPurchase: LoadingTableView {

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    private var purchaseOptions: [PlusPurchaseOption] = [] {
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

        title = "Purchase PLUS".localized()

        tableView.register(PlusPurchaseCell.self, forCellReuseIdentifier: "purchaseOption")
        tableView.estimatedRowHeight = 85
        tableView.rowHeight = 85

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
            self?.fetchPurchaseOptions()
        }

        tableView.spr_beginRefreshing()
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    fileprivate func fetchPurchaseOptions() {
        API.getPlusPurchaseOptions { [weak self] purchaseOptions in
            guard let self = self else { return }

            self.purchaseOptions = purchaseOptions.sorted { $0.price.lowercased() < $1.price.lowercased() }
        } fail: { [weak self] error in
            guard let self = self else { return }

            self.purchaseOptions = []
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localized(), animated: false)
        }
    }

    // MARK: - Table View data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchaseOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseOption", for: indexPath) as? PlusPurchaseCell {
            guard purchaseOptions.indices.contains(indexPath.row) else { return UITableViewCell() }
            let purchaseOption = purchaseOptions[indexPath.row]
            cell.configure(with: purchaseOption)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard purchaseOptions.indices.contains(indexPath.row) else { return }
        let purchaseOption = purchaseOptions[indexPath.row]
        if purchaseOption.html.isEmpty {
            UIApplication.shared.open(URL(string: purchaseOption.link)!, options: [:], completionHandler: nil)
        } else {
            let purchaseWeb = PlusPurchaseWeb(with: purchaseOption)
            navigationController!.pushViewController(purchaseWeb, animated: true)
            purchaseWeb.loadWebView()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if purchaseOptions.isEmpty { return nil }

        let view = UpdatesSectionHeader(showsButton: true)
        view.configure(with: "Available PLUS subscriptions".localized())
        view.helpButton.addTarget(self, action: #selector(self.showHelp), for: .touchUpInside)
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        purchaseOptions.isEmpty ? 0 : (60 ~~ 50)
    }

    @objc func showHelp() {
        let message = "appdb PLUS allows you to use appdb on non-jailbroken device or Apple Silicon Mac with your own developer account and sign apps in the cloud without any limitations\n\nPLUS is activated per device, separately for each of your devices\n\nWe use this money to pay for servers, traffic, and support the community\n\nPLUS is not transferable between devices, you can cancel it at any time, or we will notify your about existing subscription for unlinked device, so you can cancel it if you sold your device\n\nPLUS is not compatible with corporate-owned devices with MDM. Please use appdb on your personal devices".localized()
        let alertController = UIAlertController(title: "What is appdb PLUS?".localized(), message: message, preferredStyle: .alert, adaptive: true)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
