//
//  BBItemCollection.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import RealmSwift
import ObjectMapper
import Dwifft

// Class to handle response correctly from Featured
class ItemResponse {
    var success : Bool = false
    var errorDescription : String = ""
}

class FlowLayout : UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let cellWidth : CGFloat = Featured.size.itemWidth.value
        let cellSpacing: CGFloat = Featured.size.spacing.value
        let targetX : CGFloat = collectionView!.contentOffset.x + velocity.x * 120.0
        var targetIndex: CGFloat = round(targetX / (cellWidth + cellSpacing))
        if velocity.x > 0 {
            targetIndex = ceil(targetX / (cellWidth + cellSpacing))
        } else {
            targetIndex = floor(targetX / (cellWidth + cellSpacing))
        }

        return CGPoint(x: targetIndex * (cellWidth + cellSpacing), y: proposedContentOffset.y)
    }

}

extension ItemCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        if let app = item as? App {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as! FeaturedApp
            cell.title.text = app.name
            cell.category.text = app.category?.name
            if let url = URL(string: app.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.featured, imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let cydiaApp = item as? CydiaApp {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cydia", for: indexPath) as! FeaturedApp
            cell.title.text = cydiaApp.name
            cell.tweaked = cydiaApp.isTweaked
            cell.category.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia)
            cell.category.adjustsFontSizeToFitWidth = cell.category.text!.characters.count < 13 /* fit 'tweaked apps' */
            if let url = URL(string: cydiaApp.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Filters.featured, imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let book = item as? Book {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! FeaturedBook
            cell.title.text = book.name
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
    
}

class ItemCollection: FeaturedCell  {
    
    // Adjust title space and category if content size category did change
    let group = ConstraintGroup()

    // UI Elements
    var collectionView : UICollectionView!
    var sectionLabel : UILabel!
    var categoryLabel : PaddingLabel!
    var seeAllButton : UIButton!
    
    // Array to fill data with
    var items : [Object] = []
    
    var showFullSeparator : Bool = false
    
    // Response object
    var response : ItemResponse = ItemResponse()

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit { NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil) }

    convenience init(id: Featured.CellType, title: String, fullSeparator: Bool = false) {
        
        self.init(style: .default, reuseIdentifier: id.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(ItemCollection.updateTextSize), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        showFullSeparator = fullSeparator
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
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
            sectionLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: UIFontWeightMedium)
        } else {
            sectionLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        }
        
        sectionLabel.text = title
        sectionLabel.sizeToFit()
        
        categoryLabel  = PaddingLabel()
        categoryLabel.theme_textColor = Color.invertedTitle
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
        categoryLabel.layer.backgroundColor = UIColor.gray.cgColor
        categoryLabel.layer.cornerRadius = 5
        categoryLabel.alpha = 0
        
        seeAllButton = ButtonFactory.createChevronButton(text: "See All", color: Color.darkGray)
        seeAllButton.isEnabled = false

        contentView.addSubview(categoryLabel)
        contentView.addSubview(sectionLabel)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(collectionView)

        setConstraints()
        requestItems()

    }
    
    // MARK: - Change Content Size
    
    func updateTextSize(notification: NSNotification) {
        
        let preferredSize : CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
        let fontSizeToSet = preferredSize > 26.0 ? 24.0 : preferredSize
        
        sectionLabel.font = UIFont.systemFont(ofSize: fontSizeToSet)
        sectionLabel.sizeToFit()

        setConstraints()
    }
    
    func setConstraints() {
        
        let layout: FlowLayout = FlowLayout()
        collectionView.collectionViewLayout = layout
        if let id = Featured.CellType(rawValue: reuseIdentifier ?? "") {
            if Featured.iosTypes.contains(id) { layout.itemSize = Featured.sizeIos } else { layout.itemSize = Featured.sizeBooks }
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: Featured.size.margin.value, bottom: 0, right: Featured.size.margin.value)
        layout.minimumLineSpacing = Featured.size.spacing.value
        separatorInset.left = showFullSeparator ? 0 : Featured.size.margin.value
        layoutMargins.left = showFullSeparator ? 0 : Featured.size.margin.value
        
        constrain(sectionLabel, categoryLabel, seeAllButton, collectionView, replace: group) { section, category, seeAll, collection in
            collection.left == collection.superview!.left
            collection.right == collection.superview!.right
            collection.top == collection.superview!.top + (44~~39)
            collection.bottom == collection.superview!.bottom
            
            section.left == section.superview!.left + Featured.size.margin.value
            section.right == section.left + sectionLabel.frame.size.width ~ 999
            
            seeAll.right == seeAll.superview!.right - Featured.size.margin.value
            seeAll.left == seeAll.superview!.right - Featured.size.margin.value - seeAll.width.view.frame.size.width
            seeAll.centerY == section.centerY
            
            section.bottom == collection.top - (44~~39 - section.height.view.frame.size.height) / 2
            category.left == section.right + 8
            
            category.right <= seeAll.left - 8
            category.centerY == section.centerY
        }
    }
    
    // MARK: - Networking
    
    func requestItems() {
        self.response.success = false; self.response.errorDescription = ""
        if let id = reuseIdentifier {
            if let type = Featured.CellType(rawValue: id) {
                
                if Featured.iosTypes.contains(type) { for _ in 0..<25 { self.items.append(App()) } }
                else { for _ in 0..<25 { self.items.append(Book()) } }
                
                switch type {
                    case .cydia: getItems(type: CydiaApp.self, order: .added)
                    case .iosNew: getItems(type: App.self, order: .added)
                    case .iosPaid: getItems(type: App.self, order: .month, price: .paid)
                    case .iosPopular: getItems(type: App.self, order: .day, price: .all)
                    case .iosGames: getItems(type: App.self, order: .all, price: .all, genre: "6014")
                    case .books: getItems(type: Book.self, order: .month)
                    default: break
                }
            }
        }
    }
    
    func getItems <T:Object>(type: T.Type, order: Order, price: Price = .all, genre: String = "0") -> Void where T:Mappable, T:Meta {
        
        API.search(type: type, order: order, price: price, genre: genre, success: { array in
            
            // Success and no errors
            self.response.success = true
            self.seeAllButton.isEnabled = true
            
            if !array.isEmpty {
                let diff = self.items.diff(array)
                
                if diff.results.count > 0 {
                    
                    self.collectionView.performBatchUpdates({
                        
                        self.items = array
                        self.collectionView.deleteItems(at: diff.deletions.map({ IndexPath(item: $0.idx, section: 0) }))
                        self.collectionView.insertItems(at: diff.insertions.map({ IndexPath(item: $0.idx, section: 0) }))
                        
                        // Update category label
                        if genre != "0", let type = ItemType(rawValue: T.type().rawValue) {
                            self.categoryLabel.text = API.categoryFromId(id: genre, type: type).uppercased()
                            self.categoryLabel.alpha = 1
                        } else {
                            self.categoryLabel.text = ""
                            self.categoryLabel.alpha = 0
                        }
            
                    }, completion: nil)
                } else { print("diff is empty... wtf?") }
                
            } else { print("array is empty") }
        
            }, fail: { error in
                //print(error)
                
                self.seeAllButton.isEnabled = false
                
                if error.code == 2 { /* ObjectMapper failed to serialize response, let's ignore it */
                    self.response.success = true // If it's actually reloading a category response is not needed, but fuck it
                } else {
                    self.response.errorDescription = error.localizedDescription
                }
                
            }
        )
    }
    
    // MARK: - Reload items after category change
    
    func reloadAfterCategoryChange(id: String, type: ItemType) {
        if let identifier = reuseIdentifier {
            switch type {
            case .ios:
                switch Featured.CellType(rawValue: identifier)! {
                    case .iosNew: getItems(type: App.self, order: .added, genre: id)
                    case .iosPaid: getItems(type: App.self, order: .week, price: .paid, genre: id)
                    case .iosPopular: getItems(type: App.self, order: .day, price: .all, genre: id)
                    default: break
                }
            case .cydia:
                if Featured.CellType(rawValue: identifier) == .cydia {
                    getItems(type: CydiaApp.self, order: .added, genre: id)
                }
            case .books:
                if Featured.CellType(rawValue: identifier) == .books {
                    getItems(type: Book.self, order: .month, genre: id)
                }
            }
        }
    }

}
