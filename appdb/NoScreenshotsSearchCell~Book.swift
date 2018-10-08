//
//  NoScreenshotsSearchCell~Book.swift
//  appdb
//
//  Created by ned on 05/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift

class NoScreenshotsSearchCellBook: SearchCell {
    
    override var identifier: String { return "noscreenshotscellbook" }
    override var height: CGFloat { return coverHeight + margin*2 }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func configure(with item: Object) {
        self.name.text = item.itemName
        self.name.numberOfLines = 3
        self.seller.text = item.itemSeller
        guard let url = URL(string: item.itemIconUrl) else { return }
        icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.sharedSetup()
        
        constrain(icon) { icon in
            icon.height == coverHeight
            icon.bottom == icon.superview!.bottom - margin
        }
    }
}
