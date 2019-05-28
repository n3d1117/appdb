//
//  SnappableFlowLayout
//  appdb
//
//  Created by ned on 22/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

class SnappableFlowLayout: UICollectionViewFlowLayout {
    
    var width: CGFloat!
    var spacing: CGFloat!
    var magic: CGFloat!

    convenience init(width: CGFloat, spacing: CGFloat, magic: CGFloat = 120) {
        self.init()
        self.width = width
        self.spacing = spacing
        self.magic = magic
    }

    func updateWidth(_ width: CGFloat) {
        self.width = width
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if width > 0 {
            let targetX: CGFloat = collectionView!.contentOffset.x + velocity.x * magic
            var targetIndex: CGFloat = round(targetX / (width + spacing))
            if velocity.x > 0 {
                targetIndex = ceil(targetX / (width + spacing))
            } else {
                targetIndex = floor(targetX / (width + spacing))
            }
            return CGPoint(x: targetIndex * (width + spacing), y: proposedContentOffset.y)
        }

        return proposedContentOffset
    }
}
