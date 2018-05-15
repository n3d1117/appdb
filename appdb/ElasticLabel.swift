//
//  ElasticLabel.swift
//  appdb
//
//  Created by ned on 04/08/2017.
//  Copyright © 2017 ned. All rights reserved.

//

import UIKit
import SwiftTheme

protocol ElasticLabelDelegate: class {
    func expand(_ label: ElasticLabel)
}

class ElasticLabel: UILabel {
    
    weak var delegated: ElasticLabelDelegate?
    var maxNumberOfCollapsedLines: Int = 5
    var collapsed: Bool = true { didSet { numberOfLines = collapsed ? maxNumberOfCollapsedLines : 0 } }
    var recognizer: UITapGestureRecognizer!
    var expandedText: String! = ""
    
    var moreTextColor = ["#4E7DD0", "#649EE6"]
    
    open override var text: String? {
        didSet {
            if let text = text, text != "", collapsed {
                layoutIfNeeded()
                addTrailingIfNeeded(moreText: "more".localized(), ellipses: "...")
            }
        }
    }
    
    convenience init() { self.init(text: "", delegate: nil) }
    
    convenience init(text: String, delegate: ElasticLabelDelegate? = nil) {
        self.init(frame: .zero)
        
        self.text = text
        if let delegate = delegate { self.delegated = delegate }
        
        font = .systemFont(ofSize: (13.5~~12.5))
        contentMode = .top
        textAlignment = .left
        isUserInteractionEnabled = true
        collapsed = true
        
        recognizer = UITapGestureRecognizer(target: self, action: #selector(self.expand))
        recognizer.numberOfTouchesRequired = 1
        
    }
    
    // Replaces text with collapsed text, adds "... more" to the end
    func addTrailingIfNeeded(moreText: String, ellipses: String) {
        
        if !((self.gestureRecognizers ?? []).contains(self.recognizer)) { self.addGestureRecognizer(self.recognizer) }
        expandedText = text
        
        let trailing = " " + "more".localized()
        guard let text = text, !text.isEmpty else { return }
        
        let size = CGSize(width: bounds.size.width, height: ceil(font!.lineHeight * CGFloat(maxNumberOfCollapsedLines)))
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: textColor!, NSAttributedStringKey.font: font!]
        let trailingAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: (Themes.isNight ? UIColor(rgba: moreTextColor[0]) : UIColor(rgba: moreTextColor[1])), NSAttributedStringKey.font: font!]
        
        self.attributedText = text.truncateToSize(size: size, ellipses: ellipses, trailingText: trailing, attributes: attributes, trailingAttributes: trailingAttributes)
    }
    
    // Replaces collapsed text with expanded text, removes any attributed text
    func removeTrailing() {
        if (self.gestureRecognizers ?? []).contains(recognizer) { removeGestureRecognizer(recognizer) }
        collapsed = false
        attributedText = nil
        text = expandedText
    }
    
    @objc private func expand() {
        removeTrailing()
        delegated?.expand(self)
    }
    
}
