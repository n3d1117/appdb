//
//  DeviceStatus.swift
//  appdb
//
//  Created by ned on 16/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class DeviceStatus: LoadingTableView {
    
    var didEndRefreshing: Bool = false
    var timer: Timer?
    let refreshEvery: Double = 2.2
    
    var statuses: [DeviceStatusItem] = [] {
        didSet {
            if !didEndRefreshing {
                didEndRefreshing = true
                tableView.spr_endRefreshingAll()
            }
            if !self.statuses.isEmpty, let error = self.errorMessage, let secondary = self.secondaryErrorMessage {
                error.isHidden = true
                secondary.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Device Status".localized()
        
        tableView.register(DeviceStatusCell.self, forCellReuseIdentifier: "status")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        
        animated = false
        showsErrorButton = false
        showsSpinner = false
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        // Add trash icon to clear command queue
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.emptyCommandQueue))
        
        if IS_IPAD {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItem = dismissButton
            self.navigationItem.leftBarButtonItem = trash
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem = trash
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        // Refresh action
        tableView.spr_setIndicatorHeader{ [weak self] in
            self?.fetchStatus()
        }
        
        tableView.spr_beginRefreshing()
        
        self.timer = Timer.scheduledTimer(timeInterval: refreshEvery, target: self,
                                          selector: #selector(self.fetchStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: refreshEvery, target: self,
                                     selector: #selector(self.fetchStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func emptyCommandQueue(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Clear command queue?".localized(), preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        let clearAction = UIAlertAction(title: "Clear".localized(), style: .destructive) { _ in
            API.emptyCommandQueue(success: {
                self.fetchStatus()
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: self.refreshEvery, target: self,
                                                  selector: #selector(self.fetchStatus), userInfo: nil, repeats: true)
            })
        }
        alertController.addAction(clearAction)
        alertController.addAction(cancelAction)
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = sender
        }
        self.present(alertController, animated: true)
    }
    
    @objc fileprivate func fetchStatus() {
        API.getDeviceStatus(success: { results in
            let diff = Diff(from: self.statuses, to: results)
            self.statuses = results
            self.handleUpdates(from: diff)
            
            if self.statuses.isEmpty {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                self.showErrorMessage(text: "Device status is empty.".localized(), animated: false)
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }

        }) { error in
            let diff = Diff(from: self.statuses, to: [])
            self.statuses = []
            self.handleUpdates(from: diff)
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localizedDescription, animated: false)
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    // Automagically handles inserts, deletes and updates of rows
    fileprivate func handleUpdates(from diff: Diff<[DeviceStatusItem]>) {
        
        func doTheMagic(from diff: Diff<[DeviceStatusItem]>) {
            for index in diff.deleted { tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic) }
            for index in diff.inserted { tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic) }
            for match in diff.matches {
                if match.changed {
                    // Why both? TODO check indexes
                    print("MATCH CHANGED: from: \(match.from), to: \(match.to)")
                    tableView.reloadRows(at: [IndexPath(row: match.to, section: 0)], with: .none)
                    tableView.reloadRows(at: [IndexPath(row: match.from, section: 0)], with: .none)
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates({
                doTheMagic(from: diff)
            }, completion: nil)
        } else {
            tableView.beginUpdates()
            doTheMagic(from: diff)
            tableView.endUpdates()
        }
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "status", for: indexPath) as? DeviceStatusCell {
            cell.updateContent(with: statuses[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}
