//
//  LanguageChooser.swift
//  appdb
//
//  Created by ned on 12/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Localize_Swift

protocol ChangedLanguage: class {
    func changedLanguage()
}

class LanguageChooser: UITableViewController {
    
    weak var changedLanguageDelegate: ChangedLanguage?

    fileprivate var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()
    
    let availableLanguages = Localize.availableLanguages().filter({ !Localize.displayNameForLanguage($0).isEmpty })
    var currentLanguage: String {
        return Localize.currentLanguage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose Language".localized()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
        
        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        
        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            navigationItem.rightBarButtonItems = [dismissButton]
        }
    }
    
    @objc fileprivate func dismissAnimated() { dismiss(animated: true) }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableLanguages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let language = availableLanguages[indexPath.row]
        cell.textLabel?.text = Localize.displayNameForLanguage(language)
        cell.textLabel?.font = .systemFont(ofSize: (17~~16))
        cell.textLabel?.theme_textColor = Color.title
        cell.accessoryType = language == currentLanguage ? .checkmark : .none
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard availableLanguages.indices.contains(indexPath.row) else { return }
        let language = availableLanguages[indexPath.row]
        Localize.setCurrentLanguage(language)
        changedLanguageDelegate?.changedLanguage()
        tableView.reloadData()
        title = "Choose Language".localized()
        if Global.isIpad { navigationItem.rightBarButtonItem?.title = "Dismiss".localized() }
        Messages.shared.hideAll()
        Messages.shared.showSuccess(message: "Language set correctly, please restart the app to apply changes".localized(), context: Global.isIpad ? .viewController(self) : nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
