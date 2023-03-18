//
//  AltStoreAppDetails+Extension.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import Cartography
import ObjectMapper

extension AltStoreAppDetails {

    // Set up
    func setUp() {
        // Register cells
        for cell in header { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        for cell in details { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        tableView.register(DetailsDescription.self, forCellReuseIdentifier: "description")
        tableView.register(DetailsChangelog.self, forCellReuseIdentifier: "changelog")

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }

        // Hide separator for empty cells
        tableView.tableFooterView = UIView()

        // UI
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        tableView.separatorStyle = .none // Let's use self made separators instead

        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }

        // Fix iOS 15 tableview section header padding
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    // Initialize cells
    func initializeCells() {
        header = [DetailsHeader(type: .altstore, content: app, delegate: self)]

        details = [
            DetailsScreenshots(type: .altstore, screenshots: app.screenshots, delegate: self),
            DetailsDescription(), // dynamic
            DetailsChangelog(), // dynamic
            DetailsInformation(type: .altstore, content: app)
        ]

        details.append(DetailsPublisher("© " + app.developer))
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    // Setting the right estimated height for rows with dynamic content helps with tableview jumping issues
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if details[indexPath.row] is DetailsDescription {
            return 145 ~~ 135
        } else if details[indexPath.row] is DetailsChangelog {
            return 115 ~~ 105
        } else {
            return 32
        }
    }

    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            self.tableView.reloadData()
        }, completion: nil)
    }
}

extension AltStoreAppDetails: DetailsHeaderDelegate {
    func installClicked(sender: RoundedButton) {
        install(sender: sender)
    }
}
