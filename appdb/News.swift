//
//  News.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//


import UIKit

class News: LoadingTableView {

    fileprivate var numberOfNewsToBeDisplayed: Int = 50
    fileprivate var currentPage: Int = 1
    fileprivate var allNews: [SingleNews] = []
    fileprivate var displayedNews: [SingleNews] = []
    fileprivate var allLoaded: Bool = false
    fileprivate let arbitraryDelay: Double = 0.2
    
    fileprivate var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()
    
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
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        if IS_IPAD {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }
        
        // Refresh action
        tableView.spr_setIndicatorHeader{ [weak self] in
            self?.fetchNews()
        }
        
        // Load 25 more
        tableView.spr_setIndicatorFooter{ [weak self] in
            self?.currentPage += 1
            self?.loadMoreNews()
        }
        
        tableView.spr_beginRefreshing()
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    fileprivate func fetchNews() {
        API.getNews(limit: 500, success: { news in
            self.allNews = news
            self.loadNews()
        }, fail: { error in
            self.tableView.spr_endRefreshing()
            self.displayedNews = []
            self.tableView.reloadData()
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localizedDescription, animated: false)
        })
    }
    
    fileprivate func loadNews() {
        self.displayedNews = Array(self.allNews.prefix(self.numberOfNewsToBeDisplayed * self.currentPage))
        
        delay(arbitraryDelay) {
            if self.allLoaded {
                self.tableView.spr_endRefreshingWithNoMoreData()
                self.allLoaded = false // todo explain this
            } else {
                self.tableView.spr_endRefreshing()
            }
            
            self.state = .done
        }
    }
    
    fileprivate func loadMoreNews() {
        allLoaded = currentPage * numberOfNewsToBeDisplayed > allNews.count
        loadNews()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedNews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath) as? SimpleStaticCell {
            cell.textLabel?.text = displayedNews[indexPath.row].title
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .disclosureIndicator
            cell.selectedBackgroundView = bgColorView
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = displayedNews[indexPath.row]
        guard !item.id.isEmpty else { return }
        let newsDetailViewController = NewsDetail(with: item)
        navigationController?.pushViewController(newsDetailViewController, animated: true)
    }
}

// MARK: - 3D Touch Peek and Pop

extension News: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let item = displayedNews[indexPath.row]
        guard !item.id.isEmpty else { return nil }
        let newsDetailViewController = NewsDetail(with: item)
        return newsDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
