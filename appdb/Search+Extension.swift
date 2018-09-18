//
//  Search+Extension.swift
//  appdb
//
//  Created by ned on 11/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit
import RealmSwift
import ObjectMapper
import Cartography

extension Search {
    
    enum Phase {
        case showTrending, showSuggestions, loading, loaded, none
    }
    
    enum ScreenshotsOrder {
        case none,
        onePortrait_iphone, oneLandscape_iphone, twoPortrait_iphone, threePortrait_iphone, mixedOne_iphone, mixedTwo_iphone,
        onePortrait_ipad, oneLandscape_ipad, twoPortrait_ipad, threePortrait_ipad, mixedOne_ipad, mixedTwo_ipad
    }
    
    func detectScreenshotsOrder(from item: Object) -> ScreenshotsOrder {
        if item is Book { return .none }
        if let app = item as? App {
            var isIpad = false
            var screenshots: [Screenshot] = []
            if app.screenshotsIpad.isEmpty {
                isIpad = false
                screenshots = Array(app.screenshotsIphone)
            } else if app.screenshotsIphone.isEmpty {
                isIpad = true
                screenshots = Array(app.screenshotsIpad)
            } else {
                if IS_IPAD {
                    isIpad = true
                    screenshots = Array(app.screenshotsIpad)
                } else {
                    isIpad = false
                    screenshots = Array(app.screenshotsIphone)
                }
            }
            switch screenshots.count {
            case 0: return .none
            case 1:
                return screenshots.first!.class_ == "landscape" ?
                    (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone) : (isIpad ? .onePortrait_ipad : .onePortrait_iphone)
            case 2:
                if screenshots.first!.class_ == "portrait" {
                    return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone) : (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                } else {
                    return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .mixedOne_ipad : .mixedOne_iphone) : (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                }
            default:
                if screenshots.first!.class_ == "portrait", screenshots[1].class_ == "portrait", screenshots[2].class_ == "portrait" {
                    return (isIpad ? .threePortrait_ipad : .threePortrait_iphone)
                } else {
                    if screenshots.first!.class_ == "portrait" {
                        return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone) : (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                    } else {
                    return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .mixedOne_ipad : .mixedOne_iphone) : (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                    }
                }
            }
        } else if let cydiaApp = item as? CydiaApp {
            var isIpad = false
            var screenshots: [Screenshot] = []
            if cydiaApp.screenshotsIpad.isEmpty {
                isIpad = false
                screenshots = Array(cydiaApp.screenshotsIphone)
            } else if cydiaApp.screenshotsIphone.isEmpty {
                isIpad = true
                screenshots = Array(cydiaApp.screenshotsIpad)
                
            } else {
                if IS_IPAD {
                    isIpad = true
                    screenshots = Array(cydiaApp.screenshotsIpad)
                } else {
                    isIpad = false
                    screenshots = Array(cydiaApp.screenshotsIphone)
                }
            }
            switch screenshots.count {
            case 0: return .none
            case 1:
                return screenshots.first!.class_ == "landscape" ?
                    (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone) : (isIpad ? .onePortrait_ipad : .onePortrait_iphone)
            case 2:
                if screenshots.first!.class_ == "portrait" {
                    return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone) : (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                } else {
                    return screenshots[1].class_ == "portrait" ?
                        (isIpad ? .mixedOne_ipad : .mixedOne_iphone) : (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                }
            default:
                if screenshots.first!.class_ == "portrait", screenshots[1].class_ == "portrait", screenshots[2].class_ == "portrait" {
                    return (isIpad ? .threePortrait_ipad : .threePortrait_iphone)
                } else {
                    if screenshots.first!.class_ == "portrait" {
                        return screenshots[1].class_ == "portrait" ?
                            (isIpad ? .twoPortrait_ipad : .twoPortrait_iphone) : (isIpad ? .mixedTwo_ipad : .mixedTwo_iphone)
                    } else {
                        return screenshots[1].class_ == "portrait" ?
                            (isIpad ? .mixedOne_ipad : .mixedOne_iphone) : (isIpad ? .oneLandscape_ipad : .oneLandscape_iphone)
                    }
                }
            }
        }
        return .none
    }
    
    func searchAndUpdate<T:Object>(_ query: String, type: T.Type) where T:Mappable, T:Meta {
        var tmp: [SearchCell] = []
        API.search(type: type, q: query, success: { items in
            for item in items {
                switch self.detectScreenshotsOrder(from: item) {
                case .none: tmp.append(NoScreenshotsSearchCell())
                case .onePortrait_iphone: tmp.append(PortraitScreenshotSearchCell_iPhone())
                case .onePortrait_ipad: tmp.append(PortraitScreenshotSearchCell_iPad())
                case .oneLandscape_iphone: tmp.append(LandscapeScreenshotSearchCell_iPhone())
                case .oneLandscape_ipad: tmp.append(LandscapeScreenshotSearchCell_iPad())
                case .twoPortrait_iphone: tmp.append(TwoPortraitScreenshotsSearchCell_iPhone())
                case .twoPortrait_ipad: tmp.append(TwoPortraitScreenshotsSearchCell_iPad())
                case .threePortrait_iphone: tmp.append(ThreePortraitScreenshotsSearchCell_iPhone())
                case .threePortrait_ipad: tmp.append(ThreePortraitScreenshotsSearchCell_iPad())
                case .mixedOne_iphone: tmp.append(MixedScreenshotsSearchCellOne_iPhone())
                case .mixedOne_ipad: tmp.append(MixedScreenshotsSearchCellOne_iPad())
                case .mixedTwo_iphone: tmp.append(MixedScreenshotsSearchCellTwo_iPhone())
                case .mixedTwo_ipad: tmp.append(MixedScreenshotsSearchCellTwo_iPad())
                }
            }
            if tmp.isEmpty {
                // todo localize
                self.showErrorMessage(text: "No results found", secondaryText: "No results were found for given string")
            } else {
                self.cells = tmp
            }
        }, fail: { error in
            self.showErrorMessage(text: "An error has occurred".localized(), secondaryText: error)
        })
    }
    
    var itemWidth: CGFloat {
        if IS_IPAD {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return round((view.bounds.width / 2) - 30)
            } else {
                return round((view.bounds.width / 3) - 25)
            }
        } else {
            if UIApplication.shared.statusBarOrientation.isPortrait {
                return round(view.bounds.width - 30)
            } else {
                return round((view.bounds.width / 2) - (HAS_NOTCH ? 70 : 25))
            }
        }
    }
    
    func setup() {
        animated = true
        showsErrorButton = false
        
        let margin = UIApplication.shared.statusBarOrientation.isLandscape  && HAS_NOTCH ? 50 : Global.size.margin.value
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 15
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: Global.size.margin.value, left: margin, bottom: Global.size.margin.value, right: margin)
        layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? (2~~1) : (3~~2)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView!.theme_backgroundColor = Color.tableViewBackgroundColor
        
        view.addSubview(collectionView!)
        
        setConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            guard let layout = self.collectionView?.collectionViewLayout as? ETCollectionViewWaterfallLayout else { return }
            layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? (2~~1) : (3~~2)
            let margin = UIApplication.shared.statusBarOrientation.isLandscape  && HAS_NOTCH ? 50 : Global.size.margin.value
            layout.sectionInset = UIEdgeInsets(top: Global.size.margin.value, left: margin, bottom: Global.size.margin.value, right: margin)
        })
    }
    
    func cellDetection(_ cell: UICollectionViewCell, row: Int) -> UICollectionViewCell {
        if cells[row] is NoScreenshotsSearchCell {
            guard let cell = cell as? NoScreenshotsSearchCell else { return UICollectionViewCell() }
            // cell.configure(with name, seller, icon, stars, screenshots)
            return cell
        } else if cells[row] is TwoPortraitScreenshotsSearchCell_iPhone {
            guard let cell = cell as? TwoPortraitScreenshotsSearchCell_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is TwoPortraitScreenshotsSearchCell_iPad {
            guard let cell = cell as? TwoPortraitScreenshotsSearchCell_iPad else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is ThreePortraitScreenshotsSearchCell_iPhone {
            guard let cell = cell as? ThreePortraitScreenshotsSearchCell_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is ThreePortraitScreenshotsSearchCell_iPad {
            guard let cell = cell as? ThreePortraitScreenshotsSearchCell_iPad else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is LandscapeScreenshotSearchCell_iPhone {
            guard let cell = cell as? LandscapeScreenshotSearchCell_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is LandscapeScreenshotSearchCell_iPad {
            guard let cell = cell as? LandscapeScreenshotSearchCell_iPad else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is PortraitScreenshotSearchCell_iPhone {
            guard let cell = cell as? PortraitScreenshotSearchCell_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is PortraitScreenshotSearchCell_iPad {
            guard let cell = cell as? PortraitScreenshotSearchCell_iPad else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is MixedScreenshotsSearchCellOne_iPhone {
            guard let cell = cell as? MixedScreenshotsSearchCellOne_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is MixedScreenshotsSearchCellOne_iPad {
            guard let cell = cell as? MixedScreenshotsSearchCellOne_iPad else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is MixedScreenshotsSearchCellTwo_iPhone {
            guard let cell = cell as? MixedScreenshotsSearchCellTwo_iPhone else { return UICollectionViewCell() }
            return cell
        } else if cells[row] is MixedScreenshotsSearchCellTwo_iPad {
            guard let cell = cell as? MixedScreenshotsSearchCellTwo_iPad else { return UICollectionViewCell() }
            return cell
        }
        return UICollectionViewCell()
    }
    
}
