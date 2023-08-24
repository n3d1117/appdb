//
//  AltStoreRepos+Extension.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit

extension AltStoreRepos {

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    func setUp() {
        // Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor

        tableView.cellLayoutMarginsFollowReadableWidth = true

        tableView.register(AltStoreRepoCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = (85 ~~ 65)

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRepoClicked))
        navigationItem.rightBarButtonItem = addItem

        state = .loading
        animated = true
        showsErrorButton = false

        // Observe deauthorization event
        NotificationCenter.default.addObserver(self, selector: #selector(onDeauthorization), name: .Deauthorized, object: nil)
    }

    // Only enable button if text is not empty
    /*@objc func repoUrlTextfieldTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            (alert.actions[1] as UIAlertAction).isEnabled = !(sender.text ?? "").isEmpty
        }
    }*/

    @objc func addRepoClicked() {
        let alertController = UIAlertController(title: "Please enter repository URL".localized(), message: nil, preferredStyle: .alert, adaptive: true)
        alertController.addTextField { textField in
            textField.placeholder = "Repository URL".localized()
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.keyboardType = .URL
            //textField.addTarget(self, action: #selector(self.repoUrlTextfieldTextChanged(sender:)), for: .editingChanged)
            textField.clearButtonMode = .whileEditing
        }
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let addAction = UIAlertAction(title: "Add repo".localized(), style: .default, handler: { _ in
            guard let text = alertController.textFields?[0].text else { return }
            API.addAltStoreRepo(url: text) { item in
                Messages.shared.showSuccess(message: "Repository was added successfully".localized(), context: .viewController(self))
                self.loadRepos()
            } fail: { error in
                Messages.shared.showError(message: "An error occurred while adding the new repository".localized(), context: .viewController(self))
            }
        })
        alertController.addAction(addAction)
        //addAction.isEnabled = false

        present(alertController, animated: true)
    }

    @objc func onDeauthorization() {
        self.cleanup()
        showErrorMessage(text: "An error has occurred".localized(), secondaryText: "Please authorize app from Settings first".localized(), animated: false)
    }
}

////////////////////////////////
//  PROTOCOL IMPLEMENTATIONS  //
////////////////////////////////

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension AltStoreRepos {

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let repos = indexPath.section == 0 ? privateRepos : publicRepos
        guard repos.indices.contains(indexPath.row) else { return nil }
        let item = repos[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { AltStoreRepoApps(repo: item) })
    }

    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let viewController = animator.previewViewController {
                if Global.isIpad {
                    let nav = DismissableModalNavController(rootViewController: viewController)
                    nav.modalPresentationStyle = .formSheet
                    self.navigationController?.present(nav, animated: true)
                } else {
                    self.show(viewController, sender: self)
                }
            }
        }
    }
}

// MARK: - 3D Touch Peek and Pop on updates

extension AltStoreRepos: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        let repos = indexPath.section == 0 ? privateRepos : publicRepos
        guard repos.indices.contains(indexPath.row) else { return nil }
        let item = repos[indexPath.row]
        let vc = AltStoreRepoApps(repo: item)
        return vc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
