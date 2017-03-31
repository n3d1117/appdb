//
//  Details+Extension.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import Cartography

// Details cell template
class DetailsCell: UITableViewCell {
    
    var didSetupConstraints: Bool = false
    var type: ItemType = .ios
    var identifier: String { return "" }
    var height: CGFloat { return 0 }
    func setConstraints() {}
    
}

extension Details {
    
    // Returns content type
    var contentType: ItemType {
        if content is App { return .ios }
        if content is CydiaApp { return .cydia }
        if content is Book { return .books }
        return .ios
    }
    
    // Set up
    func setUp() {

        // Register cells
        for cell in header { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        for cell in details { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        //tableView.register(DetailsDownloadEmptyCell.self, forCellReuseIdentifier: "downloademptycell")
        tableView.register(DetailsReviewCell.self, forCellReuseIdentifier: "detailsreviewcell")
        tableView.register(DetailsDownloadCell.self, forCellReuseIdentifier: "detailsdownloadcell")
        
        // Add 'Dismiss' button for iPad
        if IS_IPAD {
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItem = dismissButton
        }
        
        // Hide separator for empty cells
        tableView.tableFooterView = UIView()
        
        // UI
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        tableView.separatorStyle = .none // Let's use self made separators instead
        
        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }

    }
    
    func dismissAnimated() { dismiss(animated: true) }
    
    // Helpers
    
    // Set header translucency on scroll
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let segment = tableView.headerView(forSection: 1) as? DetailsSegmentControl, indexForSegment != .download {
            if let header = header.first as? DetailsHeader, let nav = navigationController {
                let minOff: CGFloat = (nav.navigationBar.frame.height)~~(nav.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)
                segment.shouldBeTranslucent = (scrollView.contentOffset.y > header.height-minOff)
            }
        }
    }
    
    // Details/Reviews for details segment
    var itemsForSegmentedControl: [detailsSelectedSegmentState] {
        switch contentType {
            case .ios: if let app = content as? App {
                if !app.reviews.isEmpty { return  [.details, .reviews, .download] }
                return [.details, .download]
            }
            case .books: if let book = content as? Book {
                if !book.reviews.isEmpty { return [.details, .reviews, .download] }
                return [.details, .download]
            }
            default: break
        }; return [.details, .download]
    }
    
    //
    // Content Properties
    //
    var id: String {
        switch contentType {
        case .ios: if let app = content as? App { return app.id }
        case .cydia: if let cydiaApp = content as? CydiaApp { return cydiaApp.id }
        case .books: if let book = content as? Book { return book.id }
        }; return ""
    }
    
    var version: String {
        switch contentType {
        case .ios: if let app = content as? App { return app.version }
        case .cydia: if let cydiaApp = content as? CydiaApp { return cydiaApp.version }
        default: return ""
        }; return ""
    }
    
    var screenshots: [Screenshot] {
        switch contentType {
            case .ios: if let app = content as? App {
                if app.screenshotsIpad.isEmpty { return Array(app.screenshotsIphone) }
                if app.screenshotsIphone.isEmpty { return Array(app.screenshotsIpad) }
                return Array((app.screenshotsIpad~~app.screenshotsIphone))
            }
            case .cydia: if let cydiaApp = content as? CydiaApp {
                if cydiaApp.screenshotsIpad.isEmpty { return Array(cydiaApp.screenshotsIphone) }
                if cydiaApp.screenshotsIphone.isEmpty { return Array(cydiaApp.screenshotsIpad) }
                return Array((cydiaApp.screenshotsIpad~~cydiaApp.screenshotsIphone))
            }
            default: break
        }; return []
    }
    
    var relatedContent: [RelatedContent] {
        switch contentType {
            case .ios: if let app = content as? App { return Array(app.relatedApps) }
            case .books: if let book = content as? Book { return Array(book.relatedBooks) }
            default: break
        }; return []
    }
    
    var description_: String {
        switch contentType {
            case .ios: if let app = content as? App { return app.description_ }
            case .cydia: if let cydiaApp = content as? CydiaApp { return cydiaApp.description_ }
            case .books: if let book = content as? Book { return book.description_ }
        }; return ""
    }
    
    var changelog: String {
        switch contentType {
            case .ios: if let app = content as? App { return app.whatsnew }
            case .cydia: if let cydiaApp = content as? CydiaApp { return cydiaApp.whatsnew }
            default: break
        }; return ""
    }
    
    var updatedDate: String {
        switch contentType {
            case .ios: if let app = content as? App { return app.published }
            case .cydia: if let cydiaApp = content as? CydiaApp { return cydiaApp.updated }
            default: break
        }; return ""
    }
    
    var originalTrackid: String {
        if contentType == .cydia, let cydiaApp = content as? CydiaApp {
            return cydiaApp.originalTrackid
        }; return ""
    }
    
    var originalSection: String {
        if contentType == .cydia, let cydiaApp = content as? CydiaApp {
            return cydiaApp.originalSection
        }; return ""
    }
    
    var reviews: [Review] {
        switch contentType {
            case .ios: if let app = content as? App { return Array(app.reviews) }
            case .books: if let book = content as? Book { return Array(book.reviews) }
            default: break
        }; return []
    }
    
}
