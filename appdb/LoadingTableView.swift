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
    var refreshButton : UIButton!
    var group = ConstraintGroup()
    
    // MARK: - ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.rowHeight = view.frame.height + 200 /* Temporary row height for spinner */
        tableView.isScrollEnabled = false

        //Set up Activity Indicator View
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.theme_activityIndicatorViewStyle = [.gray, .white]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        //Set up Error Message
        errorMessage = UILabel()
        errorMessage.theme_textColor = Color.copyrightText
        errorMessage.font = UIFont.systemFont(ofSize: 22)
        errorMessage.numberOfLines = 0
        errorMessage.textAlignment = .center
        
        // Set up 'Retry' button
        refreshButton = ButtonFactory.createRetryButton(text: "Retry", color: Color.copyrightText)
        refreshButton.isHidden = true
        
        view.addSubview(refreshButton)
        view.addSubview(errorMessage)
        view.addSubview(activityIndicator)
        
        setConstraints()
    }
    
    // MARK: - Orientation

    func setConstraints() {
        constrain(activityIndicator, errorMessage, refreshButton, replace: group) { indicator, message, button in
            let offset = navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.height + tabBarController!.tabBar.frame.height
            
            indicator.centerX == indicator.superview!.centerX
            indicator.centerY == indicator.superview!.centerY - (offset / 2.0)
            
            message.left == message.superview!.left + 30
            message.right == message.superview!.right - 30
            message.centerX == message.superview!.centerX
            message.centerY == message.superview!.centerY - (offset / 2.0) - 25
            
            button.top == message.bottom + 30
            button.width == 78
            button.centerX == button.superview!.centerX
        }
    }
    
    // Update constraints to reflect orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if !self.loaded { self.setConstraints() }
        }, completion: nil)
    }
    
    // MARK: - error Screen
    func showErrorMessage(text: String = "") {
        
        activityIndicator.stopAnimating()

        errorMessage.isHidden = false
        refreshButton.isHidden = false
        errorMessage.text = text

    }

}
