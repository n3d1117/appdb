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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(openSigningInfoBlogArticle))

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

    private func loadAvailableCertificates() {
        API.getEnterpriseCerts { newCertificates in
            self.availableCertificates = newCertificates

            if let _currentCertificate = newCertificates.first(where: { cert in
                cert.id == Preferences.enterpriseCertId
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
    
    @objc private func openSigningInfoBlogArticle() {
        UIApplication.shared.open(URL(string: Global.signingCertsBlogArticle)!)
    }

    @objc private func dismissAnimated() { dismiss(animated: true) }

    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        Preferences.p12ValidationResult ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? availableCertificates.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            let certificate = availableCertificates[indexPath.row]
            cell.textLabel?.text = certificate.name
            cell.accessoryType = certificate.id == currentCertificate?.id ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Most Reliable Signing Certificate + Service guarantee for 1 year + Instant Activation!".localized()
            cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.theme_textColor = Color.title
        cell.textLabel?.makeDynamicFont()
        cell.setBackgroundColor(Color.veryVeryLightGray)
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Public Free Enterprise Certificates (frequent revokes and device blacklists)".localized() : "1-Year-Guaranteed signing certificates".localized()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard availableCertificates.indices.contains(indexPath.row) else { return }
            let certificate = availableCertificates[indexPath.row]
            if currentCertificate?.id != certificate.id {
                change(to: certificate)
            }
        } else {
            present(SigningCerts(), animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 75 : 85
    }

    fileprivate func change(to certificate: EnterpriseCertificate) {
        Preferences.set(.enterpriseCertId, to: certificate.id)
        currentCertificate = certificate
        changedCertDelegate?.changedEnterpriseCertificate()
        tableView.reloadData()
    }
}
