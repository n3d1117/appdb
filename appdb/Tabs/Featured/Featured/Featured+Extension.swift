//
//  Featured+Extension.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit

// Abstract cell, height
class FeaturedCell: UITableViewCell {
    var height: CGFloat {
        guard let id = Featured.CellType(rawValue: reuseIdentifier ?? "") else { return 0 }

        // iOS Height
        if Featured.iosTypes.contains(id) { return Global.Size.heightIos.value + (45 ~~ 40) }

        // Books Height
        if id == .books { return Global.Size.heightBooks.value + (45 ~~ 40) }
        return 0
    }
}

extension Featured {

    // Reuse identifiers
    enum CellType: String {
        case iosNew = "ios_new"
        case iosPopular = "ios_popular"
        case iosPaid = "ios_paid"
        case cydia = "cydia"
        case books = "books"
        case dummy = "dummy"
        case copyright = "copyright"
    }

    static let iosTypes: [CellType] = [.iosNew, .iosPaid, .iosPopular, .cydia]

    // Invalidate banner timer when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        banner.pauseTimer()
    }

    // Resume timer when view reappears
    override func viewWillAppear(_ animated: Bool) {
        banner.setTimerIfNeeded()
    }

    // Set up
    func setUp() {
        // Register cells
        for id in Featured.iosTypes { tableView.register(ItemCollection.self, forCellReuseIdentifier: id.rawValue) }
        tableView.register(ItemCollection.self, forCellReuseIdentifier: CellType.books.rawValue)
        tableView.register(Dummy.self, forCellReuseIdentifier: CellType.dummy.rawValue)
        tableView.register(Copyright.self, forCellReuseIdentifier: CellType.copyright.rawValue)

        for cell in cells.compactMap({$0 as? ItemCollection}) { cell.delegate = self; cell.delegateCategory = self }

        // Register for 3D Touch
        if #available(iOS 9.0, *), traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor

        if #available(iOS 11.0, *) {
            tableView.insetsContentViewsToSafeArea = false
        }

        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }

    // Add Banner
    func addBanner(_ banner: Banner) {
        tableView.tableHeaderView = banner
        if let headerView = tableView.tableHeaderView {
            let height: CGFloat = Banner.height
            var headerFrame = headerView.frame
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    // Stick banner to top
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = tableView.tableHeaderView as? Banner, let nav = navigationController {
            let minOff: CGFloat = -nav.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height
            if scrollView.contentOffset.y < minOff {
                headerView.bounds.origin.y = minOff - scrollView.contentOffset.y
            } else {
                headerView.bounds.origin.y = 0
            }
        }
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension Featured {

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard let cell = tableView.cellForRow(at: indexPath) as? ItemCollection else { return nil }
        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(point, to: cell.collectionView)) else { return nil }
        guard cell.items.indices.contains(index.row) else { return nil }

        let indexPathsIdentifiers: [IndexPath] = [indexPath, index]

        return UIContextMenuConfiguration(identifier: indexPathsIdentifiers as NSCopying, previewProvider: { Details(content: cell.items[index.row]) })
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

    override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let ids = configuration.identifier as? [IndexPath] else { return nil }
        guard ids.indices.contains(0), ids.indices.contains(1) else { return nil }
        let firstIndex = ids[0], secondIndex = ids[1]

        guard let cell = tableView.cellForRow(at: firstIndex) as? ItemCollection else { return nil }
        guard cell.items.indices.contains(secondIndex.row) else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        if let collectionViewCell = cell.collectionView.cellForItem(at: secondIndex) {
            return UITargetedPreview(view: collectionViewCell.contentView, parameters: parameters)
        }

        return nil
    }
}

// MARK: - 3D Touch Peek and Pop on icons

extension Featured: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemCollection else { return nil }

        guard let index = cell.collectionView.indexPathForItem(at: self.view.convert(location, to: cell.collectionView)) else { return nil }
        guard cell.items.indices.contains(index.row) else { return nil }

        if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedApp {
            let iconRect = tableView.convert(collectionViewCell.icon.frame, from: collectionViewCell.icon.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = iconRect }
        } else if let collectionViewCell = cell.collectionView.cellForItem(at: index) as? FeaturedBook {
            let coverRect = tableView.convert(collectionViewCell.cover.frame, from: collectionViewCell.cover.superview!)
            if #available(iOS 9.0, *) { previewingContext.sourceRect = coverRect }
        } else {
            return nil
        }

        let detailsViewController = Details(content: cell.items[index.row])
        return detailsViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
