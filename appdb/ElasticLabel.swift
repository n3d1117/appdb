//
//  ElasticLabel.swift
//  appdb
//
//  Created by ned on 24/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit

protocol ElasticLabelDelegate {
    func expand(_ label: ElasticLabel)
}

class ElasticLabel: UILabel {
    
    var delegated: ElasticLabelDelegate?

    var collapsed: Bool = true {
        didSet {
            numberOfLines = collapsed ? 5 : 0
        }
    }
    
    convenience init(text: String, delegate: ElasticLabelDelegate? = nil) {
        self.init(frame: .zero)

        self.text = text
        if let delegate = delegate { self.delegated = delegate }
        
        font = .systemFont(ofSize: (13~~12))
        textAlignment = .left
        lineBreakMode = .byTruncatingTail
        isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.expand))
        recognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(recognizer)
        
    }
    
    convenience init() {
        self.init(text: "", delegate: nil)
    }
    
    @objc private func expand() {
        delegated?.expand(self)
    }
    
}
