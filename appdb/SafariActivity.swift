//
//  SafariActivity.swift
//  appdb
//
//  Created by ned on 01/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

public extension UIActivityType {
    static let openInSafari = UIActivityType(rawValue: "it.ned.appdb.openInSafari")
}

public class SafariActivity: UIActivity {
    
    var urlToOpen: URL?
    
    var foundURL: URL? {
        didSet {
            urlToOpen = foundURL
        }
    }
    
    public override var activityTitle: String? {
        return "Open in Safari".localized()
    }
    
    public override var activityType: UIActivityType? {
        return UIActivityType.openInSafari
    }
    
    public override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "icon_safari")
    }
    
    var canOpen: (Any) -> Bool = { item in
        return item is URL && UIApplication.shared.canOpenURL(item as! URL)
    }
    
    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return activityItems.contains(where: canOpen)
    }
    
    public override func prepare(withActivityItems activityItems: [Any]) {
        foundURL = activityItems.first(where: canOpen) as? URL
    }
    
    public override func perform() {
        guard let url = urlToOpen else {
            activityDidFinish(false)
            return
        }
        activityDidFinish(UIApplication.shared.openURL(url))
    }
}
