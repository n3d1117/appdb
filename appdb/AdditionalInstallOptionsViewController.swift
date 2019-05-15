//
//  AdditionalInstallOptionsViewController.swift
//  appdb
//
//  Created by ned on 13/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Static

class AdditionalInstallOptionsViewController: TableViewController {
    
    var onCompletion: ((Bool, String, String) -> ())?

    fileprivate var duplicateApp: Bool = true
    fileprivate var newId: String = ""
    fileprivate var newName: String = ""
    
    var cancelled: Bool = true
    
    fileprivate let placeholder: String = Global.randomString(length: 4).lowercased()

    lazy var sections: [Static.Section] = [
        Section(rows: [
            Row(text: "Duplicate app".localized(), accessory: .switchToggle(value: duplicateApp) { [unowned self] newValue in
                self.duplicateApp = newValue
                self.setInstallButtonEnabled()
            }, cellClass: SimpleStaticCell.self),
            Row(text: "New ID".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": placeholder, "callback": { [unowned self] (newId: String) in
                    self.newId = newId.isEmpty ? self.placeholder : newId
                    self.setInstallButtonEnabled()
                }]
            ),
            Row(text: "New display name".localized(), cellClass: StaticTextFieldCell.self, context:
                ["placeholder": "Use Original".localized(), "callback": { [unowned self] (newName: String) in
                    self.newName = newName
                    self.setInstallButtonEnabled()
                }]
            ),
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Installation options".localized()
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        tableView.rowHeight = (!Global.isIpad && !Global.hasNotch && UIDevice.current.orientation.isLandscape) ? 53 : 50
        tableView.isScrollEnabled = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dismissAnimated))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Install".localized(), style: .done, target: self, action: #selector(proceedWithInstall))
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        newId = placeholder
        dataSource.sections = sections
    }
    
    @objc fileprivate func dismissAnimated() {
        cancelled = true
        dismiss(animated: true)
    }
    
    @objc fileprivate func proceedWithInstall() {
        onCompletion?(self.duplicateApp, self.newId, self.newName)
        cancelled = false
        dismiss(animated: true)
    }
    
    fileprivate func setInstallButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = !newId.contains(" ")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.tableView.rowHeight = (!Global.isIpad && !Global.hasNotch && UIDevice.current.orientation.isLandscape) ? 53 : 50
            self.tableView.reloadData()
        }, completion: nil)
    }
}
