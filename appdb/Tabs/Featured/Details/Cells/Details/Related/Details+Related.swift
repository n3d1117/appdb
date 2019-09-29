//
//  Details+Related.swift
//  appdb
//
//  Created by ned on 22/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage

protocol RelatedRedirectionDelegate: class {
    func relatedItemSelected(trackid: String)
}

extension DetailsRelated: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = relatedContent[indexPath.row]
        switch type {
        case .ios:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as? FeaturedApp else { break }
            cell.title.text = item.name
            cell.category.text = item.artist
            if let url = URL(string: item.icon) {
                cell.icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: (75 ~~ 65)), imageTransition: .crossDissolve(0.2))
            }
            return cell
        case .books:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as? FeaturedBook else { break }
            cell.title.text = item.name
            cell.author.text = item.artist
            if let url = URL(string: item.icon) {
                cell.cover.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
            }
            return cell
        default: break
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedContent.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.relatedItemSelected(trackid: relatedContent[indexPath.row].id)
    }
}

class DetailsRelated: DetailsCell {
    var title: UILabel!
    var collectionView: UICollectionView!
    var relatedContent: [RelatedContent] = []

    weak var delegate: RelatedRedirectionDelegate?

    override var height: CGFloat { return relatedContent.isEmpty ? 0 : (type == .books ? (190 ~~ 165) : (140 ~~ 130)) + (44 ~~ 39) }
    override var identifier: String { return "related" }

    convenience init(type: ItemType, related: [RelatedContent], delegate: RelatedRedirectionDelegate) {
        self.init(style: .default, reuseIdentifier: "related")

        self.type = type
        self.relatedContent = related
        self.delegate = delegate

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        if !relatedContent.isEmpty {
            theme_backgroundColor = Color.veryVeryLightGray
            setBackgroundColor(Color.veryVeryLightGray)

            title = UILabel()
            title.theme_textColor = Color.title
            title.text = type == .books ? "Related Books".localized() : "Related Apps".localized()
            title.font = .systemFont(ofSize: (16 ~~ 15))
            title.makeDynamicFont()

            let layout = SnappableFlowLayout(width: (75 ~~ 65), spacing: Global.Size.spacing.value)
            layout.itemSize = type == .books ? CGSize(width: (75 ~~ 65), height: (175 ~~ 165)) : CGSize(width: (75 ~~ 65), height: (140 ~~ 130))
            layout.sectionInset = UIEdgeInsets(top: 0, left: Global.Size.margin.value, bottom: 0, right: Global.Size.margin.value)
            layout.minimumLineSpacing = Global.Size.spacing.value
            layout.scrollDirection = .horizontal

            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "app")
            collectionView.register(FeaturedBook.self, forCellWithReuseIdentifier: "book")
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.scrollsToTop = false
            collectionView.theme_backgroundColor = Color.veryVeryLightGray
            collectionView.decelerationRate = UIScrollView.DecelerationRate.fast

            contentView.addSubview(title)
            contentView.addSubview(collectionView)

            setConstraints()
        }
    }

    override func setConstraints() {
        constrain(title, collectionView) { title, collection in
            title.top ~== title.superview!.top ~+ 12
            title.left ~== title.superview!.left ~+ Global.Size.margin.value
            title.right ~== title.superview!.right ~- Global.Size.margin.value

            collection.left ~== collection.superview!.left
            collection.right ~== collection.superview!.right
            collection.top ~== collection.superview!.top ~+ (44 ~~ 39)
            collection.bottom ~== collection.superview!.bottom
        }
    }
}
