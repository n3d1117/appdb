//
//  Updates.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import RealmSwift

class Updates: LoadingTableView {
    
    var allApps: [UpdateableApp] = []
    var updateableApps: [UpdateableApp] = []
    var nonUpdateableApps: [UpdateableApp] = []
    
    // Keep track of which changelogs are collapsed
    var changelogCollapsedForIndexPath: [IndexPath: Bool] = [:]
    
    var isLoading: Bool = false
    
    var retryCount: Int = 0
    var timeoutLimit: Int = 60 // will throw error after 1 min of NOT_READY responses
    
    // Token to observe changes in Settings tab, used to update badge
    var token: NotificationToken?
    deinit { token = nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Updates".localized()

        setUp()
        
        tableView.register(UpdateCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = (135~~115)

        // Refresh action
        tableView.spr_setIndicatorHeader{ [weak self] in
            self?.changelogCollapsedForIndexPath = [:]
            self?.animated = false
            self?.checkUpdates()
        }
        
        checkUpdates()
    }
    
    fileprivate var onlyOnce: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // https://stackoverflow.com/a/47839657/6022481
        if #available(iOS 11.2, *) {
            navigationController?.navigationBar.tintAdjustmentMode = .normal
            navigationController?.navigationBar.tintAdjustmentMode = .automatic
        }

        // If device was just linked, start checking for updates as soon as view appears
        if DeviceInfo.deviceIsLinked, state == .error, errorMessage.text != "No updates found".localized() {
            self.animated = onlyOnce
            if onlyOnce { onlyOnce = false }
            state = .loading
            checkUpdates()
        }
    }
    
    // get update ticket -> check updates -> update UI
    
    func checkUpdates() {
        isLoading = true
        if DeviceInfo.deviceIsLinked {
            
            API.getUpdatesTicket(success: { ticket in
                
                self.getUpdates(ticket, done: { error in
                    if let error = error {
                        self.cleanup()
                        self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error, animated: self.animated)
                    } else {
                        
                        self.isLoading = false
                        self.tableView.spr_endRefreshing()
                        self.updateBadge()
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        
                        if self.updateableApps.isEmpty && self.nonUpdateableApps.isEmpty {
                            self.tableView.reloadData()
                            self.showErrorMessage(text: "No updates found".localized(), animated: self.animated)
                        } else {
                            self.state = .done
                        }
                    }
                })
                
            }, fail: { error in
                self.cleanup()
                self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: self.animated)
            })
        } else {
            self.cleanup()
            showErrorMessage(text: "An error has occurred".localized(), secondaryText: "Please authorize app from Settings first".localized(), animated: self.animated)
        }
    }
    
    fileprivate func cleanup() {
        isLoading = false
        tableView.spr_endRefreshing()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        updateableApps = []
        nonUpdateableApps = []
        tableView.reloadData()
        updateBadge()
    }
    
    func getUpdates(_ t: String, done: @escaping (_ error: String?) -> Void) {
        API.getUpdates(ticket: t, success: { apps in
            self.allApps = apps
            let mixed = apps.filter({ !$0.isIgnored }).sorted{ $0.name.lowercased() < $1.name.lowercased() }
            self.updateableApps = mixed.filter({ $0.updateable })
            self.nonUpdateableApps = mixed.filter({ !$0.updateable })
            done(nil)
        }, fail: { error in
            debugLog(error)
            if error == "NOT_READY" && self.retryCount < self.timeoutLimit {
                delay(1) {
                    self.retryCount += 1
                    self.getUpdates(t, done: done)
                }
            } else {
                self.retryCount = 0
                done(error.prettified)
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? updateableApps.count : nonUpdateableApps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UpdateCell
        let apps = indexPath.section == 0 ? updateableApps : nonUpdateableApps
        let item = apps[indexPath.row]
        
        // If there are two apps with the same name, append section at the end to distinguish them
        var name = item.name
        if apps.filter({ $0.name == name }).count > 1 {
            let stringToBeAdded = item.type == "ios" ? (" (" + "iOS".localized() + ")") : (" (" + "Cydia".localized() + ")")
            name.append(contentsOf: stringToBeAdded)
        }
        
        cell.whatsnew.collapsed = changelogCollapsedForIndexPath[indexPath] ?? true
        cell.configure(with: name, versionOld: item.versionOld, versionNew: item.versionNew, changelog: item.whatsnew, image: item.image)
        cell.whatsnew.delegated = self

        return cell
    }
    
    // Push details controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let apps = indexPath.section == 0 ? updateableApps : nonUpdateableApps
        let item = apps[indexPath.row]
        let vc = Details(type: item.itemType, trackid: item.trackid)
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Section header view
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UpdatesSectionHeader(showsButton: section == 1)
        var text: String!
        if section == 0 {
            if updateableApps.isEmpty { return nil }
            let count = updateableApps.count
            text = (count == 1 ? "%@ Updateable app" : "%@ Updateable apps").localizedFormat("\(count)")
        } else {
            view.helpButton.addTarget(self, action: #selector(self.showHelp), for: .touchUpInside)
            if nonUpdateableApps.isEmpty { return nil }
            let count = nonUpdateableApps.count
            text = (count == 1 ? "%@ Non updateable app" : "%@ Non updateable apps").localizedFormat("\(count)")
        }
        view.configure(with: text)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return updateableApps.isEmpty ? 0 : (60~~50)
        } else {
            return nonUpdateableApps.isEmpty ? 0 : (40~~30)
        }
    }
    
    // MARK: - Swipe to ignore
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let apps = indexPath.section == 0 ? updateableApps : nonUpdateableApps
        return !apps.isEmpty && !isLoading
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let ignore = UITableViewRowAction(style: .normal, title: "Ignore".localized()) { _, _ in
            
            let realm = try! Realm()
            guard let ignoredList = realm.objects(IgnoredUpdateableApps.self).first else { return }
            
            try! realm.write {
                let trackid = (indexPath.section == 0 ? self.updateableApps : self.nonUpdateableApps)[indexPath.row].trackid
                ignoredList.ignoredTrackids.append(trackid)
            }

            if indexPath.section == 0 {
                self.updateableApps.remove(at: indexPath.row)
                if self.updateableApps.isEmpty {
                    tableView.reloadData()
                    if self.nonUpdateableApps.isEmpty {
                        self.showErrorMessage(text: "No updates found".localized(), animated: self.animated)
                    }
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                self.nonUpdateableApps.remove(at: indexPath.row)
                if self.nonUpdateableApps.isEmpty {
                    tableView.reloadData()
                    if self.updateableApps.isEmpty {
                        self.showErrorMessage(text: "No updates found".localized(), animated: self.animated)
                    }
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
            self.changelogCollapsedForIndexPath[indexPath] = nil
            
            if let header = tableView.headerView(forSection: indexPath.section) as? UpdatesSectionHeader {
                if indexPath.section == 0 {
                    let count = self.updateableApps.count
                    header.configure(with: (count == 1 ? "%@ Updateable app" : "%@ Updateable apps").localizedFormat("\(count)"))
                } else {
                    let count = self.nonUpdateableApps.count
                    header.configure(with: (count == 1 ? "%@ Non updateable app" : "%@ Non updateable apps").localizedFormat("\(count)"))
                }
            }
            
            self.updateBadge()

        }
        ignore.backgroundColor = .red
        return [ignore]
    }
    
    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if self.updateableApps.count + self.nonUpdateableApps.count > 0 { self.tableView.reloadData() }
        }, completion: nil)
    }
    
}
