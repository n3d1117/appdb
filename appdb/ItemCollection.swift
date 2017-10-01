//
//  ItemCollection.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import RealmSwift

// Class to handle response correctly from Featured
struct ItemResponse {
    var success : Bool = false
    var errorDescription : String = ""
}

extension ItemCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        if let app = item as? App {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as! FeaturedApp
            cell.title.text = app.name.decoded
            if let cat = app.category { cell.category.text  = cat.name.isEmpty ? "Unknown".localized() : cat.name
            } else { cell.category.text = "Unknown".localized() }
            if let url = URL(string: app.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let cydiaApp = item as? CydiaApp {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cydia", for: indexPath) as! FeaturedApp
            cell.title.text = cydiaApp.name.decoded
            cell.tweaked = cydiaApp.isTweaked
            cell.category.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia)
            if let url = URL(string: cydiaApp.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let book = item as? Book {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! FeaturedBook
            cell.title.text = book.name.decoded
            cell.author.text = book.author
            if let url = URL(string: book.image) {
                cell.cover.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pushDetailsController(with: items[indexPath.row])
    }
    
}

class ItemCollection: FeaturedCell {
    
    // Adjust title space and category if content size category did change
    let group = ConstraintGroup()
    var didSetConstraints = false

    // UI Elements
    var collectionView: UICollectionView!
    var sectionLabel: UILabel!
    var categoryLabel: PaddingLabel!
    var seeAllButton: UIButton!
    
    // Array to fill data with
    var items: [Object] = []
    
    var showFullSeparator: Bool = false
    
    // Response object
    var response : ItemResponse = ItemResponse()
    
    // Redirect to Details view
    var delegate: ContentRedirection? = nil
    
    // Open Featured's Categories view controller
    var delegateCategory: ChangeCategory? = nil
    
    deinit { NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil) }

    convenience init(id: Featured.CellType, title: String, fullSeparator: Bool = false) {
        
        self.init(style: .default, reuseIdentifier: id.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(ItemCollection.updateTextSize), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        showFullSeparator = fullSeparator
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        
        let layout = SnappableFlowLayout(width: Global.size.itemWidth.value, spacing: Global.size.spacing.value)
        if let id = Featured.CellType(rawValue: reuseIdentifier!) {
            if Featured.iosTypes.contains(id) { layout.itemSize = Global.sizeIos } else { layout.itemSize = Global.sizeBooks }
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: Global.size.margin.value, bottom: 0, right: Global.size.margin.value)
        layout.minimumLineSpacing = Global.size.spacing.value
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "app")
        collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "cydia")
        collectionView.register(FeaturedBook.self, forCellWithReuseIdentifier: "book")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        
        collectionView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        sectionLabel = UILabel()
        sectionLabel.theme_textColor = Color.title
        
        if #available(iOS 8.2, *) {
            sectionLabel.font = .systemFont(ofSize: 16.5, weight: UIFont.Weight.medium)
        } else {
            sectionLabel.font = .systemFont(ofSize: 16.5)
        }
        
        sectionLabel.text = title
        sectionLabel.sizeToFit()
        
        categoryLabel  = PaddingLabel()
        categoryLabel.theme_textColor = Color.invertedTitle
        if #available(iOS 8.2, *) {
            categoryLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        } else {
            categoryLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
        }
        categoryLabel.layer.backgroundColor = UIColor.gray.cgColor
        categoryLabel.layer.cornerRadius = 6
        categoryLabel.isHidden = true
        categoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openFeaturedCategories)))
        categoryLabel.makeDynamicFont()
        
        seeAllButton = ButtonFactory.createChevronButton(text: "See All".localized(), color: Color.darkGray)

        contentView.addSubview(categoryLabel)
        contentView.addSubview(sectionLabel)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(collectionView)

        setConstraints()
        requestItems()

    }
    
    @objc fileprivate func openFeaturedCategories(_ sender: AnyObject) { delegateCategory?.openCategories(sender) }
    
    // MARK: - Change Content Size for sectionLabel
    @objc fileprivate func updateTextSize(notification: NSNotification) {
        let preferredSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
        let fontSizeToSet = preferredSize > 20.0 ? 20.0 : preferredSize
        if #available(iOS 8.2, *) {
            sectionLabel.font = .systemFont(ofSize: fontSizeToSet, weight: UIFont.Weight.medium)
        } else {
            sectionLabel.font = .systemFont(ofSize: fontSizeToSet)
        }
        sectionLabel.sizeToFit()
        didSetConstraints = false
        setConstraints()
    }
    
    // MARK: - Constraints
    
    fileprivate func setConstraints() {
        if !didSetConstraints { didSetConstraints = true
            constrain(sectionLabel, categoryLabel, seeAllButton, collectionView, replace: group) { section, category, seeAll, collection in
                collection.left == collection.superview!.left
                collection.right == collection.superview!.right
                collection.top == collection.superview!.top + (44~~39)
                collection.bottom == collection.superview!.bottom
            
                section.left == section.superview!.left + Global.size.margin.value
                section.right == section.left + sectionLabel.frame.size.width ~ Global.notMaxPriority
                section.bottom == collection.top - (44~~39 - section.height.view.bounds.height) / 2
        
                seeAll.right == seeAll.superview!.right - Global.size.margin.value
                seeAll.centerY == section.centerY
                
                category.left == section.right + 8
                category.right <= seeAll.left - 8
                category.centerY == section.centerY
            }
            separatorInset.left = showFullSeparator ? 0 : Global.size.margin.value
            layoutMargins.left = showFullSeparator ? 0 : Global.size.margin.value
        }
    }
    
    // MARK: - Networking
    
    func requestItems() {
        self.response.success = false; self.response.errorDescription = ""
        if let id = reuseIdentifier {
            if let type = Featured.CellType(rawValue: id) {
                switch type {
                    case .cydia: getItems(type: CydiaApp.self, order: .added)
                    case .iosNew: getItems(type: App.self, order: .added)
                    case .iosPaid: getItems(type: App.self, order: .month, price: .paid)
                    case .iosPopular: getItems(type: App.self, order: .week, price: .free)
                    case .books: getItems(type: Book.self, order: .month)
                    default: break
                }
            }
        }
    }
    
    func getItems <T:Object>(type: T.Type, order: Order, price: Price = .all, genre: String = "0") -> Void where T:Mappable, T:Meta {
        API.search(type: type, order: order, price: price, genre: genre, success: { array in
            
            let diff = Dwifft.diff(self.items, array)
            if diff.count > 0 {
                self.collectionView.performBatchUpdates({
                    self.items = array
                    for result in diff {
                        switch result {
                            case let .delete(row, _): self.collectionView.deleteItems(at: [IndexPath(row: row, section: 0)])
                            case let .insert(row, _): self.collectionView.insertItems(at: [IndexPath(row: row, section: 0)])
                        }
                    }
                }, completion: nil)
            }
            
            // Fix rare issue where first three Cydia items would not load category text - probs not fixed
            if !self.items.isEmpty, Global.firstLaunch { self.dirtyFixEmptyCategory() }
            
            // Update category label
            if genre != "0", let type = ItemType(rawValue: T.type().rawValue) {
                self.categoryLabel.text = API.categoryFromId(id: genre, type: type).uppercased()
                self.categoryLabel.isHidden = false
                self.categoryLabel.isUserInteractionEnabled = true
            } else {
                self.categoryLabel.text = ""
                self.categoryLabel.isHidden = true
            }
                 
            // Success and no errors
            self.response.success = true
        
        }, fail: { error in
            self.response.errorDescription = error.prettified
        })
    }
    
    // Fixes rare issue where first three Cydia items would not load category text.
    // Reloading text after 0.3 seconds, seems to work (tested on iPad Mini 2) - not working for all devices

    fileprivate func dirtyFixEmptyCategory() {
        if self.items[0] is CydiaApp {
            delay(0.3) { for i in 0..<3 {
                if let cell = self.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? FeaturedApp {
                    if cell.category.text == "", let cydiaApp = self.items[i] as? CydiaApp {
                        cell.category.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia)
                    }
                }
            } }
        }
    }
    
    // MARK: - Reload items after category change
    
    func reloadAfterCategoryChange(id: String, type: ItemType) {
        if let identifier = reuseIdentifier {
            switch type {
            case .ios:
                switch Featured.CellType(rawValue: identifier)! {
                    case .iosNew: getItems(type: App.self, order: .added, genre: id)
                    case .iosPaid: getItems(type: App.self, order: .month, price: .paid, genre: id)
                    case .iosPopular: getItems(type: App.self, order: .week, price: .free, genre: id)
                    default: break
                }
            case .cydia:
                switch Featured.CellType(rawValue: identifier)! {
                    case .cydia: getItems(type: CydiaApp.self, order: .added, genre: id)
                    default: break
                }
            case .books:
                switch Featured.CellType(rawValue: identifier)! {
                    case .books: getItems(type: Book.self, order: .month, genre: id)
                    default: break
                }
            }
        }
    }

}
