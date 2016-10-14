//
//  FeaturedGenerics.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit

// Reuse identifiers
enum CellType : String {
    case iosNew = "ios_new"
    case iosPaid = "ios_paid"
    case iosFree = "ios_free"
    case cydia = "cydia"
    case books = "books"
    case dummy = "dummy"
    case banner = "banner"
    case copyright = "copyright"
}

// Utils
extension Featured {
    
    // Register cells
    func registerCells() {
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.cydia.rawValue)
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.iosNew.rawValue)
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.iosPaid.rawValue)
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.iosFree.rawValue)
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.books.rawValue)
        tableView.register(Dummy.self, forCellReuseIdentifier: CellType.dummy.rawValue)
        tableView.register(Banner.self, forCellReuseIdentifier: CellType.banner.rawValue)
        tableView.register(Copyright.self, forCellReuseIdentifier: CellType.copyright.rawValue)
    }
    
    // Add Banner
    func addBanner() {
        tableView.tableHeaderView = Banner()
        if let headerView = tableView.tableHeaderView {
            let height : CGFloat = 200~~150
            var headerFrame = headerView.frame
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    //Stick banner to top
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = tableView.tableHeaderView as? Banner {
            let minOff : CGFloat = -navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.size.height + 1.0
            if scrollView.contentOffset.y < minOff {
                headerView.contentView.frame.origin.y = min(scrollView.contentOffset.y - minOff+0.5, 0)
            }
        }
    }
}

// Abstract cell
class FeaturedTableViewCell : UITableViewCell {
    var height : CGFloat {
        guard let id = self.reuseIdentifier else { return 0 }
        switch id {
            case CellType.iosNew.rawValue, CellType.iosPaid.rawValue, CellType.iosFree.rawValue, CellType.cydia.rawValue : return common.size.heightIos.value + 40
            case CellType.books.rawValue : return common.size.heightBooks.value + 40
            case CellType.dummy.rawValue : return common.size.spacing.value
            case CellType.copyright.rawValue : return 60~~75
            default: return 0
        }
    }
}

// Common values
class common {
    enum size {
        case spacing     // The spacing between items
        case margin      // Left margin
        case itemWidth   // The width of th items in the collectionView
        case heightIos   // Height of collectionView for ios (add 40 for height of cell)
        case heightBooks // Height of collectionView for books
        
        var value : CGFloat {
            switch self {
                case .spacing: return 25~~15
                case .margin: return 20~~15
                case .itemWidth: return 83~~73
                case .heightIos: return 145~~135
                case .heightBooks: return 190~~175
            }
        }
    }
    
    // Featured's collection view item sizes
    static let sizeIos : CGSize = CGSize(width: common.size.itemWidth.value, height: common.size.heightIos.value)
    static let sizeBooks : CGSize = CGSize(width: common.size.itemWidth.value, height: common.size.heightBooks.value)
}

// Variables for featured cells
class FeaturedCellSetUp {

    var fullSeparator : Bool
    var sectionLabel : String
    
    init(label: String, fullSeparator : Bool) {
        self.fullSeparator = fullSeparator; self.sectionLabel = label;
    }
    
    convenience init(label: String) {
        self.init(label: label, fullSeparator: false)
    }
}
