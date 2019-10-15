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

    var adChangeObservation: DefaultsObservation?

    deinit { NotificationCenter.default.removeObserver(self) }

    convenience init() {
        self.init(style: .grouped)
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
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem

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
            }
        }

        reloadConfiguration()
        adMobAdjustContentInsetsIfNeeded()

        // Refresh action
        tableView.spr_setIndicatorHeader {
            reloadConfiguration()
        }

        adChangeObservation = defaults.observe(.adBannerHeight) { [weak self] _ in
            guard let self = self else { return }
            self.adMobAdjustContentInsetsIfNeeded()
        }
    }

    // Deauthorize app (clean link code and token)
    func deauthorize() {
        Preferences.removeKeysOnDeauthorization()
        NotificationCenter.default.post(name: .Deauthorized, object: self)
    }

    // Show deauthorization bulletin
    func showDeauthorizeConfirmation() {
        deauthorizeBulletinManager.showBulletin(above: tabBarController ?? self)
    }

    // Push device status controller
    func pushDeviceStatus() {
        let deviceStatusController = DeviceStatus()

        delay(1) {
            let tabBarController: TabBarController? = (UIApplication.shared.keyWindow?.rootViewController ~~ self.tabBarController) as? TabBarController
            tabBarController?.showGADInterstitialIfReady()
        }

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
        let acknowledgementsViewController = Acknowledgements()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: acknowledgementsViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(acknowledgementsViewController, animated: true)
        }
    }

    // Push credits controller
    func pushCredits() {
        let credits = Credits()
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: credits)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(credits, animated: true)
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

    // Push language chooser controller
    func pushLanguageChooser() {
        let languageViewController = LanguageChooser()
        languageViewController.changedLanguageDelegate = self
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: languageViewController)
            nav.modalPresentationStyle = .formSheet
            self.navigationController?.present(nav, animated: true)
        } else {
            self.navigationController?.pushViewController(languageViewController, animated: true)
        }
    }

    // Show contact developer options
    func contactDeveloper(indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: "Choose an option".localized(), preferredStyle: .actionSheet, adaptive: true)
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        alertController.addAction(UIAlertAction(title: "Email".localized(), style: .default) { _ in
            self.selectEmail(indexPath: indexPath)
        })
        alertController.addAction(UIAlertAction(title: "Telegram".localized(), style: .default) { _ in
            self.openTelegramLink()
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

    // Opens link to contact dev
    func openTelegramLink() {
        let username = Global.telegramUsername
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
    }

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
    @objc private func openSafari(notification: Notification) {
        guard let urlString = notification.userInfo?["URLString"] as? String else { return }
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.openURL(url)

        /*if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            deviceLinkBulletinManager.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }*/
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

// MARK: - 3D Touch

extension Settings: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let row = dataSource.row(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        // Wrap it into a UINavigationController to see viewController's title on peek
        switch row.text {
        case "System Status".localized(): return UINavigationController(rootViewController: SystemStatus())
        case "Device Status".localized(): return UINavigationController(rootViewController: DeviceStatus())
        case "Acknowledgements".localized(): return UINavigationController(rootViewController: Acknowledgements())
        case "Credits".localized(): return UINavigationController(rootViewController: Credits())
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

// MARK: - Call contactDeveloper() on cell tap, I do this here because I need the indexPath

extension Settings: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ContactDevStaticCell {
            contactDeveloper(indexPath: indexPath)
        }
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
            mail.setSubject(subject)
            present(mail, animated: true)
        case .gmail:
            if let gmailUrl = URL(string: "googlegmail://co?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.openURL(gmailUrl)
            }
        case .spark:
            if let sparkUrl = URL(string: "readdle-spark://compose?subject=\(subject)&recipient=\(recipient)") {
                UIApplication.shared.openURL(sparkUrl)
            }
        case .yahoo:
            if let yahooUrl = URL(string: "ymail://mail/compose?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.openURL(yahooUrl)
            }
        case .outlook:
            if let outlookUrl = URL(string: "ms-outlook://compose?subject=\(subject)&to=\(recipient)") {
                UIApplication.shared.openURL(outlookUrl)
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
