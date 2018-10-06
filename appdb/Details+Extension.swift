//
//  Details+Extension.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import RealmSwift
import UIKit
import Cartography
import ObjectMapper

// Details cell template
class DetailsCell: UITableViewCell {

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
        tableView.register(DetailsDescription.self, forCellReuseIdentifier: "description")
        tableView.register(DetailsChangelog.self, forCellReuseIdentifier: "changelog")
        tableView.register(DetailsReview.self, forCellReuseIdentifier: "review")
        tableView.register(DetailsDownload.self, forCellReuseIdentifier: "download")
        
        // Initialize 'Share' button
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
        shareButton.isEnabled = false
        
        if IS_IPAD {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton, shareButton]
        } else {
            self.navigationItem.rightBarButtonItems = [shareButton]
        }
        
        // Hide separator for empty cells
        tableView.tableFooterView = UIView()
        
        //Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        // UI
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        tableView.separatorStyle = .none // Let's use self made separators instead
        
        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }
        
        // Works around crazy cell bugs on rotation, enables preloading
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableView.automaticDimension

    }

    // Get content dynamically
    func getContent<T:Object>(type: T.Type, trackid: String, success:@escaping (_ item: T) -> Void) -> Void where T:Mappable, T:Meta {
        API.search(type: type, trackid: trackid, success: { items in
            if let item = items.first { success(item) }
            else { self.showErrorMessage(text: "Not found".localized(), secondaryText: "Couldn't find content with id %@ in our database".localizedFormat(trackid)) }
        }, fail: { error in
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error)
        })
    }
    
    func fetchInfo(type: ItemType, trackid: String) {
        switch type {
        case .ios:
            self.getContent(type: App.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        case .cydia:
            self.getContent(type: CydiaApp.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        case .books:
            self.getContent(type: Book.self, trackid: trackid, success: { item in
                self.content = item
                self.initializeCells()
                self.state = .done
                self.getLinks()
            })
        }
    }
    
    // Initialize cells
    func initializeCells() {
        header = [DetailsHeader(type: contentType, content: content, delegate: self)]
        
        details = [
            DetailsTweakedNotice(originalTrackId: content.itemOriginalTrackid, originalSection: content.itemOriginalSection, delegate: self),
            DetailsScreenshots(type: contentType, screenshots: content.itemScreenshots, delegate: self),
            DetailsDescription(), // dynamic
            DetailsChangelog(), // dynamic
            DetailsRelated(type: contentType, related: content.itemRelatedContent, delegate: self),
            DetailsInformation(type: contentType, content: content)
        ]
        
        switch contentType {
        case .ios: if let app = content as? App {
            details.append(DetailsExternalLink(text: "Developer Apps".localized(), devId: app.artistId, devName: app.seller))
            if !app.website.isEmpty { details.append(DetailsExternalLink(text: "Developer Website".localized(), url: content.itemWebsite)) }
            if !app.support.isEmpty { details.append(DetailsExternalLink(text: "Developer Support".localized(), url: content.itemSupport)) }
            if !app.publisher.isEmpty { details.append(DetailsPublisher(app.publisher)) }
            }
        case .cydia: if let app = content as? CydiaApp {
            details.append(DetailsPublisher("© " + app.developer))
            }
        case .books: if let book = content as? Book {
            details.append(DetailsExternalLink(text: "More by this author".localized(), devId: book.artistId, devName: book.author))
            if !book.publisher.isEmpty { details.append(DetailsPublisher(book.publisher)) }
            else if !book.author.isEmpty { details.append(DetailsPublisher("© " + book.author)) }
            }
        }
        shareButton.isEnabled = true
    }
    
    // Get links
    func getLinks() {
        API.getLinks(type: contentType, trackid: content.itemId, success: { items in
            self.versions = items
            
            // Ensure latest version is always at the top
            if let latest = self.versions.filter({$0.number==self.content.itemVersion}).first {
                if let index = self.versions.index(of: latest) {
                    self.versions.remove(at: index)
                    self.versions.insert(latest, at: 0)
                }
            }
            
            // Enable links segment
            self.loadedLinks = true
            
        }, fail: { _ in })
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
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
            case .books: if let book = content as? Book {
                if !book.reviews.isEmpty { return [.details, .reviews, .download] }
                return [.details, .download]
            }
            default: break
        }; return [.details, .download]
    }
}

// MARK: - 3D Touch Peek and Pop on icons
extension Details: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? DetailsRelated else { return nil }
        
        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(location, to: cell.collectionView)) else { return nil }
        guard cell.relatedContent.indices.contains(index.row) else { return nil }
        
        if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedApp {
            let iconRect = tableView.convert(collectionViewCell.icon.frame, from: collectionViewCell.icon.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = iconRect }
        } else if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedBook {
            let coverRect = tableView.convert(collectionViewCell.cover.frame, from: collectionViewCell.cover.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = coverRect }
        } else {
            return nil
        }
        
        let detailsViewController = Details(type: contentType, trackid: cell.relatedContent[index.row].id)
        return detailsViewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
