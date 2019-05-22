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
        
        // If device was authorized before, linkDevice will succeed with any code given
        // So there's no need to ask the user to paste the code/enter email!
        // If it fails, just show the next item
        page.actionHandler = { item in
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            delay(0.3) {
                API.linkDevice(code: "anything", success: {
                    API.getConfiguration(success: {
                        let completionPage = DeviceLinkIntroBulletins.makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { _ in
                        item.manager?.displayNextItem()
                    })
                }, fail: { _ in
                    item.manager?.displayNextItem()
                })
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
            
            delay(0.4) {
                
                // Request device link with given code
                // On success, store link token & present completion bulletin
                // On error, present error bulletin and provide a link to retry
                
                API.linkDevice(code: code, success: {
                    
                    API.getConfiguration(success: {
                        let completionPage = self.makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { error in
                        let errorPage = self.makeErrorPage(with: error.prettified)
                        item.manager?.push(item: errorPage)
                    })
                    
                }, fail: { error in
                    let errorPage = self.makeErrorPage(with: error.prettified)
                    item.manager?.push(item: errorPage)
                })
            }
            
        }
        
        return page
        
    }
    
    static func makeEmailTextFieldPage() -> EnterEmailBulletinPage {
        
        let page = EnterEmailBulletinPage(title: "Enter Email".localized())
        page.isDismissable = true
        page.descriptionText = "Please enter your email address below and click Continue. You will be redirected to the Settings app where you can proceed with appdb profile installation.".localized()
        page.actionButtonTitle = "Continue".localized()
        page.appearance.titleFontSize = 25
        page.appearance.theme_actionButtonColor = Color.mainTint
        page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
        page.alternativeButtonTitle = "Go Back".localized()
        page.appearance.shouldUseCompactDescriptionText = true
        page.textInputHandler = { item, email in

            guard let email = email else { return }
            
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            
            API.linkNewDevice(email: email, success: {
                
                API.setConfiguration(params: [.appsync: "no"], success: {
                    API.getConfiguration(success: {
                        let completionPage = self.makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { error in
                        let errorPage = self.makeErrorPage(with: error.prettified)
                        item.manager?.push(item: errorPage)
                    })
                }, fail: { error in
                    let errorPage = self.makeErrorPage(with: error.prettified)
                    item.manager?.push(item: errorPage)
                })
                
            }, fail: { error in
                let errorPage = self.makeErrorPage(with: error.prettified)
                item.manager?.push(item: errorPage)
            })
            
        }
        
        return page
    }
    
    static func makeCompletionPage() -> BLTNPageItem {
        
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
    
    static func makeDeauthorizeConfirmationPage(action: @escaping () -> ()) -> BLTNPageItem {
        
        let page = DummyBulletinPage(title: "Deauthorization".localized())
        page.isDismissable = true
        page.descriptionText = "Are you sure you want to deauthorize this app from installing apps on your device?\n\nNOTE: This won't unlink your device from appdb. To do so, remove its profile in Settings -> General -> Profiles.".localized()
        page.actionButtonTitle = "Deauthorize".localized()
        page.alternativeButtonTitle = "Cancel".localized()
        page.appearance.titleFontSize = 25
        page.appearance.theme_actionButtonColor = Color.softRed
        page.appearance.theme_alternativeButtonTitleColor = Color.mainTint
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionHandler = { (item: BLTNActionItem) in
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            action()
            delay(0.7) {
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
        
        let page = DummyBulletinPage()
        page.shouldStartWithActivityIndicator = true
        page.image = #imageLiteral(resourceName: "completed") // just a placeholder, never actually displayed
        page.actionButtonTitle = ""
        page.presentationHandler = { item in
            item.manager?.displayActivityIndicator(color: Themes.isNight ? .white : .black)
            delay(0.8) {
                API.linkDevice(code: code, success: {
                    API.getConfiguration(success: {
                        let completionPage = DeviceLinkIntroBulletins.makeCompletionPage()
                        item.manager?.push(item: completionPage)
                    }, fail: { error in
                        let errorPage = self.makeErrorPage(with: error.prettified, displayBackButton: false)
                        item.manager?.push(item: errorPage)
                    })
                }, fail: { error in
                    let errorPage = self.makeErrorPage(with: error.prettified, displayBackButton: false)
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
