//
//  MyDylibs.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//


import UIKit

class MyDylibs: LoadingTableView {

    var myDylibs: [String] = []

    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Dylibs, Frameworks and Debs".localized()
        
        setUp()

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.animated = false
            self?.loadDylibs()
        }

        loadDylibs()
    }

    // get update ticket -> check updates -> update UI

    func loadDylibs() {
        isLoading = true
        if Preferences.deviceIsLinked {
            self.getDylibs(done: { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    self.cleanup()
                    self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: self.animated)
                } else {
                    self.isLoading = false
                    self.tableView.spr_endRefreshing()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true

                    if self.myDylibs.isEmpty {
                        self.tableView.reloadData()
                        self.showErrorMessage(text: "No dylibs found".localized(), animated: self.animated)
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
        myDylibs = []
        tableView.reloadData()
    }

    func getDylibs(done: @escaping (_ error: String?) -> Void) {
        API.getDylibs(success: { [weak self] dylibs in
            guard let self = self else { return }

            self.myDylibs = dylibs            
            done(nil)
        }, fail: { error in
            done(error.prettified)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myDylibs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        let item = myDylibs[indexPath.row]
        
        cell.selectionStyle = .none
        cell.textLabel!.text = item

        return cell
    }

    // MARK: - Section header view

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UpdatesSectionHeader(showsButton: true)
        view.configure(with: "My Dylibs, Frameworks and Debs".localized())
        view.helpButton.addTarget(self, action: #selector(self.showHelp), for: .touchUpInside)
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return myDylibs.isEmpty ? 0 : (60 ~~ 50)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        return [UITableViewRowAction(style: .destructive, title: "Delete".localized(), handler: { _, indexPath in
            let item = self.myDylibs[indexPath.row]
            
            API.deleteDylib(name: item) {
                Messages.shared.showSuccess(message: "The dylib was deleted successfully".localized(), context: .viewController(self))
                self.loadDylibs()
            } fail: { error in
                Messages.shared.showError(message: error, context: .viewController(self))
            }
        })]
    }

    // Reload data on rotation to update ElasticLabel text
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            if self.myDylibs.count > 0 { self.tableView.reloadData() }
        }, completion: nil)
    }
    
    @objc func showHelp() {
        let message = "Here you can upload or import dynamic libraries, frameworks or debian packages or ZIP archives with tweaks to inject into apps that you are installing via appdb. Uploading or importing of any file will enable “Ask for Installation Options” feature for current device, so you can choose what tweaks you want to include in the app. You can disable this option later on device features configuration page.\n\nPlease note that not all packages, dylibs or frameworks that were built for jailbroken devices will work on your non-jailbroken devices.".localized()
        let alertController = UIAlertController(title: "My Dylibs, Frameworks and Debs".localized(), message: message, preferredStyle: .alert, adaptive: true)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
