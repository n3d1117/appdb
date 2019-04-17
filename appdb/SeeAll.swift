//
//  SeeAll.swift
//  appdb
//
//  Created by ned on 21/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class SeeAll: LoadingTableView {
    
    var type: ItemType = .ios
    var categoryId: String = ""
    var devId: String = ""
    var price: Price = .all
    var order: Order = .added
    var query: String = ""
    
    fileprivate var currentPage: Int = 1
    fileprivate var allLoaded: Bool = false
    
    var items: [Object] = []
    
    fileprivate var filteredItems: [Object] = []
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
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
        tableView.rowHeight = type == .books ? (130~~110) : (105~~85)
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        
        animated = false
        showsErrorButton = false
        showsSpinner = false
        
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        // Search Controller
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        switch type {
            case .ios: searchController.searchBar.placeholder = "Search iOS Apps".localized()
            case .cydia: searchController.searchBar.placeholder = "Search Cydia Apps".localized()
            case .books: searchController.searchBar.placeholder = "Search Books".localized()
        }
        searchController.searchBar.textField?.theme_textColor = Color.title
        searchController.searchBar.textField?.theme_keyboardAppearance = [.light, .dark]
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
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }
        
        // Refresh action
        tableView.spr_setIndicatorHeader{ [weak self] in
            self?.currentPage = 1
            self?.items = []
            self?.loadContent()
        }
        
        setFooter()
        
        // Begin refresh
        tableView.spr_beginRefreshing()
    }
    
    // Called when user reaches bottom, loads 25 more
    fileprivate func setFooter() {
        tableView.spr_setIndicatorFooter{ [weak self] in
            self?.currentPage += 1
            self?.loadContent()
        }
    }
    
    fileprivate func loadContent() {
        
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
        }
    }
    
    fileprivate func loadItems<T:Object>(type: T.Type) -> Void where T:Mappable, T:Meta {
        API.search(type: type, order: order, price: price, genre: categoryId, dev: devId, page: currentPage, success: { array in
            
            if array.isEmpty {
                self.tableView.spr_endRefreshingWithNoMoreData()
                self.allLoaded = true
            } else {
                self.items = self.items + array
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
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error, animated: false)
        })
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredItems.count : items.count
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
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.count <= 1 {
            filteredItems = items.filter({( item: Object) -> Bool in
                return item.itemName.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        } else {
            query = searchText
            switch type {
                case .ios: quickSearch(type: App.self)
                case .cydia: quickSearch(type: CydiaApp.self)
                case .books: quickSearch(type: Book.self)
            }
        }
    }
    
    func quickSearch<T:Object>(type: T.Type) -> Void where T:Mappable, T:Meta {
        API.search(type: type, q: query, success: { results in
            self.filteredItems = results
            self.tableView.reloadData()
        }, fail: { _ in })
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - 3D Touch Peek and Pop

extension SeeAll: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
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
