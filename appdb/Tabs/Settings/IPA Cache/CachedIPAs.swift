//
//  CachedIPAs.swift
//  appdb
//
//  Created by stev3fvcks on 26.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import Static

class CachedIPAs: LoadingTableView {

    var cachedIPAs: [CachedIPA] = []

    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Cached IPAs".localized()
        
        setUp()

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.animated = false
            self?.loadCachedIPAs()
        }

        loadCachedIPAs()
    }
    
    func loadCachedIPAs() {
        isLoading = true
        self.getCachedIPAs(done: { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.cleanup()
                self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: self.animated)
            } else {
                self.isLoading = false
                self.tableView.spr_endRefreshing()
                self.navigationItem.rightBarButtonItem?.isEnabled = true

                if self.cachedIPAs.isEmpty {
                    self.tableView.reloadData()
                    self.showErrorMessage(text: "No cached IPAs found".localized(), animated: self.animated)
                } else {
                    self.state = .done
                }
            }
        })
    }

    internal func cleanup() {
        isLoading = false
        tableView.spr_endRefreshing()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        cachedIPAs = []
        tableView.reloadData()
    }

    func getCachedIPAs(done: @escaping (_ error: String?) -> Void) {
        API.getIPACacheStatus(success: { cacheStatus in
            self.cachedIPAs = cacheStatus.ipas
            done(nil)
        }, fail: { error in
            done(error.localizedDescription)
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cachedIPAs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SimpleStaticCell {
            
            let item = cachedIPAs[indexPath.row]
            
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.sizeHr
            cell.textLabel?.theme_textColor = Color.title
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        return [UITableViewRowAction(style: .destructive, title: "Delete".localized(), handler: { _, indexPath in
            let item = self.cachedIPAs[indexPath.row]
            
            API.deleteIpaFromCache(bundleId: item.bundleId) {
                Messages.shared.showSuccess(message: "The cached IPA was deleted successfully".localized(), context: .viewController(self))
                self.loadCachedIPAs()
            }
        })]
    }

    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            if self.cachedIPAs.count > 0 { self.tableView.reloadData() }
        }, completion: nil)
    }
}
