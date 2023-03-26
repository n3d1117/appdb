//
//  EnterpriseCertChooser.swift
//  appdb
//
//  Created by stev3fvcks on 26.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Foundation
import UIKit

protocol ChangedEnterpriseCertificate: AnyObject {
    func changedEnterpriseCertificate()
}

class EnterpriseCertChooser: UITableViewController {

    weak var changedCertDelegate: ChangedEnterpriseCertificate?

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    var availableCertificates: [EnterpriseCertificate] = []

    var currentCertificate: EnterpriseCertificate?

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Enterprise Certificate".localized()

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
        
        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.loadAvailableCertificates()
        }
        
        loadAvailableCertificates()
    }
    
    private func loadAvailableCertificates() -> Void {
        API.getEnterpriseCerts { newCertificates in
            self.availableCertificates = newCertificates
            
            if let _currentCertificate = newCertificates.first(where: { cert in
                return cert.id == Preferences.enterpriseCertId
            }) {
                self.currentCertificate = _currentCertificate
            }
            
            self.tableView.spr_endRefreshing()
            self.tableView.reloadData()
        } fail: { error in
            Messages.shared.showError(message: error.localizedDescription)
            self.tableView.spr_endRefreshing()
            self.tableView.reloadData()
        }
    }

    @objc private func dismissAnimated() { dismiss(animated: true) }

    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availableCertificates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let certificate = availableCertificates[indexPath.row]
        cell.textLabel?.text = certificate.name
        cell.textLabel?.theme_textColor = Color.title
        cell.textLabel?.makeDynamicFont()
        cell.accessoryType = certificate.id == currentCertificate?.id ? .checkmark : .none
        cell.setBackgroundColor(Color.veryVeryLightGray)
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard availableCertificates.indices.contains(indexPath.row) else { return }
        let certificate = availableCertificates[indexPath.row]
        if currentCertificate?.id != certificate.id {
            change(to: certificate)
        }
    }

    fileprivate func change(to certificate: EnterpriseCertificate) {
        Preferences.set(.enterpriseCertId, to: certificate.id)
        currentCertificate = certificate
        changedCertDelegate?.changedEnterpriseCertificate()
        tableView.reloadData()
    }
}
