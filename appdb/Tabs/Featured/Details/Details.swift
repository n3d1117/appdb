//
//  Details.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import SafariServices
import TelemetryClient
import UnityAds

class Details: LoadingTableView {
    
    var adsInitialized: Bool = false
    var adsLoaded: Bool = false
    var currentInstallButton: RoundedButton?

    var content: Item!
    var descriptionCollapsed = true
    var changelogCollapsed = true
    var reviewCollapsedForIndexPath: [IndexPath: Bool] = [:]
    var indexForSegment: DetailsSelectedSegmentState = .details
    var versions: [Version] = []

    var header: [DetailsCell] = []
    var details: [DetailsCell] = []

    var loadedLinks = false {
        didSet { if loadedLinks, let segment = tableView.headerView(forSection: 1) as? DetailsSegmentControl {
            segment.setLinksEnabled(true)
        }}
    }

    // I'm declaring this here because i need its
    // reference later when i enable it
    var shareButton: UIBarButtonItem!

    // Properties for dynamic load
    var loadDynamically = false
    var dynamicType: ItemType = .ios
    var dynamicTrackid: String = ""

    // Init dynamically - fetch info from API
    convenience init(type: ItemType, trackid: String) {
        self.init(style: .plain)

        loadDynamically = true
        dynamicType = type
        dynamicTrackid = trackid
    }

    // Init with content (app, cydia app or book)
    convenience init(content: Item) {
        self.init(style: .plain)

        self.content = content
        loadDynamically = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        setUp()

        if !loadDynamically {
            initializeCells()
            getLinks()
        } else {
            state = .loading
            showsErrorButton = false
            fetchInfo(type: dynamicType, trackid: dynamicTrackid)
        }
        
        UnityAds.initialize(Global.adsId, testMode: Global.adsTestMode, initializationDelegate: self)
    }

    // MARK: - Share

    @objc func share(sender: UIBarButtonItem) {
        let urlString = "\(Global.mainSite)app/\(contentType.rawValue)/\(content.itemId)"
        guard let url = URL(string: urlString) else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: [SafariActivity()])
        if #available(iOS 11.0, *) {} else {
            activity.excludedActivityTypes = [.airDrop]
        }
        activity.popoverPresentationController?.barButtonItem = sender
        present(activity, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch indexForSegment {
        case .details, .reviews: return 3
        case .download: return 2 + (versions.isEmpty ? 1 : versions.count)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return header.count
        case 1: return 0
        default:
            switch indexForSegment {
            case .details: return details.count
            case .reviews: return content.itemReviews.count + 1
            case .download: return versions.isEmpty ? 1 : versions[section - 2].links.count
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return header[indexPath.row].height
        case 1: return 0
        default:
            switch indexForSegment {
            case .details: return details[indexPath.row].height
            case .reviews: return indexPath.row == content.itemReviews.count ? UITableView.automaticDimension : DetailsReview.height
            case .download:
                if versions.isEmpty { return DetailsDownloadEmptyCell.height }

                guard versions.indices.contains(indexPath.section - 2) else { return 0 }
                guard versions[indexPath.section - 2].links.indices.contains(indexPath.row) else { return 0 }

                let link = versions[indexPath.section - 2].links[indexPath.row]
                return link.cracker == link.uploader ? DetailsDownloadUnified.height : DetailsDownload.height
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return header[indexPath.row]
        case 1: return UITableViewCell()
        default:
            switch indexForSegment {
            case .details:
                // DetailsDescription and DetailsChangelog need to be dynamic to have smooth expand
                if details[indexPath.row] is DetailsDescription {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "description", for: indexPath) as? DetailsDescription {
                        cell.desc.collapsed = descriptionCollapsed
                        cell.configure(with: content.itemDescription)
                        cell.desc.delegated = self
                        details[indexPath.row] = cell // ugly but needed to update height correctly
                        return cell
                    } else { return UITableViewCell() }
                }
                if details[indexPath.row] is DetailsChangelog {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "changelog", for: indexPath) as? DetailsChangelog {
                        cell.desc.collapsed = changelogCollapsed
                        cell.configure(type: contentType, changelog: content.itemChangelog, updated: content.itemUpdatedDate)
                        cell.desc.delegated = self
                        details[indexPath.row] = cell // ugly but needed to update height correctly
                        return cell
                    } else { return UITableViewCell() }
                }
                // Otherwise, just return static cells
                return details[indexPath.row]
            case .reviews:
                if indexPath.row == content.itemReviews.count { return DetailsPublisher("Reviews are from Apple's iTunes Store ©".localized()) }
                if let cell = tableView.dequeueReusableCell(withIdentifier: "review", for: indexPath) as? DetailsReview {
                    cell.desc.collapsed = reviewCollapsedForIndexPath[indexPath] ?? true
                    cell.configure(with: content.itemReviews[indexPath.row])
                    cell.desc.delegated = self
                    return cell
                } else { return UITableViewCell() }
            case .download:
                if !versions.isEmpty {

                    guard versions.indices.contains(indexPath.section - 2) else { return UITableViewCell() }
                    guard versions[indexPath.section - 2].links.indices.contains(indexPath.row) else { return UITableViewCell() }

                    let link = versions[indexPath.section - 2].links[indexPath.row]
                    let shouldHideDisclosureIndicator = contentType == .books || link.hidden || link.host.hasSuffix(".onion")

                    if link.cracker == link.uploader {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "downloadUnified", for: indexPath) as? DetailsDownloadUnified else { return UITableViewCell() }
                        cell.accessoryType = shouldHideDisclosureIndicator ? .none : .disclosureIndicator
                        cell.configure(with: link, installEnabled: adsLoaded)
                        cell.button.addTarget(self, action: #selector(self.install), for: .touchUpInside)
                        return cell
                    } else {
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "download", for: indexPath) as? DetailsDownload else { return UITableViewCell() }
                        cell.accessoryType = shouldHideDisclosureIndicator ? .none : .disclosureIndicator
                        cell.configure(with: link, installEnabled: adsLoaded)
                        cell.button.addTarget(self, action: #selector(self.install), for: .touchUpInside)
                        return cell
                    }
                } else {
                    return DetailsDownloadEmptyCell("No links found.".localized())
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if state != .done { return nil }
        if section == 1 {
            return DetailsSegmentControl(itemsForSegmentedControl, state: indexForSegment, enabled: loadedLinks, delegate: self)
        }
        if section > 1, indexForSegment == .download, !versions.isEmpty {
            return DetailsVersionHeader(versions[section - 2].number, isLatest: versions[section - 2].number == content.itemVersion)
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if state != .done { return 0 }
        if section == 1 { return DetailsSegmentControl.height }
        if section > 1, indexForSegment == .download, !versions.isEmpty { return DetailsVersionHeader.height }
        return 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexForSegment == .download, indexPath.section > 1, contentType != .books {

            func openLink(rt: String, icon: String) {
                API.getPlainTextLink(rt: rt) { error, link in
                    if let error = error {
                        Messages.shared.showError(message: error.prettified)
                    } else if let link = link, let linkEncoded = link.urlEncoded, let iconEncoded = icon.urlEncoded {
                        UIApplication.shared.open(URL(string: "appdb-ios://?icon=\(iconEncoded)&url=\(linkEncoded)")!)
                    }
                }
            }

            let link = versions[indexPath.section - 2].links[indexPath.row]
            let isClickable = contentType != .books && !link.hidden && !link.host.hasSuffix(".onion")
            guard isClickable else { return }

            if link.isTicket {
                API.getRedirectionTicket(t: link.link) { [weak self] error, rt, wait in
                    guard let self = self else { return }
                    if let error = error {
                        Messages.shared.showError(message: error.prettified)
                    } else if let redirectionTicket = rt, let wait = wait {
                        if wait == 0 {
                            openLink(rt: redirectionTicket, icon: self.content.itemIconUrl)
                        } else {
                            Messages.shared.hideAll()
                            Messages.shared.showMinimal(message: "Waiting %@ seconds...".localizedFormat(String(wait)), iconStyle: .none, color: Color.darkMainTint, duration: .seconds(seconds: Double(wait)))
                            delay(Double(wait)) {
                                openLink(rt: redirectionTicket, icon: self.content.itemIconUrl)
                            }
                        }
                    }
                }
            } else {
                if let url = URL(string: link.link) {
                    let webVc = IPAWebViewController(delegate: self, url: url, appIcon: content.itemIconUrl)
                    let nav = IPAWebViewNavController(rootViewController: webVc)
                    present(nav, animated: true)
                } else {
                    Messages.shared.showError(message: "Error: malformed url".localized())
                }
            }
            return
        }

        guard let cell = details[indexPath.row] as? DetailsExternalLink else { return }
        if !cell.url.isEmpty, let url = URL(string: cell.url) {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: url)
                present(svc, animated: true)
            } else {
                UIApplication.shared.open(url)
            }
        } else if !cell.devId.isEmpty {
            let vc = SeeAll(title: cell.devName, type: contentType, devId: cell.devId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Install app
    
    @objc private func install(sender: RoundedButton) {
        currentInstallButton = sender
        UnityAds.show(self, placementId: "Interstitial_iOS", showDelegate: self)
    }

    private func actualInstall(sender: RoundedButton) {
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }

        if Preferences.deviceIsLinked {
            setButtonTitle("Requesting...")

            func install(_ additionalOptions: [AdditionalInstallationParameters: Any] = [:]) {
                                
                API.install(id: sender.linkId, type: self.contentType, additionalOptions: additionalOptions) { [weak self] error in
                    guard let self = self else { return }

                    if let error = error {
                        Messages.shared.showError(message: error.prettified, context: .viewController(self))
                        delay(0.3) {
                            setButtonTitle("Install")
                        }
                    } else {
                        setButtonTitle("Requested")

                        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }

                        Messages.shared.showSuccess(message: "Installation has been queued to your device".localized(), context: .viewController(self))

                        if self.contentType != .books {
                            ObserveQueuedApps.shared.addApp(type: self.contentType, linkId: sender.linkId,
                                                            name: self.content.itemName, image: self.content.itemIconUrl,
                                                            bundleId: self.content.itemBundleId)
                        }

                        delay(5) {
                            setButtonTitle("Install")
                        }
                    }
                }
            }

            if Preferences.askForInstallationOptions {
                let vc = AdditionalInstallOptionsViewController()
                let nav = AdditionalInstallOptionsNavController(rootViewController: vc)

                vc.heightDelegate = nav

                let segue = Messages.shared.generateModalSegue(vc: nav, source: self, trackKeyboard: true)

                delay(0.3) {
                    segue.perform()
                }

                // If vc.cancelled is true, modal was dismissed either through 'Cancel' button or background tap
                segue.eventListeners.append { event in
                    if case .didHide = event, vc.cancelled {
                        setButtonTitle("Install")
                    }
                }

                vc.onCompletion = { (patchIap: Bool, enableGameTrainer: Bool, removePlugins: Bool, enablePushNotifications: Bool, duplicateApp: Bool, newId: String, newName: String) in
                    var additionalOptions: [AdditionalInstallationParameters: Any] = [:]
                    if patchIap { additionalOptions[.inApp] = 1 }
                    if enableGameTrainer { additionalOptions[.trainer] = 1 }
                    if removePlugins { additionalOptions[.removePlugins] = 1 }
                    if enablePushNotifications { additionalOptions[.pushNotifications] = 1 }
                    if duplicateApp && !newId.isEmpty { additionalOptions[.alongside] = newId }
                    if !newName.isEmpty { additionalOptions[.name] = newName }
                    install(additionalOptions)
                }
            } else {
                install()
            }
        } else {
            setButtonTitle("Checking...")
            delay(0.3) {
                Messages.shared.showError(message: "Please authorize app from Settings first".localized(), context: .viewController(self))
                setButtonTitle("Install")
            }
        }
    }

    // MARK: - Report link with reason

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexForSegment == .download && Preferences.deviceIsLinked && !versions.isEmpty
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .normal, title: "Report".localized()) { _, _ in
            let id = self.versions[indexPath.section - 2].links[indexPath.row].id
            self.showReportAlert(id)
        }
        report.backgroundColor = .red
        return [report]
    }

    func showReportAlert(_ id: String) {
        let alert = UIAlertController(title: "Report".localized(), message: "Reporting a broken link for '%@'.".localizedFormat(content.itemName), preferredStyle: .alert, adaptive: true)

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter a reason for your report".localized()
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            //textField.addTarget(self, action: #selector(self.reportTextfieldTextChanged), for: .editingChanged)
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let reportAction = UIAlertAction(title: "Send".localized(), style: .destructive, handler: { _ in
            if let textField = alert.textFields?.first, let text = textField.text {
                API.reportLink(id: id, type: self.contentType, reason: text, completion: { [weak self] error in
                    guard let self = self else { return }

                    if let error = error {
                        Messages.shared.showError(message: error.prettified, context: .viewController(self))
                    } else {
                        Messages.shared.showSuccess(message: "Link reported successfully!".localized(), context: .viewController(self))
                    }
                })
            }
        })

        alert.addAction(reportAction)
        //reportAction.isEnabled = false

        self.present(alert, animated: true)
    }

    // Only enable button if text is not empty
    /*@objc func reportTextfieldTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            (alert.actions[1] as UIAlertAction).isEnabled = !(sender.text ?? "").isEmpty
        }
    }*/
}

////////////////////////////////
//  PROTOCOL IMPLEMENTATIONS  //
////////////////////////////////

//
// MARK: - SwitchDetailsSegmentDelegate
//   Handle Details segment index change
//
extension Details: SwitchDetailsSegmentDelegate {
    func segmentSelected(_ state: DetailsSelectedSegmentState) {
        indexForSegment = state
        tableView.reloadData()
    }
}

/* OLD WAY, probably need to use this on ios 8
 UIView.setAnimationsEnabled(false)
 tableView.beginUpdates()
 tableView.endUpdates()
 UIView.setAnimationsEnabled(true)
 */

//
// MARK: - ElasticLabelDelegate
// Expand cell when 'more' button is pressed
//
extension Details: ElasticLabelDelegate {
    func expand(_ label: ElasticLabel) {
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            switch indexForSegment {
            case .details:
                if details[indexPath.row] is DetailsDescription { descriptionCollapsed = false } else if details[indexPath.row] is DetailsChangelog { changelogCollapsed = false }
            case .reviews: reviewCollapsedForIndexPath[indexPath] = false
            case .download: break
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

//
// MARK: - RelatedRedirectionDelegate
// Push related item view controller
//
extension Details: RelatedRedirectionDelegate {
    func relatedItemSelected(trackid: String) {
        let vc = Details(type: contentType, trackid: trackid)
        // navigationController?.navigationBar.isTranslucent = false /* God damnit, Apple */
        navigationController?.pushViewController(vc, animated: true)
    }
}

//
// MARK: - ScreenshotRedirectionDelegate
// Present Full screenshots view controller with given index
//
extension Details: ScreenshotRedirectionDelegate {
    func screenshotImageSelected(with index: Int, _ allLandscape: Bool, _ mixedClasses: Bool, _ magic: CGFloat) {
        let vc = DetailsFullScreenshots(content.itemScreenshots, index, allLandscape, mixedClasses, magic)
        let nav = DetailsFullScreenshotsNavController(rootViewController: vc)
        present(nav, animated: true)
    }
}

//
// MARK: - DynamicContentRedirection
//   Push details controller given type and trackid
//
extension Details: DynamicContentRedirection {
    func dynamicContentSelected(type: ItemType, id: String) {
        let vc = Details(type: type, trackid: id)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//
// MARK: - DetailsHeaderDelegate
// Push seeAll view controller when user taps seller button
//
extension Details: DetailsHeaderDelegate {
    func sellerSelected(title: String, type: ItemType, devId: String) {
        let vc = SeeAll(title: title, type: type, devId: devId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//
// MARK: - IPAWebViewControllerDelegate
// Show success message once download started
//
extension Details: IPAWebViewControllerDelegate {
    func didDismiss() {
        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        delay(0.8) {
            Messages.shared.showSuccess(message: "File download has started".localized(), context: .viewController(self))
            TelemetryManager.send(Global.Telemetry.downloadIpaRequested.rawValue)
        }
    }
}

// MARK: - Ads

extension Details: UnityAdsInitializationDelegate {
    func initializationComplete() {
        adsInitialized = true
        
        UnityAds.load("Interstitial_iOS", loadDelegate: self)
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        adsInitialized = false
    }
}

extension Details: UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        adsLoaded = true
        if indexForSegment == .download {
            tableView.reloadData()
        }
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        adsLoaded = true
        if indexForSegment == .download {
            tableView.reloadData()
        }
    }
}

extension Details: UnityAdsShowDelegate {
    
    func performActualInstall() {
        if currentInstallButton != nil {
            actualInstall(sender: currentInstallButton!)
            adsLoaded = false
            if indexForSegment == .download {
                tableView.reloadData()
            }
            UnityAds.load("Interstitial_iOS", loadDelegate: self)
        }
    }
    
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        performActualInstall()
    }
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        performActualInstall()
    }
    
    func unityAdsShowStart(_ placementId: String) {
        
    }
    
    func unityAdsShowClick(_ placementId: String) {
        
    }
}
