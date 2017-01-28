//
//  LoadingTableView.swift
//  appdb
//
//  Created by ned on 06/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

/*
 *    USAGE FOR FUTURE NED
 *    subclass LoadingTableView, spinner will appear automatically in the center
 *    when data is done loading, set loaded = true and tableView will be reloaded
 *    ( if loading fails, call showErrorMessage with error string,
 *    spinner will be hidden and message will be shown in the center )
 */

class LoadingTableView: UITableViewController {
    
    var loaded : Bool = false {
        didSet { if loaded { /* Done loading, hide spinner and reload tableView. */
            activityIndicator.stopAnimating()
            tableView.isScrollEnabled = true
            tableView.reloadData()
        } }
    }
    
    var activityIndicator : UIActivityIndicatorView!
    var errorMessage : UILabel!
    var group = ConstraintGroup()
    
    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.rowHeight = view.frame.height + 200 /* Temporary row height for spinner */
        tableView.isScrollEnabled = false
        
        // Orientation did change notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeOrientation), name: .UIDeviceOrientationDidChange, object: nil)
        
        //Set up Activity Indicator View
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.theme_activityIndicatorViewStyle = [.gray, .white]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        errorMessage = UILabel()
        errorMessage.theme_textColor = Color.copyrightText
        errorMessage.font = UIFont.systemFont(ofSize: 21.0)
        errorMessage.numberOfLines = 0
        errorMessage.textAlignment = .center
        
        view.addSubview(errorMessage)
        view.addSubview(activityIndicator)
        
        setConstraints()
    }
    
    // MARK: - Orientation
    
    // Remove observer, mom's spaghetti
    deinit { NotificationCenter.default.removeObserver(self) }
    
    func setConstraints() {
        constrain(activityIndicator, errorMessage, replace: group) { indicator, message in
            let offset = navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.height + tabBarController!.tabBar.frame.height
            
            indicator.centerX == indicator.superview!.centerX
            indicator.centerY == indicator.superview!.centerY - (offset / 2.0)
            
            message.left == message.superview!.left + 30
            message.right == message.superview!.right - 30
            message.centerX == message.superview!.centerX
            message.centerY == message.superview!.centerY - (offset / 2.0)
        }
    }
    
    // Update constraints to reflect orientation change
    func didChangeOrientation() {
        if !loaded { setConstraints() }
    }
    
    // MARK: - error Screen
    func showErrorMessage(text: String = "") {
        activityIndicator.stopAnimating()
        errorMessage.text = text
        errorMessage.sizeToFit()
    }

}
