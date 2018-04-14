//
//  Featured+Extension.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//


import UIKit

// Abstract cell, height
class FeaturedCell: UITableViewCell {
    var height: CGFloat {
        guard let id = Featured.CellType(rawValue: reuseIdentifier ?? "") else { return 0 }
        
        // iOS Height
        if Featured.iosTypes.contains(id) { return Global.size.heightIos.value + (45~~40) }
        
        // Books Height
        if id == .books { return Global.size.heightBooks.value + (45~~40) }
        return 0
    }
}

extension Featured {
    
    // Reuse identifiers
    enum CellType: String {
        case iosNew = "ios_new"
        case iosPopular = "ios_popular"
        case iosPaid = "ios_paid"
        case cydia = "cydia"
        case books = "books"
        case dummy = "dummy"
        case banner = "banner"
        case copyright = "copyright"
    }
    
    static let iosTypes: [CellType] = [.iosNew, .iosPaid, .iosPopular, .cydia]
    
    // Set up
    func setUp() {
        
        // Register cells
        for id in Featured.iosTypes { tableView.register(ItemCollection.self, forCellReuseIdentifier: id.rawValue) }
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.books.rawValue)
        tableView.register(Dummy.self, forCellReuseIdentifier: CellType.dummy.rawValue)
        tableView.register(Banner.self, forCellReuseIdentifier: CellType.banner.rawValue)
        tableView.register(Copyright.self, forCellReuseIdentifier: CellType.copyright.rawValue)
        
        for cell in cells.flatMap({$0 as? ItemCollection}) { cell.delegate = self; cell.delegateCategory = self }
        
        //Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor
        
        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    // Add Banner
    func addBanner(_ banner: Banner) {
        tableView.tableHeaderView = banner
        banner.setTimerIfNeeded()
        if let headerView = tableView.tableHeaderView {
            let height: CGFloat = banner.height
            var headerFrame = headerView.frame
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    // Stick banner to top
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = tableView.tableHeaderView as? Banner, let nav = navigationController {
            let minOff: CGFloat = -nav.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height
            if scrollView.contentOffset.y < minOff {
                headerView.subviews[0].bounds.origin.y = minOff - scrollView.contentOffset.y
            } else {
                headerView.subviews[0].bounds.origin.y = 0
            }
        }  
    }
}


// MARK: - 3D Touch Peek and Pop on icons
extension Featured: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemCollection else { return nil }
        
        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(location, to: cell.collectionView)) else { return nil }
        guard cell.items.indices.contains(index.row) else { return nil }
        
        if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedApp {
            let iconRect = tableView.convert(collectionViewCell.icon.frame, from: collectionViewCell.icon.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = iconRect }
        } else if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedBook {
            let coverRect = tableView.convert(collectionViewCell.cover.frame, from: collectionViewCell.cover.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = coverRect }
        } else {
            return nil
        }
        
        let detailsViewController = Details(content: cell.items[index.row])
        return detailsViewController
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
