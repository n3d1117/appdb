//
//  Details.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class Details: UITableViewController {
    
    var content: Object!
    var collapsedForIndexPath : [IndexPath: Bool] = [:]
    var heightForIndexPath : [IndexPath: CGFloat] = [:]
    var indexForSegment: detailsSelectedSegmentState = .details
    var versions: [Version] = []
    
    var header: [DetailsCell] = []
    var details: [DetailsCell] = []
    
    var loadedLinks: Bool = false {
        didSet { if loadedLinks, let segment = tableView.headerView(forSection: 1) as? DetailsSegmentControl {
            segment.setLinksEnabled(true)
        }}
    }
    
    // Init with content (app, cydia app or book)
    convenience init(content: Object) {
        self.init(style: .plain)
        
        self.content = content
        
        // Initialize the cells now that we know the type
        
        header = [DetailsHeader(type: contentType, content: content)]
        
        details = [
            DetailsTweakedNotice(originalTrackId: originalTrackid, originalSection: originalSection),
            DetailsScreenshots(type: contentType, screenshots: screenshots, delegate: self),
            DetailsDescription(description: description_, delegate: self),
            DetailsChangelog(type: contentType, changelog: changelog, updated: updatedDate, delegate: self),
            DetailsRelated(type: contentType, related: relatedContent),
            DetailsInformation(type: contentType, content: content)
        ]
        
        switch contentType {
        case .ios: if let app = content as? App {
                details.append(DetailsExternalLink(text: "Developer Apps"))
                if !app.website.isEmpty { details.append(DetailsExternalLink(text: "Developer Website")) }
                if !app.support.isEmpty { details.append(DetailsExternalLink(text: "Developer Support")) }
                if !app.publisher.isEmpty { details.append(DetailsPublisher(app.publisher)) }
            }
        case .cydia: if let app = content as? CydiaApp {
                details.append(DetailsPublisher("© " + app.developer))
            }
        case .books: if let book = content as? Book {
            details.append(DetailsExternalLink(text: "More by this author"))
                if !book.publisher.isEmpty { details.append(DetailsPublisher(book.publisher)) }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
        API.getLinks(type: contentType, trackid: id, success: { items in
            self.versions = items
            
            // Ensure latest version is always at the top
            if let latest = self.versions.filter({$0.number==self.version}).first {
                if let index = self.versions.index(of: latest) {
                    self.versions.remove(at: index); self.versions.insert(latest, at: 0)
                }
            }
            
            // Enable links segment
            self.loadedLinks = true
            
        }, fail: { error in print(error) })

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch indexForSegment {
            case .details, .reviews: return 2
            case .download: return 2 + (versions.isEmpty ? 1 : versions.count)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return header.count
            case 1:
                switch indexForSegment {
                    case .details: return details.count
                    case .reviews: return reviews.count
                    case .download: return 0
                }
            default:
                switch indexForSegment {
                    case .details, .reviews: return 0
                    case .download: return versions.isEmpty ? 1 : versions[section-2].links.count
                }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0: return header[indexPath.row].height
            case 1:
                switch indexForSegment {
                    case .details: return details[indexPath.row].height
                    case .reviews: return DetailsReviewCell.height
                    case .download: return 0
                }
            default:
                switch indexForSegment {
                    case .details, .reviews: return 0
                    case .download: return versions.isEmpty ? DetailsDownloadEmptyCell.height : DetailsDownloadCell.height
                }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0: return header[indexPath.row]
            case 1:
                switch indexForSegment {
                    case .details: return details[indexPath.row]
                    case .reviews:
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "detailsreviewcell", for: indexPath) as? DetailsReviewCell {
                            cell.configure(with: reviews[indexPath.row])
                            cell.desc.delegated = self
                            cell.desc.collapsed = collapsedForIndexPath[indexPath] ?? true
                            return cell
                        } else { return UITableViewCell() }
                    case .download: return UITableViewCell()
                }
            default:
                switch indexForSegment {
                    case .details, .reviews: return UITableViewCell()
                    case .download:
                        if !versions.isEmpty {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "detailsdownloadcell", for: indexPath) as! DetailsDownloadCell
                            cell.configure(with: versions[indexPath.section-2].links[indexPath.row])
                            return cell
                        } else {
                            return DetailsDownloadEmptyCell("No links found.")
                        }
                }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightForIndexPath[indexPath] = cell.frame.height
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForIndexPath[indexPath] ?? 120
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            return DetailsSegmentControl(itemsForSegmentedControl, state: indexForSegment, enabled: loadedLinks, delegate: self)
        }
        if section > 1, indexForSegment == .download, !versions.isEmpty {
            return DetailsVersionHeader(versions[section-2].number, isLatest: versions[section-2].number == version)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 { return DetailsSegmentControl.height }
        if section > 1, indexForSegment == .download, !versions.isEmpty { return DetailsVersionHeader.height }
        return 0
    }
    
}

////////////////////////////////
//                            //
//  PROTOCOL IMPLEMENTATIONS  //
//                            //
////////////////////////////////

//
//   MARK: - SwitchDetailsSegmentDelegate
//   Handle Details segment index change
//
extension Details: SwitchDetailsSegmentDelegate {
    func segmentSelected(_ state: detailsSelectedSegmentState) {
        indexForSegment = state
        tableView.reloadData()
    }
}

//
//   Expand cell when 'more' button is pressed
//
//   Can't reload smooth with reloadRows if cell is static, hence the switch :(
//   TODO workaround?
//
extension Details: ElasticLabelDelegate {
    func expand(_ label: ElasticLabel) {
        if label.collapsed {
            switch indexForSegment {
                case .details:
                    label.collapsed = false
                    UIView.setAnimationsEnabled(false)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                case .reviews:
                    let point = label.convert(CGPoint.zero, to: tableView)
                    if let indexPath = tableView.indexPathForRow(at: point) as IndexPath? {
                        collapsedForIndexPath[indexPath] = false
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                case .download: break
            }
        }
    }
}

//
//   MARK: - ScreenshotRedirectionDelegate
//   Present Full screenshots view controller with given index
//
extension Details: ScreenshotRedirectionDelegate {
    func screenshotImageSelected(with index: Int) {
        let vc = DetailsFullScreenshots(screenshots: screenshots, index: index)
        let nav = DetailsFullScreenshotsNavController(rootViewController: vc)
        present(nav, animated: true)
    }
}
