//
//  News.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

class News: LoadingTableView {

    private var numberOfNewsToBeDisplayed: Int = 50
    private var currentPage: Int = 1
    private var allNews: [SingleNews] = []
    private var displayedNews: [SingleNews] = []
    private var allLoaded: Bool = false
    private let arbitraryDelay: Double = 0.2

    var isPeeking: Bool = false

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    private var filteredNews: [SingleNews] = []
    private let searchController = UISearchController(searchResultsController: nil)

    // Store the result from registerForPreviewing(with:sourceView:)
    var previewingContext: UIViewControllerPreviewing?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "News".localized()

        tableView.register(SimpleStaticCell.self, forCellReuseIdentifier: "news")
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            previewingContext = registerForPreviewing(with: self, sourceView: tableView)
        }

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }

        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = "Search News".localized()
        searchController.searchBar.textField?.theme_textColor = Color.title
        searchController.searchBar.textField?.theme_keyboardAppearance = [.light, .dark, .dark]
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            // Fixes weird crash on peek
            if !isPeeking {
                navigationItem.searchController = searchController
            }
        } else {
            searchController.searchBar.barStyle = .default
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.showsScopeBar = false
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
        }

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.fetchNews()
        }

        // Load 25 more
        tableView.spr_setIndicatorFooter { [weak self] in
            self?.currentPage += 1
            self?.loadMoreNews()
        }

        tableView.spr_beginRefreshing()
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    private func fetchNews() {
        API.getNews(limit: 500, success: { [weak self] news in
            guard let self = self else { return }

            self.allNews = news
            self.loadNews()
        }, fail: { [weak self] error in
            guard let self = self else { return }

            self.tableView.spr_endRefreshing()
            self.displayedNews = []
            self.tableView.reloadData()
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error.localizedDescription, animated: false)
        })
    }

    private func loadNews() {
        self.displayedNews = Array(self.allNews.prefix(self.numberOfNewsToBeDisplayed * self.currentPage))

        delay(arbitraryDelay) {
            if self.allLoaded {
                self.tableView.spr_endRefreshingWithNoMoreData()
                self.allLoaded = false
            } else {
                self.tableView.spr_endRefreshing()
            }

            self.state = .done
        }
    }

    private func loadMoreNews() {
        allLoaded = currentPage * numberOfNewsToBeDisplayed > allNews.count
        loadNews()
    }

    // MARK: - Table View data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredNews.count : displayedNews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath) as? SimpleStaticCell {
            cell.textLabel?.text = isFiltering() ? filteredNews[indexPath.row].title : displayedNews[indexPath.row].title
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .disclosureIndicator
            cell.selectedBackgroundView = bgColorView
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = isFiltering() ? filteredNews[indexPath.row] : displayedNews[indexPath.row]
        guard !item.id.isEmpty else { return }
        let newsDetailViewController = NewsDetail(with: item.id)
        navigationController?.pushViewController(newsDetailViewController, animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension News: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterNewsForSearchText(searchController.searchBar.text!)
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterNewsForSearchText(_ searchText: String) {
        filteredNews = allNews.filter({( news: SingleNews) -> Bool in
            news.title.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - 3D Touch Peek and Pop

extension News: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let tableView = previewingContext.sourceView as? UITableView else { return nil }
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let item = isFiltering() ? filteredNews[indexPath.row] : displayedNews[indexPath.row]
        guard !item.id.isEmpty else { return nil }
        let newsDetailViewController = NewsDetail(with: item.id)
        return newsDetailViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

// Allow 3D touch on search results when search controller is active
extension News: UISearchControllerDelegate {
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
