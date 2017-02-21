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
        for cell in cells { tableView.register(type(of: cell), forCellReuseIdentifier: cell.identifier) }
        
        // Add 'Dismiss' button
        if IS_IPAD {
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItem = dismissButton
        }
        
        // Hide separator for empty cells
        tableView.tableFooterView = UIView()
        
        // UI
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor//Color.veryVeryLightGray
        tableView.theme_separatorColor = Color.borderColor
        
        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }
    }
    
}

// Details cell template

class DetailsCell: UITableViewCell {
    
    var didSetupConstraints: Bool = false
    var type: ItemType = .ios
    var identifier: String { return "" }
    var height: CGFloat { return 0 }
    func setConstraints() {}
    
}
