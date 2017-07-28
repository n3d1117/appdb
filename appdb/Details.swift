//
//  Details.swift
//  appdb
//
//  Created by ned on 19/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import RealmSwift

class Details: LoadingTableView {
    
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
    
    // Properties for dynamic load
    var loadDynamically: Bool = false
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
    convenience init(content: Object) {
        self.init(style: .plain)

        self.content = content
        loadDynamically = false
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        setUp()

        if !loadDynamically {
            initializeCells()
            getLinks()
        } else {
            state = .loading
            showsErrorButton = false
            fetchInfo(type: dynamicType, trackid: dynamicTrackid)
        }

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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if state != .done { return nil }
        if section == 1 {
            return DetailsSegmentControl(itemsForSegmentedControl, state: indexForSegment, enabled: loadedLinks, delegate: self)
        }
        if section > 1, indexForSegment == .download, !versions.isEmpty {
            return DetailsVersionHeader(versions[section-2].number, isLatest: versions[section-2].number == version)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if state != .done { return 0 }
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
//   MARK: - RelatedRedirectionDelegate
//   Push related item view controller
//
extension Details: RelatedRedirectionDelegate {
    func relatedItemSelected(trackid: String) {
        let vc = Details(type: contentType, trackid: trackid)
        navigationController?.navigationBar.isTranslucent = false /* God damnit, Apple */
        navigationController?.pushViewController(vc, animated: true)
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

//
//   MARK: - DynamicContentRedirection
//   Push details controller given type and trackid
//
extension Details: DynamicContentRedirection {
    func dynamicContentSelected(type: ItemType, id: String) {
        let vc = Details(type: type, trackid: id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
