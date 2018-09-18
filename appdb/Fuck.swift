//
//  Fuck.swift
//  appdb
//
//  Created by ned on 16/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Cartography

extension UISearchBar {
    var textField: UITextField? {
        for subview in subviews.first?.subviews ?? [] {
            if let textField = subview as? UITextField {
                return textField
            }
        }
        return nil
    }
}

class Fuck: UITableViewController, UISearchBarDelegate {
    
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor
        
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
            
            //if let nav = navigationController?.navigationBar { nav.hideBottomHairline() }
            //UISearchBar.appearance().barTintColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 249.0/255.0, alpha: 1.0)
            //UISearchBar.appearance().theme_tintColor = Color.mainTint
            searchController.searchBar.theme_barStyle = [.default, .black]

            searchController.searchBar.searchBarStyle = .prominent
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    // todo delegate?
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let tmp = searchBar.text ?? ""
        searchController.isActive = false
        searchController.searchBar.text = tmp
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.textLabel?.theme_textColor = Color.title
        cell.textLabel?.text = "trending cell"
        return cell
    }
    
}
