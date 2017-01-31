//
//  FeaturedGenerics.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit

// Abstract cell, height
class FeaturedCell : UITableViewCell {
    var height : CGFloat {
        guard let id = Featured.CellType(rawValue: reuseIdentifier ?? "") else { return 0 }
        
        // iOS Height
        if Featured.iosTypes.contains(id) { return Featured.size.heightIos.value + (45~~40) }
        
        // Books Height
        if id == .books { return Featured.size.heightBooks.value + (45~~40) }
        return 0
    }
}

extension Featured {
    
    // Reuse identifiers
    enum CellType : String {
        case iosNew = "ios_new"
        case iosPaid = "ios_paid"
        case iosPopular = "ios_popular"
        case iosGames = "ios_games"
        case cydia = "cydia"
        case books = "books"
        case dummy = "dummy"
        case banner = "banner"
        case copyright = "copyright"
    }
    
    static let iosTypes : [CellType] = [.iosNew, .iosPaid, .iosPopular, .iosGames, .cydia]
    
    enum size {
        case spacing      // The spacing between items
        case margin       // Left margin
        case itemWidth    // The width of th items in the collectionView
        case heightIos    // Height of collectionView for ios (add 40 for height of cell)
        case heightBooks  // Height of collectionView for books
        
        var value : CGFloat {
            switch self {
            case .spacing: return 25~~15
            case .margin: return 20~~15
            case .itemWidth: return 83~~73
            case .heightIos: return 150~~135
            case .heightBooks: return 190~~180
            }
        }
    }
    
    // Featured's collection view item sizes
    static let sizeIos : CGSize = CGSize(width: Featured.size.itemWidth.value, height: Featured.size.heightIos.value)
    static let sizeBooks : CGSize = CGSize(width: Featured.size.itemWidth.value, height: Featured.size.heightBooks.value)
    
    // Register cells
    func registerCells() {
        for id in Featured.iosTypes { tableView.register(ItemCollection.self, forCellReuseIdentifier: id.rawValue) }
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.books.rawValue)
        tableView.register(Dummy.self, forCellReuseIdentifier: CellType.dummy.rawValue)
        tableView.register(Banner.self, forCellReuseIdentifier: CellType.banner.rawValue)
        tableView.register(Copyright.self, forCellReuseIdentifier: CellType.copyright.rawValue)
    }
    
    // Add Banner
    func addBanner(from: Banner) {
        tableView.tableHeaderView = from
        from.slideshow.unpauseTimerIfNeeded()
        if let headerView = tableView.tableHeaderView {
            let height : CGFloat = from.height
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
        if let headerView = tableView.tableHeaderView as? Banner {
            let minOff : CGFloat = -navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.size.height
            if scrollView.contentOffset.y < minOff {
                headerView.subviews[0].bounds.origin.y = minOff - scrollView.contentOffset.y
            } else {
                headerView.subviews[0].bounds.origin.y = 0
            }
        }  
    }
}
