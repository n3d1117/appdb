//
//  SeeAll.swift
//  appdb
//
//  Created by ned on 21/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import ObjectMapper

class SeeAll: LoadingTableView {

    var type: ItemType = .ios
    var categoryId: String = ""
    var devId: String = ""
    var price: Price = .all
    var order: Order = .added
    var query: String = ""

    private var currentPage: Int = 1
    private var allLoaded = false

    var items: [Item] = []

    private var filteredItems: [Item] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // Store the result from registerForPreviewing(with:sourceView:)
    var previewingContext: UIViewControllerPreviewing?

    // Called when 'See All' button is clicked
    convenience init(title: String, type: ItemType, category: String, price: Price, order: Order) {
        self.init(style: .plain)

        self.title = title
        self.type = type
        self.categoryId = category
        self.price = price
        self.order = order
    }

    // Called when 'See more from this dev/author' is clicked
    convenience init(title: String, type: ItemType, devId: String) {
        self.init(style: .plain)

        self.title = title
        self.type = type
        self.devId = devId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SeeAllCell.self, forCellReuseIdentifier: "seeallcell")
        tableView.register(SeeAllCell.self, forCellReuseIdentifier: "seeallcell_book")
        tableView.register(SeeAllCellWithStars.self, forCellReuseIdentifier: "seeallcellwithstars")
        tableView.register(SeeAllCellWithStars.self, forCellReuseIdentifier: "seeallcellwithstars_book")
        tableView.rowHeight = type == .books ? (130 ~~ 110) : (105 ~~ 85)

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

        setupFiltersButton()

        // Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        switch type {
        case .ios: searchController.searchBar.placeholder = "Search iOS Apps".localized()
        case .cydia: searchController.searchBar.placeholder = "Search Custom Apps".localized()
        case .books: searchController.searchBar.placeholder = "Search Books".localized()
        default: break
        }
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
            self?.currentPage = 1
            self?.items = []
            self?.loadContent()
        }

        setFooter()

        // Begin refresh
        tableView.spr_beginRefreshing()
    }

    fileprivate func setupFiltersButton() {
        if #available(iOS 14.0, *) {

            func load() {
                currentPage = 1
                items = []
                loadContent()
            }

            let filtersButton = UIBarButtonItem(
                image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: nil
            )

            let orderActions: [UIAction] = Order.allCases.map { order in
                UIAction(title: order.pretty, image: UIImage(systemName: order.associatedImage)) { _ in
                    self.order = order
                    load()
                }
            }
            let orderMenu = UIMenu(options: .displayInline, children: orderActions)

            if type == .ios {
                let priceActions: [UIAction] = Price.allCases.map { price in
                    UIAction(title: price.pretty, image: UIImage(systemName: price.associatedImage)) { _ in
                        self.price = price
                        load()
                    }
                }
                let priceMenu = UIMenu(options: .displayInline, children: priceActions)
                filtersButton.menu = UIMenu(children: [orderMenu, priceMenu])
            } else {
                filtersButton.menu = UIMenu(children: [orderMenu])
            }
            navigationItem.rightBarButtonItem = filtersButton
        }
    }

    // Called when user reaches bottom, loads 25 more
    private func setFooter() {
        tableView.spr_setIndicatorFooter { [weak self] in
            self?.currentPage += 1
            self?.loadContent()
        }
    }

    private func loadContent() {
        // If the data is all loaded, the footer has been removed (spr_endRefreshingWithNoMoreData)
        // But if this func gets called via indicator header refresh, only the first 25 items will be shown
        // so we need to readd the footer, as well as setting 'allLoaded' to false
        if self.allLoaded {
            allLoaded = false
            setFooter()
        }

        switch self.type {
        case .ios: loadItems(type: App.self)
        case .cydia: loadItems(type: CydiaApp.self)
        case .books: loadItems(type: Book.self)
        default: break
        }
    }

    private func loadItems<T>(type: T.Type) where T: Item {
        API.search(type: type, order: order, price: price, genre: categoryId, dev: devId, page: currentPage, success: { [weak self] array in
            guard let self = self else { return }

            if array.isEmpty {
                self.tableView.spr_endRefreshingWithNoMoreData()
                self.allLoaded = true
            } else {
                self.items += array
                if self.items.count < 25 {
                    self.tableView.spr_endRefreshingWithNoMoreData()
                } else {
                    self.tableView.spr_endRefreshing()
                }
            }

            self.state = .done
        }, fail: { error in
            self.tableView.spr_endRefreshing()
            self.items = []
            self.tableView.reloadData()
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error, animated: false)
        })
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering() ? filteredItems.count : items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (isFiltering() ? filteredItems : items).indices.contains(indexPath.row) else { return UITableViewCell() }
        let item = isFiltering() ? filteredItems[indexPath.row] : items[indexPath.row]

        if let app = item as? App {
            if app.itemHasStars {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeallcellwithstars",
                                                               for: indexPath) as? SeeAllCellWithStars else { return UITableViewCell() }
                cell.configure(name: app.name, category: app.category?.name ?? "", version: app.version, iconUrl: app.image,
                               size: app.size, rating: app.numberOfStars, num: app.numberOfRating)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeallcell",
                                                               for: indexPath) as? SeeAllCell else { return UITableViewCell() }
                cell.configure(name: app.name, category: app.category?.name ?? "", version: app.version, iconUrl: app.image,
                               size: app.size)
                return cell
            }
        } else if let book = item as? Book {
            if book.itemHasStars {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeallcellwithstars_book",
                                                               for: indexPath) as? SeeAllCellWithStars else { return UITableViewCell() }
                cell.configure(name: book.name, author: book.author, language: book.language, categoryId: book.categoryId,
                               coverUrl: book.image, rating: book.numberOfStars, num: book.numberOfRating)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeallcell_book",
                                                               for: indexPath) as? SeeAllCell else { return UITableViewCell() }
                cell.configure(name: book.name, author: book.author, language: book.language, categoryId: book.categoryId, coverUrl: book.image)
                return cell
            }
        } else if let cydiaApp = item as? CydiaApp {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "seeallcell",
                                                           for: indexPath) as? SeeAllCell else { return UITableViewCell() }
            cell.configure(name: cydiaApp.name, categoryId: cydiaApp.categoryId, version: cydiaApp.version,
                           iconUrl: cydiaApp.image, tweaked: cydiaApp.isTweaked)
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = isFiltering() ? filteredItems[indexPath.row] : items[indexPath.row]
        let vc = Details(content: item)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension SeeAll: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    func searchBarIsEmpty() -> Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String) {
        if searchText.count <= 1 {
            filteredItems = items.filter({( item: Item) -> Bool in
                item.itemName.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        } else {
            query = searchText
            switch type {
            case .ios: quickSearch(type: App.self)
            case .cydia: quickSearch(type: CydiaApp.self)
            case .books: quickSearch(type: Book.self)
            default: break
            }
        }
    }

    func quickSearch<T>(type: T.Type) where T: Item {
        API.search(type: type, q: query, success: { [weak self] results in
            guard let self = self else { return }
            self.filteredItems = results
            self.tableView.reloadData()
        }, fail: { _ in })
    }

    func isFiltering() -> Bool {
        searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension SeeAll {

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = isFiltering() ? filteredItems[indexPath.row] : items[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { Details(content: item) })
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

extension SeeAll: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let tableView = previewingContext.sourceView as? UITableView else { return nil }
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let item = isFiltering() ? filteredItems[indexPath.row] : items[indexPath.row]
        let vc = Details(content: item)
        return vc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

// Allow 3D touch on search results when search controller is active
extension SeeAll: UISearchControllerDelegate {
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
