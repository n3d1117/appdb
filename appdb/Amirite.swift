//
//  Amirite.swift
//  appdb
//
//  Created by ned on 16/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Cartography
import RealmSwift
import ObjectMapper

class Amirite: UITableViewController, UISearchResultsUpdating {
    
    var text: String!
    var results: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var type: ItemType = .ios
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray
        tableView.theme_separatorColor = Color.borderColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ida")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        searchController.searchBar.textField?.theme_textColor = Color.title
        if !text.isEmpty {
            self.text = text
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
            self.perform(#selector(self.reload), with: nil, afterDelay: 0.25)
        }
    }
    
    @objc func reload() {
        API.fastSearch(type: self.type, query: self.text, maxResults: 7, success: { results in
            self.results = results
        }, fail: { _ in })
    }
    
    /*func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked")
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let searchText = searchBar.text {
            print("Scoped changed: \(searchText) - selected scope: \(selectedScope)")
        }
    }*/
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ida", for: indexPath)
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.textLabel?.theme_textColor = Color.title
        cell.textLabel?.text = results[indexPath.row]
        //cell.highlight(text: text, normal: nil, highlight: [NSBackgroundColorAttributeName: .yellow], type: UILabel.self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("\(indexPath.row) selected")
    }
}
