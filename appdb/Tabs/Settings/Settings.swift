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
import BLTNBoard
import MessageUI
import TelemetryClient

class Settings: TableViewController {

    lazy var deviceLinkBulletinManager: BLTNItemManager = {
        let rootItem: BLTNItem = DeviceLinkIntroBulletins.makeSelectorPage()
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.theme_backgroundColor = Color.easyBulletinBackground
        if #available(iOS 10, *) {
            manager.backgroundViewStyle = .blurredDark
        }
        return manager
    }()

    lazy var deauthorizeBulletinManager: BLTNItemManager = {
        let rootItem: BLTNItem = DeviceLinkIntroBulletins.makeDeauthorizeConfirmationPage(action: {
            self.deauthorize()
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        })
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.theme_backgroundColor = Color.easyBulletinBackground
        if #available(iOS 10, *) {
            manager.backgroundViewStyle = .blurredDark
        }
        return manager
    }()

    var urlSchemeLinkCodeBulletinManager: BLTNItemManager?

    deinit { NotificationCenter.default.removeObserver(self) }

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings".localized()

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

        // Hide the 'Back' text on back button
        if #available(iOS 13.0, *) { } else {
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        dataSource = DataSource(tableViewDelegate: self)
        refreshSources()

        // Refresh link code & configuration parameters
        func reloadConfiguration() {
            if Preferences.deviceIsLinked {
                API.getLinkCode(success: {
                    API.getConfiguration(success: { [weak self] in
                        guard let self = self else { return }
                        self.refreshSources()
                    }, fail: { _ in })
                }, fail: { [weak self] error in
                    guard let self = self else { return }

                    // Profile has been removed, so let's deauthorize the app as well
                    if error == "NO_DEVICE_LINKED" {
                        self.deauthorize()
                    }

                    self.refreshSources()
                })
            } else {
                tableView.spr_endRefreshing()
            }
        }

        reloadConfiguration()

        // Refresh action
        tableView.spr_setIndicatorHeader {
            reloadConfiguration()
        }
    }

    // Deauthorize app (clean link code and token)
    func deauthorize() {
        Preferences.removeKeysOnDeauthorization()
        NotificationCenter.default.post(name: .Deauthorized, object: self)
        TelemetryManager.send(Global.Telemetry.deauthorized.rawValue)
    }

    // Show deauthorization bulletin
    func showDeauthorizeConfirmation() {
        deauthorizeBulletinManager.showBulletin(above: tabBarController ?? self)
    }

    func push(_ viewController: UIViewController) {

        // Set delegates for view controllers that require one
        if let themeChooser = viewController as? ThemeChooser {
            themeChooser.changedThemeDelegate = self
        } else if let languageChooser = viewController as? LanguageChooser {
            languageChooser.changedLanguageDelegate = self
        }

        // Show view controller
        if Global.isIpad {
            if (viewController is ThemeChooser || viewController is LanguageChooser || viewController is AdvancedOptions),
               #available(iOS 13.0, *) {
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                let nav = DismissableModalNavController(rootViewController: viewController)
                nav.modalPresentationStyle = .formSheet
                self.navigationController?.present(nav, animated: true)
            }
        } else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // Show contact developer options
    func contactDeveloper(indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: "Choose an option".localized(), preferredStyle: .actionSheet, adaptive: true)
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alertController.addAction(UIAlertAction(title: "Email".localized(), style: .default) { _ in
            self.selectEmail(indexPath: indexPath)
        })
        alertController.addAction(UIAlertAction(title: "Telegram", style: .default) { _ in
            self.openInSafari(Global.telegram)
        })
        alertController.addAction(UIAlertAction(title: "Buy me a coffee".localized(), style: .default) { _ in
            self.openInSafari(Global.donateSite)
        })
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = tableView
            popover.sourceRect = tableView.rectForRow(at: indexPath)
            popover.theme_backgroundColor = Color.popoverArrowColor
        }
        self.present(alertController, animated: true)
    }

    // Device Link Bulletin intro
    // Also subscribes to notification requests to open Safari
    func pushDeviceLink() {
        NotificationCenter.default.addObserver(self, selector: #selector(openSafari(notification:)), name: .OpenSafari, object: nil)
        deviceLinkBulletinManager.showBulletin(above: tabBarController ?? self)
    }

    // Opens Safari with given URL
    func openInSafari(_ url: String) {
        guard let url = URL(string: url) else { return }
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            present(svc, animated: true)
        } else {
            UIApplication.shared.open(url)
        }
    }

    // Open Safari from given url via notification
    @objc private func openSafari(notification: Notification) {
        guard let urlString = notification.userInfo?["URLString"] as? String else { return }
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url)

        /*if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            deviceLinkBulletinManager.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(url)
        }*/
    }

    // Get size of cache folder
    static func cacheFolderReadableSize() -> String {
        do {
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let cacheDirectorySize = try FileManager.default.sizeOfDirectory(at: cacheDirectory)
            return Global.humanReadableSize(bytes: Int64(cacheDirectorySize))
        } catch { return "" }
    }

    // Clear cache folder
    func clearCache(indexPath: IndexPath) {
        let title = "Are you sure you want to clear app cache?\n\nNOTE: This will not deauthorize the app, and your device will still be linked to appdb.".localized()
        let actionTitle = "Clear Cache".localized()
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet, adaptive: true)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .destructive) { _ in

            do {
                let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let cacheDirectoryContents = try FileManager.default.contentsOfDirectory(atPath: cacheDirectory.path)
                try cacheDirectoryContents.forEach {
                    try FileManager.default.removeItem(atPath: cacheDirectory.appendingPathComponent($0).path)
                }
                self.refreshSources()
                Messages.shared.showSuccess(message: "Cache cleared successfully!".localized())
                TelemetryManager.send(Global.Telemetry.clearedCache.rawValue)
            } catch let error {
                Messages.shared.showError(message: "Failed to clear cache: %@.".localizedFormat(error.localizedDescription))
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        if let presenter = alertController.popoverPresentationController {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = tableView
            presenter.sourceRect = tableView.rectForRow(at: indexPath)
            presenter.permittedArrowDirections = [.up, .down]
        }
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }

    // Reloads table view

    @objc func refreshSources() {
        if Preferences.deviceIsLinked {
            dataSource.sections = deviceLinkedSections
        } else {
            dataSource.sections = deviceNotLinkedSections
        }
        tableView.spr_endRefreshing()
    }
}

extension Settings {
    fileprivate func getNavControllerForText(_ text: String) -> UINavigationController? {
        switch text {
        case "Device".localized(): return UINavigationController(rootViewController: DeviceChooser())
        case "System Status".localized(): return UINavigationController(rootViewController: SystemStatus())
        case "Device Status".localized(): return UINavigationController(rootViewController: DeviceStatus())
        case "AltStore Repos".localized(): return UINavigationController(rootViewController: AltStoreRepos())
        case "Acknowledgements".localized(): return UINavigationController(rootViewController: Acknowledgements())
        case "Credits".localized(): return UINavigationController(rootViewController: Credits())
        case "Advanced Options".localized(): return UINavigationController(rootViewController: AdvancedOptions())
        case "News".localized():
            let news = News()
            news.isPeeking = true
            return UINavigationController(rootViewController: news)
        case "Choose Theme".localized():
            let vc = ThemeChooser()
            vc.changedThemeDelegate = self
            return UINavigationController(rootViewController: vc)
        case "Choose Language".localized():
            let vc = LanguageChooser()
            vc.changedLanguageDelegate = self
            return UINavigationController(rootViewController: vc)
        default: return nil
        }
    }
}

extension Settings: UITableViewDelegate {

    // Call contactDeveloper() on cell tap, I do this here because I need the indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ContactDevStaticCell {
            contactDeveloper(indexPath: indexPath)
        } else if tableView.cellForRow(at: indexPath) is ClearCacheStaticCell {
            clearCache(indexPath: indexPath)
        }
    }

    // iOS 13 Context Menus

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let row = dataSource.row(at: point) else { return nil }
        if let text = row.text, let navController = getNavControllerForText(text) {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: { navController })
        } else if row.copyAction != nil {
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
                UIMenu(title: "", children: [
                    UIAction(title: "Copy".localized(), image: UIImage(systemName: "doc.on.doc")) { _ in
                        row.copyAction?(row)
                    }
                ])
            }
        }
        return nil
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let nav = animator.previewViewController as? UINavigationController {
                self.push(nav.viewControllers[0])
            }
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
        return getNavControllerForText(row.text ?? "")
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

// MARK: - Changed Language protocol implementation

extension Settings: ChangedLanguage {
    func changedLanguage() {
        refreshSources()
    }
}

// MARK: - Link device from URL Scheme

extension Settings {
    func showlinkCodeFromURLSchemeBulletin(code: String) {
        let rootItem = DeviceLinkIntroBulletins.makeLinkCodeFromURLSchemePage(code: code)
        urlSchemeLinkCodeBulletinManager = BLTNItemManager(rootItem: rootItem)
        urlSchemeLinkCodeBulletinManager?.theme_backgroundColor = Color.easyBulletinBackground
        if #available(iOS 10, *) {
            urlSchemeLinkCodeBulletinManager?.backgroundViewStyle = .blurredDark
        }
        urlSchemeLinkCodeBulletinManager?.showBulletin(above: tabBarController ?? self)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension Settings: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    enum MailServices: String {
        case stock = "Mail"
        case spark = "Spark"
        case gmail = "Gmail"
        case yahoo = "Yahoo"
        case outlook = "Outlook"
    }

    func listMailServices() -> [MailServices] {

        var services = [MailServices]()

        if MFMailComposeViewController.canSendMail() {
            services.append(.stock)
        }
        if UIApplication.shared.canOpenURL(URL(string: "googlegmail://")!) {
            services.append(.gmail)
        }
        if UIApplication.shared.canOpenURL(URL(string: "readdle-spark://")!) {
            services.append(.spark)
        }
        if UIApplication.shared.canOpenURL(URL(string: "ymail://")!) {
            services.append(.yahoo)
        }
        if UIApplication.shared.canOpenURL(URL(string: "ms-outlook://")!) {
            services.append(.outlook)
        }

        return services
    }

    func compose(service: MailServices, subject: String, recipient: String) {
        switch service {
        case .stock:
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipient])
            mail.setSubject(subject.removingPercentEncoding ?? "")
            present(mail, animated: true)
        case .gmail:
            if let gmailUrl = URL(string: "googlegmail://co?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.open(gmailUrl)
            }
        case .spark:
            if let sparkUrl = URL(string: "readdle-spark://compose?subject=\(subject)&recipient=\(recipient)") {
                UIApplication.shared.open(sparkUrl)
            }
        case .yahoo:
            if let yahooUrl = URL(string: "ymail://mail/compose?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.open(yahooUrl)
            }
        case .outlook:
            if let outlookUrl = URL(string: "ms-outlook://compose?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.open(outlookUrl)
            }
        }
    }

    // Compose email to dev
    func selectEmail(indexPath: IndexPath) {

        let recipient = Global.email
        let subject = "appdb \(Global.appVersion) — Support"

        guard let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

        let services = listMailServices()

        if services.isEmpty {
            Messages.shared.showError(message: "Could not find email service.".localized())
        } else if services.count == 1, let service = services.first {
            compose(service: service, subject: subjectEncoded, recipient: recipient)
        } else {

            // Show mail options
            let alertController = UIAlertController(title: nil, message: "Select a service".localized(), preferredStyle: .actionSheet, adaptive: true)
            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

            for service in services {
                alertController.addAction(UIAlertAction(title: service.rawValue, style: .default) { _ in
                    self.compose(service: service, subject: subjectEncoded, recipient: recipient)
                })
            }
            if let popover = alertController.popoverPresentationController {
                popover.sourceView = tableView
                popover.sourceRect = tableView.rectForRow(at: indexPath)
                popover.theme_backgroundColor = Color.popoverArrowColor
            }
            self.present(alertController, animated: true)
        }
    }
}
