//
//  BulletinDataSource.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BulletinBoard

// todo make it all work with swifttheme

enum DeviceLinkIntroBulletins {
    
    static func makeSelectorPage() -> SelectorBulletinPage {
        let page = SelectorBulletinPage(title: "Authorization".localized())
        page.isDismissable = true
        page.image = #imageLiteral(resourceName: "mdm_installed")
        page.descriptionText = "Is your device already linked to appdb? You can check if you have appdb profile installed at Settings -> General -> Profiles.".localized()
        page.actionButtonTitle = "Continue".localized()
        page.appearance.titleFontSize = 27
        page.appearance.actionButtonColor = Color.mainTint.value() as! UIColor // TODO FIX
        page.appearance.alternativeButtonColor = page.appearance.actionButtonColor
        page.appearance.shouldUseCompactDescriptionText = true
        return page
    }
    
    static func makeLinkCodeTextFieldPage() -> EnterLinkCodeBulletinPage {
        
        let page = EnterLinkCodeBulletinPage(title: "Enter Link Code".localized())
        page.isDismissable = true
        page.descriptionText = "Paste the 8 digits case sensitive link code you see on this page:".localized()
        page.actionButtonTitle = "Continue".localized()
        page.alternativeButtonTitle = "Go Back".localized()
        page.appearance.titleFontSize = 27
        page.appearance.actionButtonColor = Color.mainTint.value() as! UIColor
        page.appearance.shouldUseCompactDescriptionText = true

        page.textInputHandler = { item, linkCode in
            
            guard let code = linkCode else { return }
            
            item.manager?.displayActivityIndicator()
            
            delay(0.6) {
                
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
        page.descriptionText = "Please enter your email address below".localized()
        page.actionButtonTitle = "Continue".localized()
        page.appearance.titleFontSize = 27
        page.appearance.actionButtonColor = Color.mainTint.value() as! UIColor
        page.alternativeButtonTitle = "Go Back".localized()
        page.appearance.shouldUseCompactDescriptionText = true
        page.textInputHandler = { item, email in

            guard let email = email else { return }
            
            item.manager?.displayActivityIndicator()
            
            API.linkNewDevice(email: email, success: {
                
                API.setConfiguration(params: [.appsync: "no" , .ignoreCompatibility: "no", .askForOptions: "no"], success: {
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
        
        return page
    }
    
    static func makeCompletionPage() -> PageBulletinItem {
        
        let page = PageBulletinItem(title: "Success".localized())
        page.image = #imageLiteral(resourceName: "completed")
        page.appearance.actionButtonColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.appearance.titleFontSize = 27
        page.descriptionText = "Well done! This app is now authorized to install apps on your device.".localized()
        page.appearance.shouldUseCompactDescriptionText = true
        page.actionButtonTitle = "Start using appdb!".localized()
        page.isDismissable = true
        
        NotificationCenter.default.post(name: .RefreshSettings, object: self, userInfo: ["linked": true])
        
        page.actionHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        return page
        
    }
    
    static func makeErrorPage(with error: String) -> PageBulletinItem {
        
        let page = PageBulletinItem(title: "Unable to complete".localized())
        page.image = #imageLiteral(resourceName: "error")
        page.appearance.imageViewTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        page.appearance.actionButtonTitleColor = .white
        page.appearance.titleFontSize = 27
        page.descriptionText = "An error has occurred".localized() + ":\n" + error
        page.alternativeButtonTitle = "Go Back".localized()
        page.appearance.alternativeButtonColor = Color.mainTint.value() as! UIColor
        page.appearance.shouldUseCompactDescriptionText = true
        page.isDismissable = true
        page.alternativeHandler = { item in
            item.manager?.popItem()
        }
        
        return page
        
    }
    
}
