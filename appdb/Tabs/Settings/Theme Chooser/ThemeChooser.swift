//
//  ThemeChooser.swift
//  appdb
//
//  Created by ned on 12/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit

protocol ChangedTheme: AnyObject {
    func changedTheme()
}

class ThemeChooser: UITableViewController {

    weak var changedThemeDelegate: ChangedTheme?
    var followSystemAppearanceToggle: UISwitch?

    private var bgColorView: UIView = {
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        return bgColorView
    }()

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }

        if #available(iOS 13.0, *) {
            followSystemAppearanceToggle = UISwitch()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Choose Theme".localized()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        tableView.cellLayoutMarginsFollowReadableWidth = true

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        if #available(iOS 13.0, *) {} else {
            if Global.isIpad {
                // Add 'Dismiss' button for iPad
                let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
                self.navigationItem.rightBarButtonItems = [dismissButton]
            }
        }

        disableUserInteractionIfNeeded()
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if #available(iOS 13.0, *) {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if #available(iOS 13.0, *), section > 0 {
            return 1
        } else {
            return Themes.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if #available(iOS 13.0, *), indexPath.section > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Follow System Appearance".localized()
            cell.textLabel?.makeDynamicFont()
            cell.textLabel?.theme_textColor = Color.title
            cell.setBackgroundColor(Color.veryVeryLightGray)
            cell.accessoryView = followSystemAppearanceToggle
            followSystemAppearanceToggle?.setOn(Preferences.followSystemAppearance, animated: false)
            followSystemAppearanceToggle?.addTarget(self, action: #selector(appearanceToggleValueChanged), for: .valueChanged)
            cell.accessoryType = .none
            cell.theme_backgroundColor = Color.veryVeryLightGray
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = Themes(rawValue: indexPath.row)?.toString
            cell.textLabel?.makeDynamicFont()
            cell.textLabel?.theme_textColor = Color.title
            cell.accessoryView = nil
            cell.accessoryType = Themes.current == Themes(rawValue: indexPath.row) ? .checkmark : .none
            cell.setBackgroundColor(Color.veryVeryLightGray)
            cell.theme_backgroundColor = Color.veryVeryLightGray
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let theme = Themes(rawValue: indexPath.row) else { return }
        if theme == .dark {
            Preferences.set(.shouldSwitchToDarkerTheme, to: false)
        } else if theme == .darker {
            Preferences.set(.shouldSwitchToDarkerTheme, to: true)
        }
        reloadTheme(theme: theme)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if #available(iOS 13.0, *), section > 0 {
            return ""
        } else {
            return "Available Themes".localized()
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if #available(iOS 13.0, *), section > 0 {
            return "Automatically switch between light and dark theme based on System Appearance. To switch to the Darker theme instead, just manually select it once.\n\nNOTE: If you're experiencing issues (theme not switching automatically or mixed themes) just close the app from multitasking and reopen it.".localized()
        }
        return nil
    }

    @objc func appearanceToggleValueChanged(sender: UISwitch) {
        Preferences.set(.followSystemAppearance, to: sender.isOn)

        disableUserInteractionIfNeeded()

        if Preferences.followSystemAppearance {
            switch Themes.current {
            case .dark, .darker:
                if !Global.isDarkSystemAppearance {
                    reloadTheme(theme: .light)
                }
            default:
                if Global.isDarkSystemAppearance {
                    reloadTheme(theme: Preferences.shouldSwitchToDarkerTheme ? .darker : .dark)
                }
            }
        }

        Global.refreshAppearanceForCurrentTheme()
    }

    func disableUserInteractionIfNeeded() {
        if #available(iOS 13.0, *) {
            (0..<tableView.numberOfRows(inSection: 0)).indices.forEach { rowIndex in
                if let cell = tableView.cellForRow(at: IndexPath(row: rowIndex, section: 0)) {
                    cell.setEnabled(on: !Preferences.followSystemAppearance)
                }
            }
        }
    }

    func reloadTheme(theme: Themes) {
        if Themes.current != theme {
            Themes.switchTo(theme: theme)
            changedThemeDelegate?.changedTheme()
            tableView.reloadData()
        }
    }
}
