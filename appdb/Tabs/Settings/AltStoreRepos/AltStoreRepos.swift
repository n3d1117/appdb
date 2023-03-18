//
//  AltStoreRepos.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//


import UIKit

class AltStoreRepos: LoadingTableView {

    var allRepos: [AltStoreRepo] = []
    var privateRepos: [AltStoreRepo] = []
    var publicRepos: [AltStoreRepo] = []

    var isLoading = false
    
    // Observation token to observe changes in Settings tab, used to update badge
    var observation: DefaultsObservation?

    deinit {
        observation = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "AltStore Repos".localized()
        
        setUp()

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.animated = false
            self?.loadRepos()
        }

        loadRepos()
    }

    private var onlyOnce = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // https://stackoverflow.com/a/47839657/6022481
        if #available(iOS 11.2, *) {
            navigationController?.navigationBar.tintAdjustmentMode = .normal
            navigationController?.navigationBar.tintAdjustmentMode = .automatic
        }

        // If device was just linked, start checking for updates as soon as view appears
        if Preferences.deviceIsLinked, state == .error, errorMessage.text != "No repos found".localized() {
            self.animated = onlyOnce
            if onlyOnce { onlyOnce = false }
            state = .loading
            loadRepos()
        }
    }

    // get update ticket -> check updates -> update UI

    func loadRepos() {
        isLoading = true
        if Preferences.deviceIsLinked {
            self.getRepos(done: { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    self.cleanup()
                    self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: self.animated)
                } else {
                    self.isLoading = false
                    self.tableView.spr_endRefreshing()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true

                    if self.privateRepos.isEmpty && self.publicRepos.isEmpty {
                        self.tableView.reloadData()
                        self.showErrorMessage(text: "No AltStore repos found".localized(), animated: self.animated)
                    } else {
                        self.state = .done
                    }
                }
            })
        } else {
            self.cleanup()
            showErrorMessage(text: "An error has occurred".localized(), secondaryText: "Please authorize app from Settings first".localized(), animated: false)
        }
    }

    internal func cleanup() {
        isLoading = false
        tableView.spr_endRefreshing()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        privateRepos = []
        publicRepos = []
        tableView.reloadData()
    }

    func getRepos(done: @escaping (_ error: String?) -> Void) {
        API.getAltStoreRepos(isPublic: false, success: { _privateRepos in
            API.getAltStoreRepos(isPublic: true, success: { [weak self] _publicRepos in
                guard let self = self else { return }

                self.privateRepos = _privateRepos
                self.publicRepos = _publicRepos
                
                self.allRepos = _privateRepos + _publicRepos
                
                done(nil)
            }, fail: { error in
                done(error.prettified)
            })
        }, fail: { error in
            done(error.prettified)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? privateRepos.count : publicRepos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AltStoreRepoCell else { return UITableViewCell() }
        let repos = indexPath.section == 0 ? privateRepos : publicRepos
        let item = repos[indexPath.row]

        cell.configure(with: item)

        return cell
    }

    // Push details controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repos = indexPath.section == 0 ? privateRepos : publicRepos
        let item = repos[indexPath.row]
        let vc = AltStoreRepoApps(repo: item)
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
        let view = UpdatesSectionHeader(showsButton: false)
        var text: String!
        if section == 0 {
            if privateRepos.isEmpty { return nil }
            let count = privateRepos.count
            text = (count == 1 ? "%@ Private Repo" : "%@ Private Repos").localizedFormat(String(count))
        } else {
            if publicRepos.isEmpty { return nil }
            let count = publicRepos.count
            text = (count == 1 ? "%@ Public Repo" : "%@ Public Repos").localizedFormat(String(count))
        }
        view.configure(with: text)
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return privateRepos.isEmpty ? 0 : (60 ~~ 50)
        } else {
            return publicRepos.isEmpty ? 0 : (60 ~~ 50)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section != 0 {
            return nil
        }
        
        return [UITableViewRowAction(style: .destructive, title: "Delete".localized(), handler: { _, indexPath in
            let repos = indexPath.section == 0 ? self.privateRepos : self.publicRepos
            let item = repos[indexPath.row]
            
            if !item.isPublic {
                API.deleteAltStoreRepo(id: item.id) {
                    Messages.shared.showSuccess(message: "The repository was deleted successfully".localized(), context: .viewController(self))
                    self.loadRepos()
                } fail: { error in
                    Messages.shared.showError(message: error, context: .viewController(self))
                }

            }
        })]
    }

    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            if self.privateRepos.count + self.publicRepos.count > 0 { self.tableView.reloadData() }
        }, completion: nil)
    }
}
