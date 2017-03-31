//
//  Details+SegmentControl.swift
//  appdb
//
//  Created by ned on 05/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography

protocol SwitchDetailsSegmentDelegate {
    func segmentSelected(_ state: detailsSelectedSegmentState)
}

enum detailsSelectedSegmentState: String {
    case details = "Details"
    case reviews = "Reviews"
    case download = "Download"
}

class DetailsSegmentControl: TableViewHeader {
    
    var shouldBeTranslucent: Bool = false {
        willSet {
            if newValue != shouldBeTranslucent {
                if newValue {
                    translucentView.backgroundColor = .clear
                    translucentView.translucentAlpha = 1
                } else {
                    translucentView.theme_backgroundColor = Color.veryVeryLightGray
                    translucentView.translucentAlpha = 0
                }
            }
        }
    }
    
    var translucentView: ILTranslucentView!
    var segment: UISegmentedControl!
    var items: [detailsSelectedSegmentState] = []
    var delegate: SwitchDetailsSegmentDelegate? = nil
    
    func index(for state: detailsSelectedSegmentState) -> Int {
        switch state {
            case .details: return 0
            case .reviews: return 1
            case .download: return items.contains(.reviews) ? 2 : 1
        }
    }
    
    static var height: CGFloat { return 40 }
    
    convenience init(_ items: [detailsSelectedSegmentState], state: detailsSelectedSegmentState, enabled: Bool, delegate: SwitchDetailsSegmentDelegate) {
        self.init(frame: .zero)
        
        self.items = items
        self.delegate = delegate

        preservesSuperviewLayoutMargins = false
        layoutMargins.left = 0
        contentView.backgroundColor = .clear
        addSeparator(full: true)
        
        segment = UISegmentedControl(items: self.items.flatMap{$0.rawValue.localized()})
        segment.selectedSegmentIndex = index(for: state)
        segment.addTarget(self, action: #selector(self.indexDidChange), for: .valueChanged)
        segment.theme_tintColor = Color.informationParameter
        translucentView = ILTranslucentView(frame: .zero)
        translucentView.theme_backgroundColor = Color.veryVeryLightGray
        translucentView.translucentTintColor = .clear
        translucentView.translucentAlpha = 0
        setLinksEnabled(enabled)
        
        translucentView.addSubview(segment)
        contentView.addSubview(translucentView)
        
        constrain(translucentView, segment) { translucentView, segment in
            translucentView.edges == translucentView.superview!.edges
            
            segment.top == translucentView.top + 7
            segment.bottom == translucentView.bottom - 7 ~ 999.0
            segment.centerX == translucentView.centerX
            
            if items.contains(.reviews) {
                if IS_IPAD {
                    segment.width == 380
                } else {
                    segment.left == segment.superview!.left + Featured.size.margin.value + 5 ~ 999.0
                    segment.right == segment.superview!.right - Featured.size.margin.value - 5 ~ 999.0
                }
            } else {
                segment.width == (280~~250)
            }
        }
        
    }
    
    func indexDidChange() {
        delegate?.segmentSelected(items[segment.selectedSegmentIndex])
    }
    
    func setLinksEnabled(_ enabled: Bool) {
        guard let index = items.index(of: .download) else { return }
        segment.setEnabled(enabled, forSegmentAt: index)
    }
    
}
