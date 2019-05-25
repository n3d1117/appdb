//
//  ThemeChooser.swift
//  appdb
//
//  Created by ned on 12/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

protocol ChangedTheme: class {
    func changedTheme()
}

class ThemeChooser: UITableViewController {
    
    weak var changedThemeDelegate: ChangedTheme?
    
    fileprivate var lightTheme: Bool {
        return !Themes.isNight
    }
    
    fileprivate var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()
    
    convenience init() {
        self.init(style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose Theme".localized()
        
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
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }
    }
    
    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? "Light".localized() : "Dark".localized()
        cell.textLabel?.font = .systemFont(ofSize: (16~~15))
        cell.textLabel?.makeDynamicFont()
        cell.textLabel?.theme_textColor = Color.title
        switch indexPath.row {
            case 0: cell.accessoryType = lightTheme ? .checkmark : .none
            default: cell.accessoryType = !lightTheme ? .checkmark : .none
        }
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0: if Themes.isNight { Themes.switchTo(theme: .Light) }
            default: if !Themes.isNight { Themes.switchTo(theme: .Dark) }
        }
        changedThemeDelegate?.changedTheme()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Themes".localized()
    }
    
}
