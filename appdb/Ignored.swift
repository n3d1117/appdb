//
//  Ignored.swift
//  appdb
//
//  Created by ned on 10/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import RealmSwift

protocol IgnoredAppsListChanged: class {
    func ignoredChanged()
}

class Ignored: LoadingTableView {
    
    // Delegate to notify for changes in ignored list
    var delegate: IgnoredAppsListChanged?
    
    let realm = try! Realm()
    
    var ignoredTrackids: [String] {
        guard let obj = realm.objects(IgnoredUpdateableApps.self).first else { return [] }
        return Array(obj.ignoredTrackids)
    }
    
    var apps: [UpdateableApp] {
        var tmpApps: [UpdateableApp] = []
        for id in ignoredTrackids {
            if let match = realm.objects(UpdateableApp.self).filter("trackid = %@", id).first {
                tmpApps.append(match)
            }
        }
        return tmpApps.sorted{ $0.name.lowercased() < $1.name.lowercased() }
    }
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animated = false
        showsSpinner = false
        showsErrorButton = false
        
        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor

        tableView.register(IgnoredCell.self, forCellReuseIdentifier: "cell")
        
        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }
        
        if apps.isEmpty {
            showErrorMessage(text: "No ignored updates".localized(), secondaryText: "Swipe left on any update to add it to this list".localized(), animated: false)
        }
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return apps.isEmpty ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IgnoredCell
        
        // If there are two apps with the same name, append section at the end to distinguish them
        let app = apps[indexPath.row]
        var name = app.name
        if apps.filter({ $0.name == name }).count > 1 {
            let stringToBeAdded = app.type == "ios" ? (" (" + "iOS".localized() + ")") : (" (" + "Cydia".localized() + ")")
            name.append(contentsOf: stringToBeAdded)
        }
        
        cell.configure(with: name, image: app.image)
        cell.removeButton.addTarget(self, action: #selector(self.removeFromIgnored), for: .touchUpInside)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UpdatesSectionHeader(showsButton: false)
        view.configure(with: "Ignored Updates".localized())
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - Remove from ignored list
    
    @objc func removeFromIgnored(_ sender: UIButton) {
        guard let obj = realm.objects(IgnoredUpdateableApps.self).first else { return }
        
        if let cell = sender.superview as? IgnoredCell, let row = tableView.indexPath(for: cell)?.row {

            guard apps.indices.contains(row) else { return }
            
            try! realm.write {
                if let index = obj.ignoredTrackids.index(of: apps[row].trackid) {
                    obj.ignoredTrackids.remove(at: index) // this affects self.apps too
                    tableView.beginUpdates()
                    if apps.isEmpty {
                        tableView.deleteSections(IndexSet(arrayLiteral: 0), with: .fade)
                    } else {
                        tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
                    }
                    tableView.endUpdates()
                    if apps.isEmpty {
                        showErrorMessage(text: "No ignored updates".localized(), secondaryText: "Swipe left on any update to add it to this list".localized(), animated: false)
                    }
                    delegate?.ignoredChanged()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if !self.apps.isEmpty { self.tableView.reloadData() }
        }, completion: nil)
    }
    
}
