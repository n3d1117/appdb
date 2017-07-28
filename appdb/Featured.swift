//
//  Featured.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import RealmSwift
import Cartography

protocol ChangeCategory {
    func reloadViewAfterCategoryChange(id: String, type: ItemType)
}

protocol ContentRedirection {
    func pushDetailsController(with content: Object)
}

class Featured: LoadingTableView, UIPopoverPresentationControllerDelegate {
    
    let cells: [FeaturedCell] = [
        ItemCollection(id: .cydia, title: "Custom Apps".localized(), fullSeparator: true),
        Dummy(),
        ItemCollection(id: .iosNew, title: "New and Noteworthy".localized()),
        ItemCollection(id: .iosPaid, title: "Top Paid".localized()),
        ItemCollection(id: .iosPopular, title: "Popular This Week".localized(), fullSeparator: true),
        Dummy(),
        ItemCollection(id: .books, title: "Top Books".localized(), fullSeparator: true),
        Copyright()
    ]
    
    var banner: Banner = Banner()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up
        title = "Featured".localized()
        setUp()
        state = .loading
        animated = true
        
        // Add categories button
        let categoriesButton = UIBarButtonItem(title: "Categories".localized(), style: .plain, target: self, action:#selector(self.openCategories))
        navigationItem.leftBarButtonItem = categoriesButton
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Fix random separator margin issues
        if #available(iOS 9, *) { tableView.cellLayoutMarginsFollowReadableWidth = false }
        
        /* DEBUG */
        let tmpButton = UIBarButtonItem(title: "switch".localized(), style: .plain, target: self, action:#selector(self.tmpSwitch))
        navigationItem.rightBarButtonItem = tmpButton
        /* DEBUG */
        
        // List Genres and enable button on completion
        API.listGenres()

        // Wait for data to be fetched, reload tableView on completion
        reloadTableWhenReady()
        
    }
    
    /* DEBUG */
    func tmpSwitch() { Themes.switchTo(theme: Themes.isNight ? .Light : .Dark) }
    /* DEBUG */
    
    // MARK: - Load Initial Data
    
    func reloadTableWhenReady() {
        
        let itemCells = cells.flatMap{$0 as? ItemCollection}
        if itemCells.count != (itemCells.filter{$0.response.success == true}.count) {
            if !(itemCells.filter{$0.response.errorDescription != ""}.isEmpty) {
                
                let error = itemCells.filter{$0.response.errorDescription != ""}.first!.response.errorDescription
                showErrorMessage(text: "Cannot connect".localized(), secondaryText: error)
                
                // Button target action to retry loading
                refreshButton.addTarget(self, action: #selector(self.retry), for: .touchUpInside)
                
            } else {
                // Not ready, retrying in 0.3 seconds
                delay(0.3) { self.reloadTableWhenReady() }
            }
        } else {
            
            // If i don't do this here, stuff breaks :(
            for layout in itemCells.flatMap({$0.collectionView.collectionViewLayout as? SnappableFlowLayout}) { layout.scrollDirection = .horizontal }
            
            // Add banner
            addBanner(self.banner)
            
            // Enable categories button
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            
            // Works around crazy cell bugs on rotation, enables preloading
            tableView.estimatedRowHeight = 32
            tableView.rowHeight = UITableViewAutomaticDimension
            
            // Reload tableView (animated), hide spinner
            state = .done
        }
    }
    
    // MARK: - Retry Loading
    
    func retry() {
        
        state = .loading
        
        delay(0.3) {
            // Retry all network operations
            API.listGenres()
            for cell in self.cells.flatMap({$0 as? ItemCollection}) { cell.requestItems() }
            //self.banner.setImageInputs()
            self.reloadTableWhenReady()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state == .done ? cells.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return state == .done ? cells[indexPath.row] : UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return state == .done ? cells[indexPath.row].height : 0
    }
    
}

////////////////////////////////
//                            //
//  PROTOCOL IMPLEMENTATIONS  //
//                            //
////////////////////////////////

// MARK: - Reload view after category change
extension Featured: ChangeCategory {
    
    // Open categories
    func openCategories(_ sender: UIBarButtonItem) {
        let categoriesViewController = Categories()
        categoriesViewController.delegate = self
        let nav = UINavigationController(rootViewController: categoriesViewController)
        nav.modalPresentationStyle = .popover
        nav.preferredContentSize = CGSize(width: 350, height: 500)
        if let popover = nav.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = sender.value(forKey: "view") as! UIView?
            popover.sourceRect = (sender.value(forKey: "view") as! UIView!).bounds
            popover.theme_backgroundColor = Color.popoverArrowColor
        }
        present(nav, animated: true, completion: nil)
    }
    
    // Popover on ipad, modal on iphone
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .fullScreen }
    
    // Reload Categories
    func reloadViewAfterCategoryChange(id: String, type: ItemType) {
        for cell in cells { if let collection = cell as? ItemCollection {
            collection.reloadAfterCategoryChange(id: id, type: type)
        } }
    }
}

// MARK: - Push Details controller
extension Featured: ContentRedirection {
    func pushDetailsController(with content: Object) {
        let detailsViewController = Details(content: content)
        if IS_IPAD {
            let nav = DismissableModalNavController(rootViewController: detailsViewController)
            nav.modalPresentationStyle = .formSheet
            navigationController?.present(nav, animated: true)
        } else {
            navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }
}
