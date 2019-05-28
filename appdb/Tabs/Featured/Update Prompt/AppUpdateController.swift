//
//  AppUpdateController.swift
//  appdb
//
//  Created by ned on 28/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

protocol AppUpdateDynamicHeightChange: class {
    func updateHeight(with value: CGFloat)
}

class AppUpdateNavController: UINavigationController, AppUpdateDynamicHeightChange {

    var group = ConstraintGroup()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        // Initial height, to be updated later
        constrain(view, replace: group) { view in
            view.height ~== AppUpdateHeader.height + navigationBar.frame.size.height + 1
            view.width ~<= (800 ~~ 550)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Update view height constraint and animate the change
    func updateHeight(with value: CGFloat) {
        var newHeight: CGFloat = value + navigationBar.frame.size.height + AppUpdateHeader.height - 1
        let maxHeight: CGFloat = 550 ~~ (UIScreen.main.bounds.height - (UIApplication.shared.statusBarOrientation.isLandscape ? 50 : 200))
        if newHeight > maxHeight { newHeight = maxHeight }
        constrain(view, replace: group) { view in
            view.height ~== newHeight
            view.width ~<= 800 ~~ 550
        }
        UIView.animate(withDuration: 0.2, animations: view.superview!.layoutIfNeeded)
    }
}

class AppUpdateController: UITableViewController {

    var updatedApp: CydiaApp!
    var linkId: String!

    weak var delegate: AppUpdateDynamicHeightChange?

    init(updatedApp: CydiaApp, linkId: String) {
        self.updatedApp = updatedApp
        self.linkId = linkId
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Update Available".localized()

        tableView.estimatedRowHeight = 200

        tableView.register(AppUpdateHeader.self, forCellReuseIdentifier: "header")
        tableView.register(DetailsChangelog.self, forCellReuseIdentifier: "changelog")

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Add 'Dismiss' button
        let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(dismissAnimated))
        self.navigationItem.rightBarButtonItems = [dismissButton]

        updateHeight(afterWaitingFor: 0.4)
    }

    // Calls updateHeight() of the delegate, passing cell height
    // This is ugly, but who cares?
    func updateHeight(afterWaitingFor: Double) {
        delay(afterWaitingFor) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DetailsChangelog {
                self.delegate?.updateHeight(with: cell.frame.size.height)
            }
        }
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath) as? AppUpdateHeader {
                cell.configure(with: updatedApp, linkId: linkId)
                cell.updateButton.addTarget(self, action: #selector(update), for: .touchUpInside)
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "changelog", for: indexPath) as? DetailsChangelog {
                cell.desc.collapsed = false // show all text by default, without '...more' button
                cell.configure(type: .cydia, changelog: updatedApp.whatsnew, updated: updatedApp.itemUpdatedDate)
                cell.title.text = "What's New in version %@".localizedFormat(updatedApp.version)
                cell.addSeparator(full: true)
                return cell
            }
        default: return UITableViewCell()
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? AppUpdateHeader.height : UITableView.automaticDimension
    }

    // MARK: - Rotation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.updateHeight(afterWaitingFor: 0.3)
        }, completion: nil)
    }

    // MARK: - Update button tapped

    @objc private func update(sender: RoundedButton) {
        func setButtonTitle(_ text: String) {
            sender.setTitle(text.localized().uppercased(), for: .normal)
        }

        guard Preferences.deviceIsLinked else {
            setButtonTitle("Checking...")
            delay(0.3) {
                Messages.shared.showError(message: "Please authorize app from Settings first".localized(), context: Global.isIpad ? .viewController(self) : nil)
                setButtonTitle("Update")
            }
            return
        }

        setButtonTitle("Requesting...")

        API.install(id: sender.linkId, type: .cydia) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                Messages.shared.showError(message: error.prettified, context: Global.isIpad ? .viewController(self) : nil)
                delay(0.3) {
                    setButtonTitle("Update")
                }
            } else {
                setButtonTitle("Requested")
                Messages.shared.showSuccess(message: "Installation has been queued to your device".localized())

                ObserveQueuedApps.shared.addApp(type: .cydia, linkId: sender.linkId, name: self.updatedApp.name, image: self.updatedApp.image, bundleId: self.updatedApp.bundleId)

                delay(5) { setButtonTitle("Install") }
            }
        }
    }
}
