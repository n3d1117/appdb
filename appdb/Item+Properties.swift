//
//  Item+Properties.swift
//  appdb
//
//  Created by ned on 02/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import RealmSwift

//
// Content Properties
//
extension Object {
    
    var itemId: String {
        if let app = self as? App { return app.id }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.id }
        if let book = self as? Book { return book.id }
        return ""
    }
    
    var itemName: String {
        if let app = self as? App { return app.name.decoded }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.name.decoded }
        if let book = self as? Book { return book.name.decoded }
        return ""
    }
    
    var itemVersion: String {
        if let app = self as? App { return app.version }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.version }
        return ""
    }
    
    var itemBundleId: String {
        if let app = self as? App { return app.bundleId }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.bundleId }
        return ""
    }
    
    var itemScreenshots: [Screenshot] {
        if let app = self as? App {
            if app.screenshotsIpad.isEmpty { return Array(app.screenshotsIphone) }
            if app.screenshotsIphone.isEmpty { return Array(app.screenshotsIpad) }
            return Array((app.screenshotsIpad~~app.screenshotsIphone))
        }
        if let cydiaApp = self as? CydiaApp {
            if cydiaApp.screenshotsIpad.isEmpty { return Array(cydiaApp.screenshotsIphone) }
            if cydiaApp.screenshotsIphone.isEmpty { return Array(cydiaApp.screenshotsIpad) }
            return Array((cydiaApp.screenshotsIpad~~cydiaApp.screenshotsIphone))
        }
        return []
    }
    
    var itemScreenshotsIphone: [Screenshot] {
        if let app = self as? App { return Array(app.screenshotsIphone) }
        if let cydiaApp = self as? CydiaApp { return Array(cydiaApp.screenshotsIphone) }
        return []
    }
    
    var itemScreenshotsIpad: [Screenshot] {
        if let app = self as? App { return Array(app.screenshotsIpad) }
        if let cydiaApp = self as? CydiaApp { return Array(cydiaApp.screenshotsIpad) }
        return []
    }
    
    var itemCydiaCategoryId: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.categoryId }
        return ""
    }
    
    var itemRelatedContent: [RelatedContent] {
        if let book = self as? Book { return Array(book.relatedBooks) }
        return []
    }
    
    var itemDescription: String {
        if let app = self as? App { return app.description_ }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.description_ }
        if let book = self as? Book { return book.description_ }
        return ""
    }
    
    var itemChangelog: String {
        if let app = self as? App { return app.whatsnew }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.whatsnew }
        return ""
    }
    
    var itemUpdatedDate: String {
        if let app = self as? App { return app.published }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.updated }
        return ""
    }
    
    var itemOriginalTrackid: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.originalTrackid }
        return ""
    }
    
    var itemOriginalSection: String {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.originalSection }
        return ""
    }
    
    var itemReviews: [Review] {
        if let book = self as? Book { return Array(book.reviews) }
        return []
    }
    
    var itemWebsite: String {
        if let app = self as? App { return app.website }
        return ""
    }
    
    var itemSupport: String {
        if let app = self as? App { return app.support }
        return ""
    }
    
    var itemSeller: String {
        if let app = self as? App { return app.seller }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.developer }
        if let book = self as? Book { return book.author }
        return ""
    }
    
    var itemIconUrl: String {
        if let app = self as? App { return app.image }
        if let cydiaApp = self as? CydiaApp { return cydiaApp.image }
        if let book = self as? Book { return book.image }
        return ""
    }
    
    var itemFirstScreenshotUrl: String {
        return itemScreenshots.first?.image ?? ""
    }
    
    var itemFirstTwoScreenshotsUrls: [String] {
        guard itemScreenshots.count > 1 else { return [] }
        return [itemScreenshots[0].image, itemScreenshots[1].image]
    }
    
    var itemFirstThreeScreenshotsUrls: [String] {
        guard itemScreenshots.count > 2 else { return [] }
        return [itemScreenshots[0].image, itemScreenshots[1].image, itemScreenshots[2].image]
    }
    
    var itemIsTweaked: Bool {
        if let cydiaApp = self as? CydiaApp { return cydiaApp.isTweaked }
        return false
    }
    
    var itemHasStars: Bool {
        if let app = self as? App { return !app.numberOfStars.isZero && !app.numberOfRating.isEmpty }
        if let book = self as? Book { return !book.numberOfStars.isZero && !book.numberOfRating.isEmpty }
        return false
    }
    
    var itemNumberOfStars: Double {
        if let app = self as? App { return app.numberOfStars }
        if let book = self as? Book { return book.numberOfStars }
        return 0
    }
    
    var itemRating: String {
        if let app = self as? App { return app.numberOfRating }
        if let book = self as? Book { return book.numberOfRating }
        return ""
    }
}
