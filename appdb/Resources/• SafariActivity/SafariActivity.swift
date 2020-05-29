//
//  SafariActivity.swift
//  appdb
//
//  Created by ned on 01/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import SafariServices
import UIKit

public extension UIActivity.ActivityType {
    static let openInSafari = UIActivity.ActivityType(rawValue: "it.ned.appdb.openInSafari")
}

public class SafariActivity: UIActivity {

    var urlToOpen: URL?

    var foundURL: URL? {
        didSet {
            urlToOpen = foundURL
        }
    }

    public override var activityTitle: String? {
        "Open in Safari".localized()
    }

    public override var activityType: UIActivity.ActivityType? {
        UIActivity.ActivityType.openInSafari
    }

    public override var activityImage: UIImage? {
        #imageLiteral(resourceName: "icon_safari")
    }

    var canOpen: (Any) -> Bool = { item in
        guard let item = item as? URL else { return false }
        return UIApplication.shared.canOpenURL(item)
    }

    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        activityItems.contains(where: canOpen)
    }

    public override func prepare(withActivityItems activityItems: [Any]) {
        foundURL = activityItems.first(where: canOpen) as? URL
    }

    public override func perform() {
        guard let url = urlToOpen else {
            activityDidFinish(false)
            return
        }
        UIApplication.shared.open(url)
        activityDidFinish(true)
    }
}
