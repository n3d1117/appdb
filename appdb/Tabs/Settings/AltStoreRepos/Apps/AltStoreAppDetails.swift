//
//  AltStoreAppDetails.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import SafariServices
import TelemetryClient
import UnityAds

class AltStoreAppDetails: LoadingTableView {
    
    var adsInitialized: Bool = false
    var adsLoaded: Bool = !Global.showAds || Global.DEBUG || Preferences.isPlus
    var currentInstallButton: RoundedButton?

    var app: AltStoreApp!
    var descriptionCollapsed = true
    var changelogCollapsed = true

    var header: [DetailsCell] = []
    var details: [DetailsCell] = []

    // Init dynamically - fetch info from API
    convenience init(item: AltStoreApp) {
        self.init(style: .plain)
        self.app = item
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        setUp()
        initializeCells()
        
        if Global.showAds && !Global.DEBUG && !Preferences.isPlus {
            UnityAds.initialize(Global.adsId, testMode: Global.adsTestMode, initializationDelegate: self)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return header.count
        case 1: return 0
        default:
            return details.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return header[indexPath.row].height
        case 1: return 0
        default:
            return details[indexPath.row].height
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return header[indexPath.row]
        case 1: return UITableViewCell()
        default:
            if details[indexPath.row] is DetailsDescription {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "description", for: indexPath) as? DetailsDescription {
                    cell.desc.collapsed = descriptionCollapsed
                    cell.configure(with: app.description_)
                    cell.desc.delegated = self
                    details[indexPath.row] = cell // ugly but needed to update height correctly
                    return cell
                } else { return UITableViewCell() }
            }
            if details[indexPath.row] is DetailsChangelog {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "changelog", for: indexPath) as? DetailsChangelog {
                    cell.desc.collapsed = changelogCollapsed
                    cell.configure(type: .altstore, changelog: app.whatsnew, updated: app.updated)
                    cell.desc.delegated = self
                    details[indexPath.row] = cell // ugly but needed to update height correctly
                    return cell
                } else { return UITableViewCell() }
            }
            // Otherwise, just return static cells
            return details[indexPath.row]
        }
    }

    // MARK: - Install app

    @objc func install(sender: RoundedButton) {
        currentInstallButton = sender
        if !Global.showAds || Global.DEBUG || Preferences.isPlus {
            actualInstall(sender: currentInstallButton!)
        } else {
            UnityAds.show(self, placementId: "Interstitial_iOS", showDelegate: self)
        }
    }

    private func actualInstall(sender: RoundedButton) {
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }
        
        if Preferences.deviceIsLinked {
            setButtonTitle("Requesting...")

            func install(_ app: AltStoreApp, additionalOptions: [AdditionalInstallationParameters: Any] = [:]) {
                API.customInstall(ipaUrl: app.downloadURL, type: .altstore, iconUrl: app.image, bundleId: app.bundleId, name: app.name,  additionalOptions: additionalOptions) { [weak self] error in
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

                vc.onCompletion = { [weak self] (patchIap: Bool, enableGameTrainer: Bool, removePlugins: Bool, enablePushNotifications: Bool, duplicateApp: Bool, newId: String, newName: String, selectedDylibs: [String]) in
                    guard let self = self else { return }
                    var additionalOptions: [AdditionalInstallationParameters: Any] = [:]
                    if patchIap { additionalOptions[.inApp] = 1 }
                    if enableGameTrainer { additionalOptions[.trainer] = 1 }
                    if removePlugins { additionalOptions[.removePlugins] = 1 }
                    if enablePushNotifications { additionalOptions[.pushNotifications] = 1 }
                    if duplicateApp && !newId.isEmpty { additionalOptions[.alongside] = newId }
                    if !newName.isEmpty { additionalOptions[.name] = newName }
                    if !selectedDylibs.isEmpty { additionalOptions[.injectDylibs] = selectedDylibs }
                    install(self.app, additionalOptions: additionalOptions)
                }
            } else {
                install(self.app)
            }
        } else {
            setButtonTitle("Checking...")
            delay(0.3) {
                Messages.shared.showError(message: "Please authorize app from Settings first".localized(), context: .viewController(self))
                setButtonTitle("Install")
            }
        }
    }
}

////////////////////////////////
//  PROTOCOL IMPLEMENTATIONS  //
////////////////////////////////

//
// MARK: - ElasticLabelDelegate
// Expand cell when 'more' button is pressed
//
extension AltStoreAppDetails: ElasticLabelDelegate {
    func expand(_ label: ElasticLabel) {
        let point = label.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
            if details[indexPath.row] is DetailsDescription { descriptionCollapsed = false } else if details[indexPath.row] is DetailsChangelog { changelogCollapsed = false }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

//
// MARK: - ScreenshotRedirectionDelegate
// Present Full screenshots view controller with given index
//
extension AltStoreAppDetails: ScreenshotRedirectionDelegate {
    func screenshotImageSelected(with index: Int, _ allLandscape: Bool, _ mixedClasses: Bool, _ magic: CGFloat) {
        let vc = DetailsFullScreenshots(app.screenshots, index, allLandscape, mixedClasses, magic)
        let nav = DetailsFullScreenshotsNavController(rootViewController: vc)
        present(nav, animated: true)
    }
}


// MARK: - Ads

extension AltStoreAppDetails: UnityAdsInitializationDelegate {
    func initializationComplete() {
        adsInitialized = true
        
        if Global.showAds && !Global.DEBUG && !Preferences.isPlus {
            UnityAds.load("Interstitial_iOS", loadDelegate: self)
        }
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        adsInitialized = false
    }
}

extension AltStoreAppDetails: UnityAdsLoadDelegate {
    func enableInstallButton() {
        if let detailsHeader = header.first as? DetailsHeader, let installButton = detailsHeader.installButton {
            installButton.isEnabled = true
        }
    }
    
    func unityAdsAdLoaded(_ placementId: String) {
        adsLoaded = true
        enableInstallButton()
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        adsLoaded = false
        enableInstallButton()
    }
}

extension AltStoreAppDetails: UnityAdsShowDelegate {
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        if currentInstallButton != nil {
            actualInstall(sender: currentInstallButton!)
        }
    }
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        if currentInstallButton != nil {
            actualInstall(sender: currentInstallButton!)
        }
    }
    
    func unityAdsShowStart(_ placementId: String) {
        
    }
    
    func unityAdsShowClick(_ placementId: String) {
        
    }
}
