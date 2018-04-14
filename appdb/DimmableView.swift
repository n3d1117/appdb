//
//  DimmableView
//  appdb
//
//  Created by ned on 21/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import UIKit

/*
 *
 * USAGE FOR FUTURED NED
 * This is bad. I know it. It's late and I can't think of anything else.
 *
 * USAGE:
 * - Declare a dim view like this --> var dim: UIView = DimmableView.get()
 * - Set radius if needed
 * - Add as a subview
 * - Set its frame
 * - use --> dim.layer.opacity = DimmableView.opacity <-- somewhere to darken!
 * - use --> dim.layer.opacity = 0 <-- to undarken!
 *
 */

struct DimmableView {
    static func get() -> UIView {
        let dim = UIView()
        dim.layer.opacity = 0
        dim.backgroundColor = .black
        return dim
    }
    
    static let opacity: Float = 0.3
}
