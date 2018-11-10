//
//  News+Detail.swift
//  appdb
//
//  Created by ned on 16/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//


import UIKit

class NewsDetail: LoadingTableView {
    
    fileprivate var item: SingleNews!
    var partialItem: SingleNews!
    
    convenience init(with item: SingleNews) {
        self.init(style: .plain)
        self.partialItem = item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Todo register cells
        tableView.register(NewsDetailTitleDateCell.self, forCellReuseIdentifier: "titledatecell")
        tableView.register(NewsDetailHTMLCell.self, forCellReuseIdentifier: "htmlcell")

        if Global.isIpad {
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
            cell.htmlText.transform(using: item.text)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard state == .done else { return 0 }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard state == .done else { return 0 }
        switch indexPath.row {
        case 0: return 90
        default: return 300
        }
    }
    
}

extension AttributedLabel {
    func transform(using text: String) {
        var counter = 0
        var isOrdered = false
        
        // Supports <ul>, <ol>, <li>, <p>, <br>
        let transformers: [TagTransformer] = [
            .brTransformer,
            TagTransformer(tagName: "ul", tagType: .start) { _ in
                isOrdered = false
                return ""
            },
            TagTransformer(tagName: "ol", tagType: .start) { _ in
                isOrdered = true
                return ""
            },
            TagTransformer(tagName: "li", tagType: .start) { _ in
                counter += 1
                return isOrdered ? "\(counter). " : "• "
            },
            TagTransformer(tagName: "li", tagType: .end) { _ in
                return "\n"
            },
            TagTransformer(tagName: "p", tagType: .end) { _ in
                return "\n"
            }
            
        ]
        // Supports <b>
        let b = Style("b").font(.boldSystemFont(ofSize: font.pointSize))
        
        // Supports <i>
        let i = Style("i").font(.italicSystemFont(ofSize: font.pointSize))
        
        // Supports <strong>
        let strong = Style("strong").font(.boldSystemFont(ofSize: font.pointSize))
        
        // Supports <u>
        let u = Style("u").underlineStyle(.single)
        
        let link = Style("a").foregroundColor(UIColor(rgba: "#446CB3"), .normal).foregroundColor(UIColor(rgba: "#486A92"), .highlighted)
            .underlineStyle(.single)
        
        attributedText = text.style(tags: [b, i, strong, u, link], transformers: transformers).styleLinks(link)
        onClick = { label, detection in
            switch detection.type {
            case .link(let url):
                var partialUrl = url.absoluteString.replacingOccurrences(of: "&amp;", with: "&")
                if !partialUrl.hasPrefix("http") { partialUrl = "http://" + partialUrl }
                guard let fullUrl = URL(string: partialUrl) else { return }
                UIApplication.shared.openURL(fullUrl)
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"] {
                    if href.hasPrefix("http") {
                        guard let url = URL(string: href.replacingOccurrences(of: "&amp;", with: "&")) else { return }
                        UIApplication.shared.openURL(url)
                    } else {
                        let urlString: String = "\(Global.mainSite)\(href)".replacingOccurrences(of: "&amp;", with: "&")
                        guard let url = URL(string: urlString) else { return }
                        UIApplication.shared.openURL(url)
                    }
                }
            default:
                break
            }
        }
    }
}
