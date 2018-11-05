//
//  Search+Extension.swift
//  appdb
//
//  Created by ned on 04/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

extension Search {
    
    var leftInset: CGFloat {
        return IS_IPAD ? 25 : 15
    }
    
    var topInset: CGFloat {
        return IS_IPAD ? 25 : 15
    }
    
    var margin: CGFloat {
        return UIApplication.shared.statusBarOrientation.isLandscape && HAS_NOTCH ? 50 : 15
    }
    
    func pushDetailsController(with content: Object) {
        let detailsViewController = Details(content: content)
        if IS_IPAD {
            let nav = DismissableModalNavController(rootViewController: detailsViewController)
            nav.modalPresentationStyle = .formSheet
            navigationController?.present(nav, animated: true)
        } else {
            navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if self.currentPhase != .loading { self.switchLayout(phase: self.currentPhase) }
        })
    }

    func searchAndUpdate<T: Object>(_ query: String = "", page: Int = 1, type: T.Type) where T: Mappable, T: Meta {
        var tmp: [SearchCell] = []
        if page == 1 { results = [] }
        
        self.collectionView.spr_resetNoMoreData()
        
        API.search(type: type, q: query, page: page, success: { items in
            for item in items {
                self.results.append(item)
                
                switch self.detectScreenshotsOrder(from: item) {
                    case .none: tmp.append(NoScreenshotsSearchCell())
                    case .none_book: tmp.append(NoScreenshotsSearchCellBook())
                    case .none_book_stars: tmp.append(NoScreenshotsSearchCellBookWithStars())
                    case .onePortrait_iphone: tmp.append(PortraitScreenshotSearchCell_iPhone())
                    case .onePortrait_iphone_stars:  tmp.append(PortraitScreenshotSearchCell_iPhone())
                    case .onePortrait_ipad: tmp.append(PortraitScreenshotSearchCellWithStars_iPad())
                    case .onePortrait_ipad_stars: tmp.append(PortraitScreenshotSearchCellWithStars_iPad())
                    case .oneLandscape_iphone: tmp.append(LandscapeScreenshotSearchCell_iPhone())
                    case .oneLandscape_iphone_stars: tmp.append(LandscapeScreenshotSearchCellWithStars_iPhone())
                    case .oneLandscape_ipad: tmp.append(LandscapeScreenshotSearchCell_iPad())
                    case .oneLandscape_ipad_stars: tmp.append(LandscapeScreenshotSearchCellWithStars_iPad())
                    case .twoPortrait_iphone: tmp.append(TwoPortraitScreenshotsSearchCell_iPhone())
                    case .twoPortrait_iphone_stars: tmp.append(TwoPortraitScreenshotsSearchCellWithStars_iPhone())
                    case .twoPortrait_ipad: tmp.append(TwoPortraitScreenshotsSearchCell_iPad())
                    case .twoPortrait_ipad_stars: tmp.append(TwoPortraitScreenshotsSearchCellWithStars_iPad())
                    case .threePortrait_iphone: tmp.append(ThreePortraitScreenshotsSearchCell_iPhone())
                    case .threePortrait_iphone_stars: tmp.append(ThreePortraitScreenshotsSearchCellWithStars_iPhone())
                    case .threePortrait_ipad: tmp.append(ThreePortraitScreenshotsSearchCell_iPad())
                    case .threePortrait_ipad_stars: tmp.append(ThreePortraitScreenshotsSearchCellWithStars_iPad())
                    case .mixedOne_iphone: tmp.append(MixedScreenshotsSearchCellOne_iPhone())
                    case .mixedOne_iphone_stars: tmp.append(MixedScreenshotsSearchCellOneWithStars_iPhone())
                    case .mixedOne_ipad: tmp.append(MixedScreenshotsSearchCellOne_iPad())
                    case .mixedOne_ipad_stars: tmp.append(MixedScreenshotsSearchCellOneWithStars_iPad())
                    case .mixedTwo_iphone: tmp.append(MixedScreenshotsSearchCellTwo_iPhone())
                    case .mixedTwo_iphone_stars: tmp.append(MixedScreenshotsSearchCellTwoWithStars_iPhone())
                    case .mixedTwo_ipad: tmp.append(MixedScreenshotsSearchCellTwo_iPad())
                    case .mixedTwo_ipad_stars: tmp.append(MixedScreenshotsSearchCellTwoWithStars_iPad())
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
            
        }) { error in
            delay(0.3) {
                self.state = .error(first: "An error has occurred".localized(), second: error, animated: true)
            }
        }
    }
    
    enum CellType {
        case none, none_book, none_book_stars, // No screenshots
        
        // iPhone screenshots
        onePortrait_iphone, onePortrait_iphone_stars, oneLandscape_iphone, oneLandscape_iphone_stars,
        twoPortrait_iphone, twoPortrait_iphone_stars, threePortrait_iphone, threePortrait_iphone_stars,
        mixedOne_iphone, mixedOne_iphone_stars, mixedTwo_iphone, mixedTwo_iphone_stars,
        
        // iPad screenshots
        onePortrait_ipad, onePortrait_ipad_stars, oneLandscape_ipad, oneLandscape_ipad_stars,
        twoPortrait_ipad, twoPortrait_ipad_stars, threePortrait_ipad, threePortrait_ipad_stars,
        mixedOne_ipad, mixedOne_ipad_stars, mixedTwo_ipad, mixedTwo_ipad_stars
    }
    
    func detectScreenshotsOrder(from item: Object) -> CellType {
        if item is Book {
            return item.itemHasStars ? .none_book_stars : .none_book
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
                if IS_IPAD {
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
                        return (isIpad ? .oneLandscape_ipad_stars : .oneLandscape_iphone_stars)
                    } else {
                        return (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                    }
                } else {
                    if item.itemHasStars {
                        return (isIpad ? .onePortrait_ipad_stars : .onePortrait_iphone_stars)
                    } else {
                        return (isIpad ? .onePortrait_ipad : .onePortrait_iphone)
                    }
                }
            case 2:
                if screenshots.first!.class_ == "portrait" {
                    if screenshots[1].class_ == "portrait" {
                        if item.itemHasStars {
                            return (isIpad ? .twoPortrait_ipad_stars : .twoPortrait_iphone_stars)
                        } else {
                            return (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone)
                        }
                    } else {
                        if item.itemHasStars {
                            return (isIpad ? .mixedTwo_ipad_stars : .mixedTwo_iphone_stars)
                        } else {
                            return (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                        }
                    }
                } else {
                    if screenshots[1].class_ == "portrait" {
                        if item.itemHasStars {
                            return (isIpad ? .mixedOne_ipad_stars : .mixedOne_iphone_stars)
                        } else {
                            return (isIpad ? .mixedOne_ipad : .mixedOne_iphone)
                        }
                    } else {
                        if item.itemHasStars {
                            return (isIpad ? .oneLandscape_ipad_stars : .oneLandscape_iphone_stars)
                        } else {
                            return (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                        }
                    }
                }
            default:
                if screenshots.first!.class_ == "portrait", screenshots[1].class_ == "portrait", screenshots[2].class_ == "portrait" {
                    if item.itemHasStars {
                        return (isIpad ? .threePortrait_ipad_stars : .threePortrait_iphone_stars)
                    } else {
                        return (isIpad ? .threePortrait_ipad : .threePortrait_iphone)
                    }
                } else {
                    if screenshots.first!.class_ == "portrait" {
                        if screenshots[1].class_ == "portrait" {
                            if item.itemHasStars {
                                return (isIpad ? .twoPortrait_ipad_stars : .twoPortrait_iphone_stars)
                            } else {
                                return (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone)
                            }
                        } else {
                            if item.itemHasStars {
                                return (isIpad ? .mixedTwo_ipad_stars : .mixedTwo_iphone_stars)
                            } else {
                                return (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                            }
                        }
                    } else {
                        
                        if screenshots[1].class_ == "portrait" {
                            if item.itemHasStars {
                                return (isIpad ? .mixedOne_ipad_stars : .mixedOne_iphone_stars)
                            } else {
                                return (isIpad ? .mixedOne_ipad : .mixedOne_iphone)
                            }
                        } else {
                            if item.itemHasStars {
                                return (isIpad ? .oneLandscape_ipad_stars : .oneLandscape_iphone_stars)
                            } else {
                                return (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
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
        if IS_IPAD {
            if UIDevice.current.orientation.isPortrait {
                return (view.bounds.width / 2) - 30
            } else {
                return (view.bounds.width / 3) - 25
            }
        } else {
            if UIDevice.current.orientation.isPortrait {
                return view.bounds.width - 30
            } else {
                return (view.bounds.width / 2) - (HAS_NOTCH ? 80 : 25)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        guard resultCells.indices.contains(indexPath.row) else { return .zero }
        return CGSize(width: itemDimension, height: resultCells[indexPath.row].height)
    }
}

// MARK: - 3D Touch Peek and Pop on results

extension Search: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        guard  let cell = collectionView.cellForItem(at: indexPath) else { return nil }
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
            let offset: CGFloat = !IS_IPAD && searchController.isActive ? 115 : 15
            popover.sourceRect = CGRect(origin: CGPoint(x: searchBar.frame.size.width - offset, y: -20), size: CGSize(width: 50, height: 50))
        }
        present(vc, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func selectedTypeWithIndex(_ index: Int) {
        searchBar(searchController.searchBar, selectedScopeButtonIndexDidChange: index)
        if currentPhase != .showTrending {
            actuallySearch(with: searchController.searchBar.text ?? "")
        }
    }
}

protocol SearchDidSelectTypeProtocol {
    func selectedTypeWithIndex(_ index: Int)
}

class SmallTableViewController: UITableViewController {
    
    var selectedType: Int = 0
    var delegate: SearchDidSelectTypeProtocol?
    
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
        return 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        switch indexPath.row {
        case 0: cell.textLabel?.text = "iOS".localized()
        case 1: cell.textLabel?.text = "Cydia".localized()
        default: cell.textLabel?.text = "Books".localized()
        }
        cell.accessoryType = indexPath.row == selectedType ? .checkmark : .none
        cell.contentView.theme_backgroundColor = Color.veryVeryLightGray
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
