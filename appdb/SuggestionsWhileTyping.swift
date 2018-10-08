//
//  SuggestionsWhileTyping.swift
//  appdb
//
//  Created by ned on 16/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Cartography
import RealmSwift
import ObjectMapper

protocol SearcherDelegate: class {
    func didClickSuggestion(_ text: String)
}

class SuggestionsWhileTyping: UITableViewController, UISearchResultsUpdating {
    
    var searcherDelegate: SearcherDelegate? = nil
    
    var text: String = ""
    var results: [String] = []
    
    var type: ItemType = .ios
    
    lazy var bgColorView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Color.cellSelectionColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray
        tableView.theme_separatorColor = Color.borderColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "suggestion")
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.count > 1 {
            self.text = text
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
            self.perform(#selector(self.reload), with: nil, afterDelay: 0.25)
        } else {
            if results.isEmpty {
                results = []
                tableView.reloadData()
            }
        }
    }
    
    @objc func reload() {
        API.fastSearch(type: self.type, query: self.text, maxResults: 7, success: { results in
            self.results = results
            self.tableView.reloadData()
        }, fail: { _ in })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestion", for: indexPath)
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.textLabel?.theme_textColor = Color.title
        if results.indices.contains(indexPath.row) {
            var result = results[indexPath.row]
            while result.hasPrefix(" ") { result = String(result.dropFirst()) }
            cell.textLabel?.text = result
        }
        cell.selectedBackgroundView = bgColorView
        //cell.highlight(text: text, normal: nil, highlight: [NSBackgroundColorAttributeName: .yellow], type: UILabel.self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searcherDelegate?.didClickSuggestion(results[indexPath.row])
    }
}
