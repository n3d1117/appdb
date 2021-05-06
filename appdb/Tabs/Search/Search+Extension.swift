//
//  Search+Extension.swift
//  appdb
//
//  Created by ned on 04/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import ObjectMapper

extension Search {

    var topInset: CGFloat {
        Global.isIpad ? 25 : 15
    }

    var margin: CGFloat {
        UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : 15
    }

    func pushDetailsController(with content: Item) {
        let detailsViewController = Details(content: content)
        if Global.isIpad {
            let nav = DismissableModalNavController(rootViewController: detailsViewController)
            nav.modalPresentationStyle = .formSheet
            navigationController?.present(nav, animated: true)
        } else {
            navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shouldRelayout, currentPhase != .loading {
            shouldRelayout = false
            switchLayout(phase: currentPhase)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shouldRelayout = true
        coordinator.animate(alongsideTransition: { _ in
            if self.currentPhase != .loading { self.switchLayout(phase: self.currentPhase) }
        })
    }

    func searchAndUpdate<T>(_ type: T.Type, query: String = "", page: Int = 1) where T: Item {
        var tmp: [SearchCell] = []
        if page == 1 { results = [] }

        self.collectionView.spr_resetNoMoreData()

        API.search(type: type, q: query, page: page, success: { [weak self] items in
            guard let self = self else { return }

            for item in items {
                self.results.append(item)

                switch self.detectScreenshotsOrder(from: item) {
                case .none: tmp.append(NoScreenshotsSearchCell())
                case .noneBook: tmp.append(NoScreenshotsSearchCellBook())
                case .noneBookStars: tmp.append(NoScreenshotsSearchCellBookWithStars())
                case .onePortraitIphone: tmp.append(PortraitScreenshotSearchCelliPhone())
                case .onePortraitIphoneStars: tmp.append(PortraitScreenshotSearchCellWithStarsiPhone())
                case .onePortraitIpad: tmp.append(PortraitScreenshotSearchCelliPad())
                case .onePortraitIpadStars: tmp.append(PortraitScreenshotSearchCellWithStarsiPad())
                case .oneLandscapeIphone: tmp.append(LandscapeScreenshotSearchCelliPhone())
                case .oneLandscapeIphoneStars: tmp.append(LandscapeScreenshotSearchCellWithStarsiPhone())
                case .oneLandscapeIpad: tmp.append(LandscapeScreenshotSearchCelliPad())
                case .oneLandscapeIpadStars: tmp.append(LandscapeScreenshotSearchCellWithStarsiPad())
                case .twoPortraitIphone: tmp.append(TwoPortraitScreenshotsSearchCelliPhone())
                case .twoPortraitIphoneStars: tmp.append(TwoPortraitScreenshotsSearchCellWithStarsiPhone())
                case .twoPortraitIpad: tmp.append(TwoPortraitScreenshotsSearchCelliPad())
                case .twoPortraitIpadStars: tmp.append(TwoPortraitScreenshotsSearchCellWithStarsiPad())
                case .threePortraitIphone: tmp.append(ThreePortraitScreenshotsSearchCelliPhone())
                case .threePortraitIphoneStars: tmp.append(ThreePortraitScreenshotsSearchCellWithStarsiPhone())
                case .threePortraitIpad: tmp.append(ThreePortraitScreenshotsSearchCelliPad())
                case .threePortraitIpadStars: tmp.append(ThreePortraitScreenshotsSearchCellWithStarsiPad())
                case .mixedOneIphone: tmp.append(MixedScreenshotsSearchCellOneiPhone())
                case .mixedOneIphoneStars: tmp.append(MixedScreenshotsSearchCellOneWithStarsiPhone())
                case .mixedOneIpad: tmp.append(MixedScreenshotsSearchCellOneiPad())
                case .mixedOneIpadStars: tmp.append(MixedScreenshotsSearchCellOneWithStarsiPad())
                case .mixedTwoIphone: tmp.append(MixedScreenshotsSearchCellTwoiPhone())
                case .mixedTwoIphoneStars: tmp.append(MixedScreenshotsSearchCellTwoWithStarsiPhone())
                case .mixedTwoIpad: tmp.append(MixedScreenshotsSearchCellTwoiPad())
                case .mixedTwoIpadStars: tmp.append(MixedScreenshotsSearchCellTwoWithStarsiPad())
                }
            }
            if tmp.isEmpty {
                if page == 1 {
                    delay(0.3) {
                        self.state = .error(first: "No results found".localized(),
                                            second: "No results were found for '%@'".localizedFormat(query),
                                            animated: true)
                    }
                } else {
                    self.collectionView.spr_endRefreshingWithNoMoreData()
                }
            } else {
                if page > 1 {
                    self.resultCells += tmp
                    self.collectionView.spr_endRefreshing()
                    self.collectionView.reloadData()
                } else {
                    delay(0.3) {
                        self.resultCells = tmp
                        self.switchLayout(phase: .showResults, animated: true, reload: true)
                        if tmp.count < 25 {
                             self.collectionView.spr_endRefreshingWithNoMoreData()
                        }
                    }
                }
            }
        }, fail: { error in
            delay(0.3) {
                self.state = .error(first: "Cannot connect".localized(), second: error, animated: true)
            }
        })
    }

    enum CellType {
        case none, noneBook, noneBookStars, // No screenshots

        // iPhone screenshots
        onePortraitIphone, onePortraitIphoneStars, oneLandscapeIphone, oneLandscapeIphoneStars,
        twoPortraitIphone, twoPortraitIphoneStars, threePortraitIphone, threePortraitIphoneStars,
        mixedOneIphone, mixedOneIphoneStars, mixedTwoIphone, mixedTwoIphoneStars,

        // iPad screenshots
        onePortraitIpad, onePortraitIpadStars, oneLandscapeIpad, oneLandscapeIpadStars,
        twoPortraitIpad, twoPortraitIpadStars, threePortraitIpad, threePortraitIpadStars,
        mixedOneIpad, mixedOneIpadStars, mixedTwoIpad, mixedTwoIpadStars
    }

    func detectScreenshotsOrder(from item: Item) -> CellType {
        if item is Book {
            return item.itemHasStars ? .noneBookStars : .noneBook
        } else if item is App || item is CydiaApp {
            var isIpad = false
            var screenshots: [Screenshot] = []
            if item.itemScreenshotsIpad.isEmpty {
                isIpad = false
                screenshots = item.itemScreenshotsIphone
            } else if item.itemScreenshotsIphone.isEmpty {
                isIpad = true
                screenshots = item.itemScreenshotsIpad
            } else {
                if Global.isIpad {
                    isIpad = true
                    screenshots = item.itemScreenshotsIpad
                } else {
                    isIpad = false
                    screenshots = item.itemScreenshotsIphone
                }
            }
            switch screenshots.count {
            case 0: return .none
            case 1:
                if screenshots.first!.class_ == "landscape" {
                    if item.itemHasStars {
                        return (isIpad ? .oneLandscapeIpadStars : .oneLandscapeIphoneStars)
                    } else {
                        return (isIpad ? .oneLandscapeIpad : .oneLandscapeIphone)
                    }
                } else {
                    if item.itemHasStars {
                        return (isIpad ? .onePortraitIpadStars : .onePortraitIphoneStars)
                    } else {
                        return (isIpad ? .onePortraitIpad : .onePortraitIphone)
                    }
                }
            case 2:
                if screenshots.first!.class_ == "portrait" {
                    if screenshots[1].class_ == "portrait" {
                        if item.itemHasStars {
                            return (isIpad ? .twoPortraitIpadStars : .twoPortraitIphoneStars)
                        } else {
                            return (isIpad ? .twoPortraitIpad : .twoPortraitIphone)
                        }
                    } else {
                        if item.itemHasStars {
                            return (isIpad ? .mixedTwoIpadStars : .mixedTwoIphoneStars)
                        } else {
                            return (isIpad ? .mixedTwoIpad : .mixedTwoIphone)
                        }
                    }
                } else {
                    if screenshots[1].class_ == "portrait" {
                        if item.itemHasStars {
                            return (isIpad ? .mixedOneIpadStars : .mixedOneIphoneStars)
                        } else {
                            return (isIpad ? .mixedOneIpad : .mixedOneIphone)
                        }
                    } else {
                        if item.itemHasStars {
                            return (isIpad ? .oneLandscapeIpadStars : .oneLandscapeIphoneStars)
                        } else {
                            return (isIpad ? .oneLandscapeIpad : .oneLandscapeIphone)
                        }
                    }
                }
            default:
                if screenshots.first!.class_ == "portrait", screenshots[1].class_ == "portrait", screenshots[2].class_ == "portrait" {
                    if item.itemHasStars {
                        return (isIpad ? .threePortraitIpadStars : .threePortraitIphoneStars)
                    } else {
                        return (isIpad ? .threePortraitIpad : .threePortraitIphone)
                    }
                } else {
                    if screenshots.first!.class_ == "portrait" {
                        if screenshots[1].class_ == "portrait" {
                            if item.itemHasStars {
                                return (isIpad ? .twoPortraitIpadStars : .twoPortraitIphoneStars)
                            } else {
                                return (isIpad ? .twoPortraitIpad : .twoPortraitIphone)
                            }
                        } else {
                            if item.itemHasStars {
                                return (isIpad ? .mixedTwoIpadStars : .mixedTwoIphoneStars)
                            } else {
                                return (isIpad ? .mixedTwoIpad : .mixedTwoIphone)
                            }
                        }
                    } else {
                        if screenshots[1].class_ == "portrait" {
                            if item.itemHasStars {
                                return (isIpad ? .mixedOneIpadStars : .mixedOneIphoneStars)
                            } else {
                                return (isIpad ? .mixedOneIpad : .mixedOneIphone)
                            }
                        } else {
                            if item.itemHasStars {
                                return (isIpad ? .oneLandscapeIpadStars : .oneLandscapeIphoneStars)
                            } else {
                                return (isIpad ? .oneLandscapeIpad : .oneLandscapeIphone)
                            }
                        }
                    }
                }
            }
        } else {
            return .none
        }
    }
}

////////////////////////////////
//  PROTOCOL IMPLEMENTATIONS  //
////////////////////////////////

// MARK: - ETCollectionViewDelegateWaterfallLayout

extension Search: ETCollectionViewDelegateWaterfallLayout {
    var itemDimension: CGFloat {
        if Global.isIpad {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return (view.bounds.width / 2) - margin * 1.5
            } else {
                return (view.bounds.width / 3) - margin * 1.5
            }
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return view.bounds.width - margin * 2
            } else {
                return (view.bounds.width / 2) - margin * 1.5
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        guard resultCells.indices.contains(indexPath.row) else { return .zero }
        return CGSize(width: itemDimension, height: resultCells[indexPath.row].height)
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension Search {

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard currentPhase == .showResults else { return nil }
         guard results.indices.contains(indexPath.row) else { return nil }
        let item = results[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: { Details(content: item) })
    }

    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
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

    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard let indexPath = configuration.identifier as? IndexPath else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        if let collectionViewCell = collectionView.cellForItem(at: indexPath) {
            return UITargetedPreview(view: collectionViewCell.contentView, parameters: parameters)
        }

        return nil
    }
}

// MARK: - 3D Touch Peek and Pop on results

extension Search: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard currentPhase == .showResults else { return nil }
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        guard  let cell = collectionView.cellForItem(at: indexPath) else { return nil }
        guard results.indices.contains(indexPath.row) else { return nil }
        previewingContext.sourceRect = cell.frame
        let item = results[indexPath.row]
        let vc = Details(content: item)
        return vc
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

// MARK: - Tapped on a tag

extension Search: TagListViewDelegate {
    func tagPressed(_ title: String) {
        actuallySearch(with: title)
    }
}

// MARK: - Redirect to results after clicking a suggestion

extension Search: SearcherDelegate {
    func didClickSuggestion(_ text: String) {
        actuallySearch(with: text)
    }
}

// MARK: - Workaround: Table view controller used inside a popover used to select
// content type (ios, cydia, books) only on iOS 9/10 because scope bar is too buggy

extension Search: UIPopoverPresentationControllerDelegate, SearchDidSelectTypeProtocol {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        guard let updateSuggestions = searchController.searchResultsController as? SuggestionsWhileTyping else { return }
        var type: Int = 0
        if updateSuggestions.type == .cydia { type = 1 }
        if updateSuggestions.type == .books { type = 2 }
        let vc = SmallTableViewController()
        vc.delegate = self
        vc.selectedType = type
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 120, height: 120)
        if let popover = vc.popoverPresentationController {
            popover.permittedArrowDirections = .up
            popover.delegate = self
            popover.sourceView = searchBar
            popover.theme_backgroundColor = Color.popoverArrowColor
            let offset: CGFloat = !Global.isIpad && searchController.isActive ? 115 : 15
            popover.sourceRect = CGRect(origin: CGPoint(x: searchBar.frame.size.width - offset, y: -20), size: CGSize(width: 50, height: 50))
        }
        present(vc, animated: true, completion: nil)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }

    func selectedTypeWithIndex(_ index: Int) {
        searchBar(searchController.searchBar, selectedScopeButtonIndexDidChange: index)
        if currentPhase != .showTrending {
            actuallySearch(with: searchController.searchBar.text ?? "")
        }
    }
}

protocol SearchDidSelectTypeProtocol: AnyObject {
    func selectedTypeWithIndex(_ index: Int)
}

class SmallTableViewController: UITableViewController {
    var selectedType: Int = 0
    weak var delegate: SearchDidSelectTypeProtocol?

    lazy var bgColorView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Color.cellSelectionColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        tableView.rowHeight = 40
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.theme_separatorColor = Color.borderColor

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Show full separator
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        switch indexPath.row {
        case 0: cell.textLabel?.text = "iOS".localized()
        case 1: cell.textLabel?.text = "Cydia".localized()
        default: cell.textLabel?.text = "Books".localized()
        }
        cell.accessoryType = indexPath.row == selectedType ? .checkmark : .none
        cell.setBackgroundColor(Color.veryVeryLightGray)
        cell.theme_backgroundColor = Color.veryVeryLightGray
        cell.textLabel?.theme_textColor = Color.title
        cell.selectedBackgroundView = bgColorView
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: selectedType = 0
        case 1: selectedType = 1
        default: selectedType = 2
        }
        delegate?.selectedTypeWithIndex(selectedType)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
