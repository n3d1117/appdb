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
    
    var content : Object!
    
    var cells : [DetailsCell] = []
    
    // Init with content (app, cydia app or book)
    convenience init(content: Object) {
        self.init(style: .plain)
        
        self.content = content
        
        // Initialize the cells now that we know the type
        cells = [
            DetailsHeader(type: contentType, content: content)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()

    }
    
    func dismissAnimated() {
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row].height
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }

}
