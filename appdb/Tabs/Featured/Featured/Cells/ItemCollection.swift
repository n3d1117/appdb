//
//  ItemCollection.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import DeepDiff
import AlamofireImage
import ObjectMapper

// Struct to handle response correctly from Featured
struct FeaturedItemCollectionResponse {
    var success: Bool = false
    var errorDescription: String = ""
}

extension ItemCollection: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]

        if let app = item as? App {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as? FeaturedApp else { return UICollectionViewCell() }
            cell.title.text = app.name.decoded
            if let cat = app.category { cell.category.text = cat.name.isEmpty ? "Unknown".localized() : cat.name
            } else { cell.category.text = "Unknown".localized() }
            if let url = URL(string: app.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: Global.Size.itemWidth.value), imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let cydiaApp = item as? CydiaApp {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cydia", for: indexPath) as? FeaturedApp else { return UICollectionViewCell() }
            cell.title.text = cydiaApp.name.decoded
            cell.tweaked = cydiaApp.isTweaked
            cell.category.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia)
            if let url = URL(string: cydiaApp.image) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: Global.Size.itemWidth.value), imageTransition: .crossDissolve(0.2))
            }
            return cell
        }
        if let book = item as? Book {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as? FeaturedBook else { return UICollectionViewCell() }
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
    var items: [Item] = []

    var showFullSeparator: Bool = false

    // Response object
    var response = FeaturedItemCollectionResponse()

    // Redirect to Details view
    weak var delegate: ContentRedirection?

    // Open Featured's Categories view controller
    weak var delegateCategory: ChangeCategory?

    deinit { NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil) }

    convenience init(id: Featured.CellType, title: String, fullSeparator: Bool = false) {
        self.init(style: .default, reuseIdentifier: id.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(ItemCollection.updateTextSize), name: UIContentSizeCategory.didChangeNotification, object: nil)

        showFullSeparator = fullSeparator
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false

        let layout = SnappableFlowLayout(width: Global.Size.itemWidth.value, spacing: Global.Size.spacing.value)
        if let id = Featured.CellType(rawValue: reuseIdentifier!) {
            if Featured.iosTypes.contains(id) { layout.itemSize = Global.sizeIos } else { layout.itemSize = Global.sizeBooks }
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: Global.Size.margin.value, bottom: 0, right: Global.Size.margin.value)
        layout.minimumLineSpacing = Global.Size.spacing.value

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "app")
        collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "cydia")
        collectionView.register(FeaturedBook.self, forCellWithReuseIdentifier: "book")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        collectionView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray

        sectionLabel = UILabel()
        sectionLabel.theme_textColor = Color.title

        sectionLabel.font = .systemFont(ofSize: 16.5, weight: UIFont.Weight.medium)

        sectionLabel.text = title
        sectionLabel.sizeToFit()

        categoryLabel = PaddingLabel()
        categoryLabel.theme_textColor = Color.invertedTitle
        categoryLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .semibold)
        categoryLabel.layer.backgroundColor = UIColor.gray.cgColor
        categoryLabel.layer.cornerRadius = 6
        categoryLabel.isHidden = true
        categoryLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openFeaturedCategories)))
        categoryLabel.makeDynamicFont()

        seeAllButton = ButtonFactory.createChevronButton(text: "See All".localized(), color: Color.darkGray)
        seeAllButton.addTarget(self, action: #selector(self.openSeeAll), for: .touchUpInside)

        contentView.addSubview(categoryLabel)
        contentView.addSubview(sectionLabel)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(collectionView)

        setConstraints()
        requestItems()
    }

    @objc private func openFeaturedCategories(_ sender: AnyObject) { delegateCategory?.openCategories(sender) }

    // MARK: - Change Content Size for sectionLabel
    @objc private func updateTextSize(notification: NSNotification) {
        let preferredSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
        let fontSizeToSet = preferredSize > 20.0 ? 20.0 : preferredSize
        sectionLabel.font = .systemFont(ofSize: fontSizeToSet, weight: UIFont.Weight.medium)
        sectionLabel.sizeToFit()
        didSetConstraints = false
        setConstraints()
    }

    // MARK: - Constraints

    private func setConstraints() {
        if !didSetConstraints { didSetConstraints = true
            constrain(sectionLabel, categoryLabel, seeAllButton, collectionView, replace: group) { section, category, seeAll, collection in
                collection.left ~== collection.superview!.left
                collection.right ~== collection.superview!.right
                collection.top ~== collection.superview!.top ~+ (44 ~~ 39)
                collection.bottom ~== collection.superview!.bottom

                if #available(iOS 11.0, *) {
                    section.left ~== section.superview!.safeAreaLayoutGuide.left ~+ Global.Size.margin.value
                } else {
                    section.left ~== section.superview!.left ~+ Global.Size.margin.value
                }
                (section.right ~== section.left ~+ sectionLabel.frame.size.width) ~ Global.notMaxPriority
                section.bottom ~== collection.top ~- (44 ~~ 39 - section.height.item.bounds.height) / 2

                if #available(iOS 11.0, *) {
                    seeAll.right ~== seeAll.superview!.safeAreaLayoutGuide.right ~- Global.Size.margin.value
                } else {
                    seeAll.right ~== seeAll.superview!.right ~- Global.Size.margin.value
                }
                seeAll.centerY ~== section.centerY
                category.left ~== section.right ~+ 8
                category.right ~<= seeAll.left ~- 8
                category.centerY ~== section.centerY
            }
            separatorInset.left = showFullSeparator ? 0 : Global.Size.margin.value
            layoutMargins.left = showFullSeparator ? 0 : Global.Size.margin.value
        }
    }

    @objc private func openSeeAll() {
        delegate?.pushSeeAllController(title: sectionLabel.text!, type: currentType, category: currentCategory, price: currentPrice, order: currentOrder)
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

    func getItems<T>(type: T.Type, order: Order, price: Price = .all, genre: String = "0") where T: Mappable, T: Item {
        API.search(type: type, order: order, price: price, genre: genre, success: { [weak self] array in
            guard let self = self else { return }

            if self.items.isEmpty {
                self.items = array
                self.collectionView.reloadData()
            } else {
                let changes = diff(old: self.items, new: array)
                self.collectionView.reload(changes: changes, section: 0, updateData: {
                    self.items = array
                })
            }

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

    // MARK: - Reload items after category change

    func reloadAfterCategoryChange(id: String, type: ItemType) {
        if let identifier = reuseIdentifier {
            switch type {
            case .ios:
                currentIosCategory = id
                switch Featured.CellType(rawValue: identifier)! {
                case .iosNew: getItems(type: App.self, order: .added, genre: id)
                case .iosPaid: getItems(type: App.self, order: .month, price: .paid, genre: id)
                case .iosPopular: getItems(type: App.self, order: .week, price: .free, genre: id)
                default: break
                }
            case .cydia:
                currentCydiaCategory = id
                switch Featured.CellType(rawValue: identifier)! {
                case .cydia: getItems(type: CydiaApp.self, order: .added, genre: id)
                default: break
                }
            case .books:
                currentBooksCategory = id
                switch Featured.CellType(rawValue: identifier)! {
                case .books: getItems(type: Book.self, order: .month, genre: id)
                default: break
                }
            default:
                break
            }
        }
    }

    // Current parameters

    private var currentIosCategory: String! = "0"
    private var currentCydiaCategory: String! = "0"
    private var currentBooksCategory: String! = "0"

    private var currentCategory: String {
        switch currentType! {
        case .cydia: return currentCydiaCategory
        case .books: return currentBooksCategory
        default: return currentIosCategory
        }
    }

    private var currentType: ItemType! {
        guard let identifier = reuseIdentifier else { return .ios }
        guard let type = Featured.CellType(rawValue: identifier) else { return .ios }
        switch type {
        case .cydia: return .cydia
        case .books: return .books
        default: return .ios
        }
    }

    private var currentPrice: Price! {
        guard let identifier = reuseIdentifier else { return .all }
        guard let type = Featured.CellType(rawValue: identifier) else { return .all }
        switch type {
        case .iosPaid: return .paid
        case .iosPopular: return .free
        default: return .all
        }
    }

    private var currentOrder: Order! {
        guard let identifier = reuseIdentifier else { return .added }
        guard let type = Featured.CellType(rawValue: identifier) else { return .added }
        switch type {
        case .iosPaid: return .month
        case .iosPopular: return .week
        case .books: return .month
        default: return .added
        }
    }
}
