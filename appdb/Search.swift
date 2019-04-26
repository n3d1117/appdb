//
//  Search.swift
//  appdb
//
//  Created by ned on 16/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import ObjectMapper
import RealmSwift

class Search: LoadingCollectionView, UISearchBarDelegate {
    
    fileprivate var currentPage: Int = 1
    
    fileprivate var trendingItems: [String] = [] {
        didSet {
            if !trendingItems.isEmpty {
                self.collectionView.reloadData()
            }
        }
    }
    
    var searchController = UISearchController()
    
    var resultCells: [SearchCell] = [] {
        didSet {
            for cell in resultCells { collectionView.register(type(of: cell), forCellWithReuseIdentifier: cell.identifier) }
        }
    }
    
    var results: [Object] = []
    
    enum Phase {
        case showTrending, showResults, loading
    }
    
    var currentPhase: Phase = .showTrending
    
    var shouldIncreaseHeight: Bool {
        let type = InternalDeviceType.current
        return type == .iPhone4S || type == .iPhone5 || type == .iPhone5C || type == .iPhone5S
    }
    
    var trendingLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        var offset: CGFloat = 0
        if let nav = navigationController, let tab = tabBarController {
            offset = nav.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height + tab.tabBar.frame.height + 80
        }
        if shouldIncreaseHeight {
            offset -= 60
        }
        layout.itemSize = CGSize(width: view.bounds.width - (4~~3) * margin, height: view.bounds.height - offset)
        layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: topInset, right: 0)
        return layout
    }
    
    var resultsLayout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: topInset, left: margin, bottom: topInset, right: margin)
        if Global.isIpad {
            layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 2 : 3
        } else {
            layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 1 : 2
        }
        return layout
    }
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Search".localized()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = trendingLayout
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.register(TrendingCollectionViewCell.self, forCellWithReuseIdentifier: "trendingcell")

        // Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }

        // Add UISearchResultsUpdating
        let updateSuggestions = SuggestionsWhileTyping(style: .plain)
        updateSuggestions.searcherDelegate = self
        searchController = UISearchController(searchResultsController: updateSuggestions)
        searchController.searchResultsUpdater = updateSuggestions
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search iOS Apps".localized()
        searchController.searchBar.textField?.theme_textColor = Color.title
        searchController.searchBar.textField?.enablesReturnKeyAutomatically = false
        searchController.searchBar.textField?.theme_keyboardAppearance = [.light, .dark]
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            searchController.searchBar.scopeButtonTitles = ["iOS".localized(), "Cydia".localized(), "Books".localized()]
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            searchController.searchBar.barStyle = .default
            searchController.searchBar.searchBarStyle = .minimal
            searchController.searchBar.showsScopeBar = false
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.showsBookmarkButton = true
            searchController.searchBar.setImage(#imageLiteral(resourceName: "filter"), for: .bookmark, state: .normal)
            navigationItem.titleView = searchController.searchBar
        }
        
        setFooter()
        
        getTrending()
    }
    
    // Fetch trending apps
    
    func getTrending(type: ItemType = .ios) {
        API.getTrending(type: type, order: .day, maxResults: (12~~10), success: { results in
            self.trendingItems = results
        })
    }
    
    // Called when user reaches bottom, loads 25 more
    
    fileprivate func setFooter() {
        collectionView.spr_setIndicatorFooter { [weak self] in
            self?.currentPage += 1
            // start search
            guard let updateSuggestions = self?.searchController.searchResultsController as? SuggestionsWhileTyping else { return }
            guard let text = self?.searchController.searchBar.text else { return }
            guard let page = self?.currentPage else { return }
            switch updateSuggestions.type {
            case .ios: self?.searchAndUpdate(text, page: page, type: App.self)
            case .cydia: self?.searchAndUpdate(text, page: page, type: CydiaApp.self)
            case .books: self?.searchAndUpdate(text, page: page, type: Book.self)
            default: break
            }
        }
        collectionView.spr_endRefreshingWithNoMoreData()
    }
    
    // MARK: - Search bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        actuallySearch(with: text)
    }
    
    func actuallySearch(with text: String) {
        currentPage = 1
        searchController.isActive = false
        searchController.searchBar.text = text
        switchLayout(phase: .loading, reload: true)
        // start search
        guard let updateSuggestions = self.searchController.searchResultsController as? SuggestionsWhileTyping else { return }
        switch updateSuggestions.type {
            case .ios: self.searchAndUpdate(text, type: App.self)
            case .cydia: self.searchAndUpdate(text, type: CydiaApp.self)
            case .books: self.searchAndUpdate(text, type: Book.self)
            default: break
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if currentPhase != .showTrending {
            switchLayout(phase: .showTrending, reload: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let updateSuggestions = searchController.searchResultsController as? SuggestionsWhileTyping else { return }
        switch selectedScope {
            case 0:
                updateSuggestions.type = .ios
                searchController.searchBar.placeholder = "Search iOS Apps".localized()
            case 1:
                updateSuggestions.type = .cydia
                searchController.searchBar.placeholder = "Search Cydia Apps".localized()
            case 2:
                updateSuggestions.type = .books
                searchController.searchBar.placeholder = "Search Books".localized()
            default: break
        }
        getTrending(type: updateSuggestions.type)
        guard let text = searchBar.text, text.count > 1  else { return }
        updateSuggestions.reload()
    }
    
    // MARK: - Collection view delegate
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentPhase {
            case .showResults: return resultCells.count
            case .showTrending: return trendingItems.count > 0 ? 1 : 0
            case .loading: return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch currentPhase {
        case .showResults:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resultCells[indexPath.row].identifier, for: indexPath)
            (cell as? SearchCell)?.configure(with: results[indexPath.row])
            return cell
        case .showTrending:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingcell", for: indexPath)
            (cell as? TrendingCollectionViewCell)?.configure(with: trendingTitle(), delegate: self, tags: trendingItems)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    fileprivate func trendingTitle() -> String {
        guard let updateSuggestions = self.searchController.searchResultsController as? SuggestionsWhileTyping else { return "" }
        switch updateSuggestions.type {
        case .ios: return "Trending iOS Apps".localized().uppercased().replacingOccurrences(of: "IOS", with: "iOS")
        case .cydia: return "Trending Cydia Apps".localized().uppercased()
        case .books: return "Trending Books".localized().uppercased()
        default: return ""
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if results.indices.contains(indexPath.row), currentPhase == .showResults {
            pushDetailsController(with: results[indexPath.row])
        }
    }
    
    func switchLayout(phase: Phase, animated: Bool = false, reload: Bool = false) {
        currentPhase = phase
        
        if reload {
            collectionView.reloadData()
        }
        
        switch currentPhase {
        case .showTrending:
            state = .hideIndicator
            self.collectionView.collectionViewLayout.invalidateLayout()
            collectionView.collectionViewLayout = trendingLayout
        case .loading:
            state = .loading
            self.collectionView.collectionViewLayout.invalidateLayout()
            collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        case .showResults:
            self.collectionView.collectionViewLayout.invalidateLayout()
            collectionView.collectionViewLayout = resultsLayout
            state = .done(animated: animated)
        }
    }
    
    // Fix bug on iOS 11+ where the scroll indicator would follow first cell when scrolled up
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *), currentPhase == .showResults, let nav = navigationController {
            let minOff: CGFloat = -nav.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height - searchController.searchBar.frame.size.height
            collectionView.showsVerticalScrollIndicator = scrollView.contentOffset.y > minOff
        }
    }
}
