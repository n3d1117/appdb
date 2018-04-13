//
//  Settings.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Static
import BulletinBoard
import SafariServices

class Settings: TableViewController {
    
    lazy var bulletinManager: BulletinManager = {
        let rootItem: BulletinItem = DeviceLinkIntroBulletins.makeSelectorPage()
        let manager = BulletinManager(rootItem: rootItem)
        //todo add manual files and change property in BulletinManager.swift to automatically adapt to SwiftTheme
        manager.backgroundColor = .white
        return manager
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
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
            Section(header: "device", rows: [
                // todo localize
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
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
    
    // Push news controller
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
    
    // Device Link Bulletin intro
    // Also subscribes to notification requests to open Safari
    fileprivate func pushDeviceLink() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(openSafari(notification:)), name: .OpenSafari, object: nil)
        
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: tabBarController ?? self)
    }
    
    // Open Safari from given url via notification
    @objc fileprivate func openSafari(notification: Notification) {
        guard let urlString = notification.userInfo?["URLString"] as? String else { return }
        guard let url = URL(string: urlString) else { return }

        // NOTE: SVC causes all sorts of issues when presented from a bulletin
        // so let's just open Safari.app instead
        // 2lazy2fix
        
        UIApplication.shared.openURL(url)
        
        /*if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            bulletinManager.presentAboveBulletin(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }*/
    }
}
