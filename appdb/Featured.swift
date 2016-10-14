//
//  Featured.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

class Featured: UITableViewController {
    
    let cells : [FeaturedTableViewCell] = [
        ItemCollection(id: .cydia, vars: FeaturedCellSetUp(label: "Cydia and Custom Apps", fullSeparator: true)),
        Dummy(),
        ItemCollection(id: .iosNew, vars: FeaturedCellSetUp(label: "New and Noteworthy")),
        ItemCollection(id: .iosPaid, vars: FeaturedCellSetUp(label: "Top Paid")),
        ItemCollection(id: .iosFree, vars: FeaturedCellSetUp(label: "Top Free", fullSeparator: true)),
        Dummy(),
        ItemCollection(id: .books, vars: FeaturedCellSetUp(label: "Top Books", fullSeparator: true)),
        Copyright()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up
        title = "Featured"
        tableView.backgroundColor = Color.tableViewBackgroundColor
        clearsSelectionOnViewWillAppear = false 
        
        // Register cells
        registerCells()
        
        // Add banner
        addBanner()
        
        // Works around crazy cell bugs on rotation, enables preloading
        tableView.estimatedRowHeight = 32
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return cells[indexPath.row].height
    }

}
