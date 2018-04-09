//
//  Settings.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Foundation
import UIKit
import Static

class Settings: TableViewController {
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        tableView.rowHeight = 50
        
        dataSource.sections = [
            Section(header: "ui", rows: [
                Row(text: "Dark Mode".localized(), accessory: .switchToggle(value: Themes.isNight) { newValue in
                    Themes.switchTo(theme: newValue ? .Dark : .Light)
                }, cellClass: SimpleStaticCell.self)
            ]),
            Section(header: "...", rows: [
                Row(text: "News".localized(), selection: { [unowned self] in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        ]
    }
    
    fileprivate func pushNews() {
        let newsViewController = News()
        if IS_IPAD {
            let nav = DismissableModalNavController(rootViewController: newsViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(newsViewController, animated: true)
        }
    }
}
