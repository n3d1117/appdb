//
//  IPACache.swift
//  appdb
//
//  Created by ned on 05/01/22.
//  Copyright © 2022 ned. All rights reserved.
//

import UIKit

class IPACache: LoadingTableView {

    var status: IPACacheStatus? {
        didSet {
            self.tableView.spr_endRefreshing()
            self.state = .done
        }
    }

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "IPA Cache".localized()

        tableView.register(SimpleStaticCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 50

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        animated = false
        showsErrorButton = false
        showsSpinner = false

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }

        // Refresh action
        tableView.spr_setIndicatorHeader { [weak self] in
            self?.fetchStatus()
        }

        tableView.spr_beginRefreshing()
    }

    private func fetchStatus() {
        API.getIPACacheStatus { [weak self] status in
            guard let self = self else { return }
            self.status = status
        } fail: { [weak self] error in
            guard let self = self else { return }
            self.status = nil
            self.showErrorMessage(text: "Cannot connect".localized(), secondaryText: error.localizedDescription, animated: false)
        }
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        status == nil ? 0 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        status == nil
            ? 0
            : section == 0 ? 1 : 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SimpleStaticCell, let status = status {
            if (indexPath.section == 0) {
                cell.textLabel?.text = "Cached IPAs".localized()
                cell.detailTextLabel?.text = "\(status.ipas.count)"
                cell.textLabel?.theme_textColor = Color.title
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            } else {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Size".localized()
                    cell.detailTextLabel?.text = status.sizeHr + " / " + status.sizeLimitHr
                    cell.textLabel?.theme_textColor = Color.title
                    cell.selectionStyle = .none
                case 1:
                    cell.textLabel?.text = "In Update".localized()
                    cell.detailTextLabel?.text = status.inUpdate ? "Yes".localized() : "No".localized()
                    cell.textLabel?.theme_textColor = Color.title
                    cell.selectionStyle = .none
                case 2:
                    cell.textLabel?.text = "Reinstall everything".localized()
                    cell.detailTextLabel?.text = nil
                    cell.textLabel?.theme_textColor = Color.mainTint
                    cell.selectionStyle = .default
                case 3:
                    cell.textLabel?.text = "Clear IPA cache".localized()
                    cell.detailTextLabel?.text = nil
                    cell.textLabel?.theme_textColor = Color.mainTint
                    cell.selectionStyle = .default
                case 4:
                    cell.textLabel?.text = "Re-validate IPA cache".localized()
                    cell.detailTextLabel?.text = nil
                    cell.textLabel?.theme_textColor = Color.mainTint
                    cell.selectionStyle = .default
                default: break
                }
            }
            return cell
        }
        return UITableViewCell()
    }

    // MARK: - Section header view

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UpdatesSectionHeader(showsButton: section == 0)
        view.configure(with: section == 0 ? status?.updatedAt ?? "" : "IPA cache status for current device".localized())
        view.helpButton.addTarget(self, action: #selector(self.showHelp), for: .touchUpInside)
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return status == nil ? 0 : (60 ~~ 50)
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        status == nil
            ? nil
            : section == 0 ? status?.updatedAt : ""
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && status != nil {
            let cachedIPAsVc = CachedIPAs()
            cachedIPAsVc.cachedIPAs = status!.ipas
            navigationController?.pushViewController(cachedIPAsVc, animated: true)
        } else {
            switch indexPath.row {
            case 2:
                API.reinstallEverything(success: {
                    Messages.shared.showSuccess(message: "Success".localized(), context: .viewController(self))
                }, fail: { error in
                    Messages.shared.showError(message: error.prettified, context: .viewController(self))
                })
            case 3:
                API.clearIpaCache {
                    Messages.shared.showSuccess(message: "Success".localized(), context: .viewController(self))
                }
            case 4:
                API.revalidateIpaCache {
                    Messages.shared.showSuccess(message: "Success".localized(), context: .viewController(self))
                }
            default:
                break
            }
        }
    }
    
    @objc func showHelp() {
        let message = "appdb saves all installed IPA files for your device to cache, so you can easily restore all your apps after device reset or revocation. Cache is stored per device, and will be deleted if you will unlink your device. If you restored your device and missing appdb profile, you can visit device status page and tap \"Update profile\" button to install it, or link device via email by tapping \"Just link new device\" in message from appdb.\n\nNote: IPA files does not contain app data, if you want to keep your app data, backup device via Finder or iTunes, Remove revoked apps, Install apps from cache and then restore backup from Finder or iTunes.".localized()
        let alertController = UIAlertController(title: "IPA cache status for current device".localized(), message: message, preferredStyle: .alert, adaptive: true)
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
