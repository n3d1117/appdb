//
//  Search.swift
//  appdb
//
//  Created by ned on 17/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class Search: LoadingCollectionView {
    
    var cells: [SearchCell] = [] {
        didSet { if !cells.isEmpty {
            for cell in cells { collectionView?.register(type(of: cell), forCellWithReuseIdentifier: cell.identifier) }
            currentPhase = .loaded
        } }
    }
    
    var searchController = UISearchController()
    
    var currentPhase: Phase = .none {
        didSet { if currentPhase != oldValue {
            switch currentPhase {
            case .showTrending: break
                // switch to trending
            case .showSuggestions: break
                // switch to suggestions
            case .loading:
                // hide all
                state = .loading
            case .loaded:
                showAllElements()
                let offset = self.searchController.searchBar.frame.size.height + UIApplication.shared.statusBarFrame.height
                collectionView?.setContentOffset(CGPoint(x: 0, y: -offset), animated: false)
                state = .done
            default: break
            }
        } }
    }
    
    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        // Setup search bar
        self.title = "Search"
        
        let a = Amirite(style: .plain)
        
        searchController = UISearchController(searchResultsController: a)
        searchController.searchResultsUpdater = a
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search" //todo localize
        searchController.searchBar.scopeButtonTitles = ["iOS", "Cydia", "Book"] //todo localize
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            //Todo
        }
        
        // Enable search button even if search bar text is empty
        for view in searchController.searchBar.subviews {
            for subview in view.subviews {
                if subview is UITextField {
                    (subview as! UITextField).enablesReturnKeyAutomatically = false
                    break
                }
            }
        }
        
        /*delay(5.0) {
         self.hideTrending()
         self.currentPhase = .loading
         }*/
        
        
        /*self.searchAndUpdate("spotify", type: App.self)*/
        
    }
    
    // MARK: - Constraints
    
    func setConstraints() {
        guard let collectionView = collectionView else { return }
        constrain(collectionView) { collection in
            collection.edges == collection.superview!.edges
        }
    }
    
}

// MARK: - Collection view data source

extension Search: ETCollectionViewDelegateWaterfallLayout {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state == .done ? cells.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard state == .done, !cells.isEmpty else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath.row].identifier, for: indexPath)
        return cellDetection(cell, row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cells.indices.contains(indexPath.row) {
            return CGSize(width: itemWidth, height: cells[indexPath.row].height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
}

extension Search: UISearchBarDelegate {
    
    // todo delegate?
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let tmp = searchBar.text ?? ""
        searchController.isActive = false
        searchController.searchBar.text = tmp
        currentPhase = .loading
        // start search
        guard let amirite = searchController.searchResultsController as? Amirite else { return }
        switch amirite.type {
        case .ios: self.searchAndUpdate(tmp, type: App.self)
        case .cydia: self.searchAndUpdate(tmp, type: CydiaApp.self)
        case .books: self.searchAndUpdate(tmp, type: Book.self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let amirite = searchController.searchResultsController as? Amirite else { return }
        switch selectedScope {
        case 0: amirite.type = .ios
        case 1: amirite.type = .cydia
        case 2: amirite.type = .books
        default: break
        }
        amirite.reload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentPhase = .showTrending
    }
}




