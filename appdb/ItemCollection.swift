//
//  BBItemCollection.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography

extension ItemCollection : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = CellType(rawValue: reuseIdentifier!) else { return UICollectionViewCell() }
        switch type {
            case .iosNew, .iosPaid, .iosFree, .cydia:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as! FeaturedApp
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "book", for: indexPath) as! FeaturedBook
                return cell
            default: return UICollectionViewCell()
        }
    }
}

class ItemCollection: FeaturedTableViewCell {
    
    var constraint : NSLayoutConstraint!

    var collectionView : UICollectionView!
    var sectionLabel : UILabel!
    
    // Full separator and section label text
    var variables : FeaturedCellSetUp!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    convenience init(id : CellType, vars : FeaturedCellSetUp) {
        
        self.init(style: .default, reuseIdentifier: id.rawValue)
        self.variables = vars

        NotificationCenter.default.addObserver(self, selector: #selector(ItemCollection.updateTextSize), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.register(FeaturedApp.self, forCellWithReuseIdentifier: "app")
        collectionView.register(FeaturedBook.self, forCellWithReuseIdentifier: "book")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = UIColor.white
        
        sectionLabel = UILabel()
        sectionLabel.textColor = UIColor.black
        sectionLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        sectionLabel.text = variables.sectionLabel
        sectionLabel.sizeToFit()
        
        //Set item size
        switch id {
            case .iosNew, .iosPaid, .iosFree, .cydia: layout.itemSize = common.sizeIos
            case .books: layout.itemSize = common.sizeBooks
            default: break
        }
        
        contentView.addSubview(sectionLabel)
        contentView.addSubview(collectionView)
        
        setConstraints()
    }
    
    func updateTextSize(notification: NSNotification) {
        
        let preferredSize : CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
        let fontSizeToSet = preferredSize > 28.0 ? 26.0 : preferredSize
        
        sectionLabel.font = UIFont.systemFont(ofSize: fontSizeToSet)
        sectionLabel.sizeToFit()
        contentView.removeConstraint(constraint)
        
        constrain(sectionLabel, collectionView) { label, collection in
            constraint = label.bottom == collection.top - (39 - label.height.view.frame.size.height) / 2
        }
    }
    
    func setConstraints() {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            separatorInset.left = variables.fullSeparator ? 0 : common.size.margin.value
            layoutMargins.left = variables.fullSeparator ? 0 : common.size.margin.value
            layout.sectionInset = UIEdgeInsets(top: 0, left: common.size.margin.value, bottom: 0, right: common.size.margin.value)
            layout.minimumLineSpacing = common.size.spacing.value
            
            constrain(sectionLabel, collectionView, contentView) { label, collection, content in
                collection.left == content.left
                collection.right == content.right
                collection.bottom == content.bottom ~ 999
                collection.top == content.top + 39
                label.left == collection.left + common.size.margin.value
                label.right == collection.right - common.size.margin.value
                constraint = label.bottom == collection.top - (39 - label.height.view.frame.size.height) / 2
            }
        }
    }

}
