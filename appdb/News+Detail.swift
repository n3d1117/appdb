//
//  News+Detail.swift
//  appdb
//
//  Created by ned on 16/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Foundation
import UIKit
import Kanna

class NewsDetail: LoadingTableView {
    
    fileprivate var item: SingleNews!
    var partialItem: SingleNews!
    
    fileprivate func decodeNews(from string: String) -> String {
        let newString: String =  string.replacingOccurrences(of: "</p>", with: "\n", options: .regularExpression, range: nil)
        do {
            return try HTML(html: newString, encoding: .utf8).text ?? ""
        } catch {
            return ""
        }
    }
    
    convenience init(with item: SingleNews) {
        self.init(style: .plain)
        self.partialItem = item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Todo register cells
        tableView.register(NewsDetailTitleDateCell.self, forCellReuseIdentifier: "titledatecell")
        tableView.register(NewsDetailHTMLCell.self, forCellReuseIdentifier: "htmlcell")

        if IS_IPAD {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
            // TODO add share button?
        }
        
        // Hide separator for empty cells
        tableView.tableFooterView = UIView()
        
        // UI
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        
        tableView.separatorStyle = .none
        
        showsErrorButton = false
        state = .loading
        
        guard let p = self.partialItem else { return }
        API.getNewsDetail(id: p.id, success: { result in
            self.item = result
            self.state = .done
        }, fail: { error in
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error.localizedDescription, animated: false)
        })
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state == .done ? 2 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard state == .done else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titledatecell", for: indexPath)
                as? NewsDetailTitleDateCell else { return UITableViewCell() }
            cell.title.text = item.title
            cell.date.text = item.added
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "htmlcell", for: indexPath)
                as? NewsDetailHTMLCell else { return UITableViewCell() }
            cell.htmlText.text = decodeNews(from: item.text)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard state == .done else { return 0 }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard state == .done else { return 0 }
        switch indexPath.row {
        case 0: return 90
        default: return 300
        }
    }
}
