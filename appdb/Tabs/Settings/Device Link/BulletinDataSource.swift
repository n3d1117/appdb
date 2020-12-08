//
//  BulletinDataSource.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BLTNBoard

enum DeviceLinkIntroBulletins {

    static func makeSelectorPage() -> SelectorBulletinPage {
        let page = SelectorBulletinPage(title: "Authorization".localized())
        page.isDismissable = true
        page.actionButtonTitle = "Continue".localized()
        page.appearance.titleFontSize = 23
        page.appearance.theme_actionButtonColor = Color.mainTint
        page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionHandler = { item in
            if page.deviceIsNotYetLinked {
                // If device is not yet linked to appdb there's not much I can do: just redirect
                // user to the web page where he can link it (APIs to link manually no longer work)
                let linkPageUrlString = "\(Global.mainSite)/link"
                NotificationCenter.default.post(name: .OpenSafari, object: self, userInfo: ["URLString": "\(linkPageUrlString)"])
            } else {
                // Otherwise, show page where user can enter link code as usual
                item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
                delay(0.2) {
                    item.manager?.displayNextItem()
                }
            }
        }

        return page
    }

    static func makeLinkCodeTextFieldPage() -> EnterLinkCodeBulletinPage {
        let page = EnterLinkCodeBulletinPage(title: "Enter Link Code".localized())
        page.isDismissable = true
        page.descriptionText = "Paste the 8 digits case sensitive link code you see on this page:".localized()
        page.actionButtonTitle = "Continue".localized()
        page.alternativeButtonTitle = "Go Back".localized()
        page.appearance.titleFontSize = 25
        page.appearance.theme_actionButtonColor = Color.mainTint
        page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
        page.appearance.shouldUseCompactDescriptionText = true

        page.textInputHandler = { item, linkCode in
            guard let code = linkCode else { return }

            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)

            delay(0.3) {
                // Request device link with given code
                // On success, store link token & present completion bulletin
                // On error, present error bulletin and provide a link to retry

                API.linkDevice(code: code, success: {
                    API.getConfiguration(success: {
                        let completionPage = makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { error in
                        let errorPage = makeErrorPage(with: error.prettified)
                        item.manager?.push(item: errorPage)
                    })
                }, fail: { error in
                    let errorPage = makeErrorPage(with: error.prettified)
                    item.manager?.push(item: errorPage)
                })
            }
        }

        return page
    }

    static func makeCompletionPage() -> BLTNPageItem {
        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        let page = DummyBulletinPage(title: "Success".localized())
        page.image = #imageLiteral(resourceName: "completed")
        page.appearance.theme_actionButtonColor = Color.softGreen
        page.appearance.theme_imageViewTintColor = Color.softGreen
        page.appearance.theme_actionButtonTitleColor = Color.invertedTitle
        page.appearance.titleFontSize = 25
        page.descriptionText = "Well done! This app is now authorized to install apps on your device.".localized()
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionButtonTitle = "Start using appdb!".localized()
        page.isDismissable = true

        NotificationCenter.default.post(name: .RefreshSettings, object: self)

        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }

        return page
    }

    static func makeErrorPage(with error: String, displayBackButton: Bool = true) -> BLTNPageItem {
        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.error) }
        let page = DummyBulletinPage(title: "Unable to complete".localized())
        page.image = #imageLiteral(resourceName: "error")
        page.appearance.theme_imageViewTintColor = Color.softRed
        page.appearance.titleFontSize = 25
        page.descriptionText = "An error has occurred".localized() + ":\n" + error
        page.appearance.shouldUseCompactDescriptionText = true
        page.isDismissable = true
        if displayBackButton {
            page.alternativeButtonTitle = "Go Back".localized()
            page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
            page.alternativeHandler = { item in
                item.manager?.popItem()
            }
        }

        return page
    }

    // MARK: - Deauthorization

    static func makeDeauthorizeConfirmationPage(action: @escaping () -> Void) -> BLTNPageItem {
        let page = DummyBulletinPage(title: "Deauthorization".localized())
        page.isDismissable = true
        page.descriptionText = "Are you sure you want to deauthorize this app from installing apps on your device?\n\nNOTE: This won't unlink your device from appdb. To do so, remove its profile in Settings -> General -> Profiles.".localized()
        page.actionButtonTitle = "Deauthorize".localized()
        page.alternativeButtonTitle = "Cancel".localized()
        page.appearance.titleFontSize = 25
        page.appearance.theme_actionButtonColor = Color.softRed
        page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionHandler = { item in
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            action()
            delay(0.4) {
                item.manager?.push(item: makeDeauthorizeCompletedPage())
            }
        }
        page.alternativeHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin(animated: true)
        }

        return page
    }

    static func makeDeauthorizeCompletedPage() -> BLTNPageItem {
        let page = DummyBulletinPage(title: "Deauthorized".localized())
        page.image = #imageLiteral(resourceName: "completed")
        page.appearance.theme_actionButtonColor = Color.softGreen
        page.appearance.theme_imageViewTintColor = Color.softGreen
        page.appearance.theme_actionButtonTitleColor = Color.invertedTitle
        page.appearance.titleFontSize = 25
        page.descriptionText = "App was deauthorized successfully.".localized()
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionButtonTitle = "Continue".localized()
        page.isDismissable = true

        NotificationCenter.default.post(name: .RefreshSettings, object: self)

        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }

        return page
    }

    // MARK: - link device from url scheme with given code

    static func makeLinkCodeFromURLSchemePage(code: String) -> BLTNPageItem {
        let page = DummyBulletinPage(title: "")
        page.shouldStartWithActivityIndicator = true
        page.image = #imageLiteral(resourceName: "completed") // just a placeholder, never actually displayed
        page.actionButtonTitle = ""
        page.presentationHandler = { item in
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            delay(0.6) {
                API.linkDevice(code: code, success: {
                    API.getConfiguration(success: {
                        let completionPage = makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { error in
                        let errorPage = makeErrorPage(with: error.prettified, displayBackButton: false)
                        item.manager?.push(item: errorPage)
                    })
                }, fail: { error in
                    let errorPage = makeErrorPage(with: error.prettified, displayBackButton: false)
                    item.manager?.push(item: errorPage)
                })
            }
        }

        return page
    }
}

// Workaround to set descriptionLabel's theme color for error/completion page
class DummyBulletinPage: BLTNPageItem {
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        descriptionLabel?.theme_textColor = Color.title
        return []
    }
}
