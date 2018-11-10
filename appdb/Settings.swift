//
//  Settings.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Static
import SafariServices
import RealmSwift
import BLTNBoard

class Settings: TableViewController {
    
    lazy var bulletinManager: BLTNItemManager = {
        let rootItem: BLTNItem = DeviceLinkIntroBulletins.makeSelectorPage()
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.theme_backgroundColor = Color.easyBulletinBackground
        if #available(iOS 10, *) {
            manager.backgroundViewStyle = .blurredDark
        }
        return manager
    }()
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        tableView.rowHeight = 50
        
        // Subscribe to notifications for device linked/unlinked so i can refresh sections
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSources), name: .RefreshSettings, object: nil)
        
        // Register for 3d Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        refreshSources()
        
        // Refresh link code & configuration parameters
        if DeviceInfo.deviceIsLinked {
            API.getLinkCode(success: {
                API.getConfiguration(success: { [unowned self] in
                    self.refreshSources()
                }) { _ in }
            }) { error in
                // Profile has been removed, so let's deauthorize the app as well
                if error == "NO_DEVICE_LINKED" { self.deauthorize() }
            }
        }
    }
    
    // Deauthorize app (clean link code, token & refresh settings)
    func deauthorize() {
        let realm = try! Realm()
        guard let pref = realm.objects(Preferences.self).first else { return }
        try! realm.write {
            pref.token = ""
            pref.linkCode = ""
        }
        NotificationCenter.default.post(name: .RefreshSettings, object: self)
    }
    
    // Push news controller
    func pushDeviceStatus() {
        let deviceStatusController = DeviceStatus()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: deviceStatusController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(deviceStatusController, animated: true)
        }
    }
    
    // Push news controller
    func pushNews() {
        let newsViewController = News()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: newsViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(newsViewController, animated: true)
        }
    }
    
    // Push acknowledgements controller
    func pushAcknowledgements() {
        let statusViewController = Acknowledgements()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: statusViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(statusViewController, animated: true)
        }
    }
    
    // Push system status controller
    func pushSystemStatus() {
        let statusViewController = SystemStatus()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: statusViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(statusViewController, animated: true)
        }
    }
    
    // Push theme chooser controller
    func pushThemeChooser() {
        let themeViewController = ThemeChooser()
        themeViewController.changedThemeDelegate = self
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: themeViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(themeViewController, animated: true)
        }
    }
    
    // Device Link Bulletin intro
    // Also subscribes to notification requests to open Safari
    func pushDeviceLink() {
        NotificationCenter.default.addObserver(self, selector: #selector(openSafari(notification:)), name: .OpenSafari, object: nil)
        bulletinManager.showBulletin(above: tabBarController ?? self)
    }
    
    // Opens link to contact dev
    /*func openTelegramLink() {
        let username = "MY_TG_USERNAME"
        let link = "tg://resolve?domain=\(username)"
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        } else if let url = URL(string: "https://t.me/\(username)") {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }*/
    
    // Opens Safari with given URL
    func openInSafari(_ url: String) {
        guard let url = URL(string: url) else { return }
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // Open Safari from given url via notification
    @objc fileprivate func openSafari(notification: Notification) {
        guard let urlString = notification.userInfo?["URLString"] as? String else { return }
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.openURL(url)
        
        /*if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            bulletinManager.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }*/
    }
    
    // Reloads table view
    
    @objc func refreshSources() {
        if DeviceInfo.deviceIsLinked {
            dataSource.sections = deviceLinkedSections
        } else {
            dataSource.sections = deviceNotLinkedSections
        }
    }
}

// MARK: - 3D Touch

extension Settings: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let row = dataSource.row(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        
        // Wrap it into a UINavigationController to see viewController's title on peek
        switch row.text {
            case "System Status".localized(): return UINavigationController(rootViewController: SystemStatus())
            case "News".localized(): return UINavigationController(rootViewController: News())
            case "Device Status".localized(): return UINavigationController(rootViewController: DeviceStatus())
            default: return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Unwrap it when committing, to make sure it show back button and everything navigation-related
        if let view = (viewControllerToCommit as? UINavigationController)?.viewControllers.first {
            show(view, sender: self)
        }
    }
}

// MARK: - Changed Theme protocol implementation

extension Settings: ChangedTheme {
    func changedTheme() {
        refreshSources()
    }
}
