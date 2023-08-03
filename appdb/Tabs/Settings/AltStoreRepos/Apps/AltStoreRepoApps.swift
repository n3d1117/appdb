//
//  AltStoreRepoApps.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 st3vefvcks. All rights reserved.
//

import UIKit
import ObjectMapper

class AltStoreRepoApps: LoadingTableView {

    var repo: AltStoreRepo!

    var query: String = ""

    var apps: [AltStoreApp] = []

    private var filteredApps: [AltStoreApp] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // Store the result from registerForPreviewing(with:sourceView:)
    var previewingContext: UIViewControllerPreviewing?

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    // Called when repo cell is clicked
    convenience init(repo: AltStoreRepo) {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
        self.repo = repo
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(AltStoreRepoAppCell.self, forCellReuseIdentifier: "altstoreappcell")
        tableView.rowHeight = (125 ~~ 105)

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            previewingContext = registerForPreviewing(with: self, sourceView: tableView)
        }

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = "Search Apps".localized()
        searchController.searchBar.textField?.theme_textColor = Color.title
        searchController.searchBar.textField?.theme_keyboardAppearance = [.light, .dark, .dark]
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            searchController.searchBar.barStyle = .default
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.showsScopeBar = false
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
        }

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.leftBarButtonItems = [dismissButton]
        }

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.loadContent()
        }

        // Begin refresh
        tableView.spr_beginRefreshing()
    }

    private func loadContent() {
        API.getAltStoreRepo(id: repo.id, success: { [weak self] _repo in
            guard let self = self else { return }

            self.repo = _repo

            if _repo.apps != nil && !_repo.apps!.isEmpty {
                self.apps = _repo.apps!
            }

            print("apps: \(self.apps)")

            self.state = .done
            self.tableView.spr_endRefreshing()
            self.tableView.reloadData()
        }, fail: { error in
            self.tableView.spr_endRefreshing()
            self.tableView.reloadData()
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: false)
        })
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering() ? filteredApps.count : apps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (isFiltering() ? filteredApps : apps).indices.contains(indexPath.row) else { return UITableViewCell() }
        let item = isFiltering() ? filteredApps[indexPath.row] : apps[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "altstoreappcell",
                                                       for: indexPath) as? AltStoreRepoAppCell else { return UITableViewCell() }
        cell.configure(app: item)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = isFiltering() ? filteredApps[indexPath.row] : apps[indexPath.row]
        let vc = AltStoreAppDetails(item: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension AltStoreRepoApps: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    func searchBarIsEmpty() -> Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String) {
        query = searchText
        if (query.isEmpty) {
            self.filteredApps = apps
        } else {
            filteredApps = apps.filter({( item: AltStoreApp) -> Bool in
                item.name.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        }
    }

    func isFiltering() -> Bool {
        searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension AltStoreRepoApps {

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = isFiltering() ? filteredApps[indexPath.row] : apps[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { AltStoreAppDetails(item: item) })
    }

    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                self.show(viewController, sender: self)
            }
        }
    }
}

// MARK: - 3D Touch Peek and Pop

extension AltStoreRepoApps: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let tableView = previewingContext.sourceView as? UITableView else { return nil }
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let item = isFiltering() ? filteredApps[indexPath.row] : apps[indexPath.row]
        let vc = AltStoreAppDetails(item: item)
        return vc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

// Allow 3D touch on search results when search controller is active
extension AltStoreRepoApps: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            unregisterForPreviewing(withContext: context)
            previewingContext = searchController.registerForPreviewing(with: self, sourceView: tableView)
        }
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        if let context = previewingContext {
            searchController.unregisterForPreviewing(withContext: context)
            previewingContext = registerForPreviewing(with: self, sourceView: tableView)
        }
    }
}
