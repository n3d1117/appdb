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
    
    fileprivate var currentPage: Int = 1
    fileprivate var allLoaded: Bool = false
    
    var items: [Object] = []
    
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
        tableView.rowHeight = type == .books ? (130~~110) : (100~~80)
        
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
                self.tableView.spr_endRefreshing()
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
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard items.indices.contains(indexPath.row) else { return UITableViewCell() }
        let item = items[indexPath.row]
        
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
        let item = items[indexPath.row]
        let vc = Details(content: item)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - 3D Touch Peek and Pop

extension SeeAll: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let item = items[indexPath.row]
        let vc = Details(content: item)
        return vc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
