//
//  Credits.swift
//  appdb
//
//  Created by ned on 29/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Static
import SafariServices

class Credits: TableViewController {

    enum CreditType: String, CaseIterable {
        case developer = "Developer"
        case specialThanks = "Special Thanks"
        case translations = "Translations"
    }

    enum Handle {
        case twitter(username: String)
        case website(site: String)
        case telegram(username: String)
    }

    struct Credit {
        var name: String
        var detail: String?
        var base64Image: String
        var type: CreditType
        var handle: Handle
    }

    lazy var credits: [Credit] = [
        Credit(name: "ned", detail: nil, base64Image: nedImage, type: .developer, handle: .telegram(username: Global.telegramUsername)),
        Credit(name: "appdb team", detail: nil, base64Image: appdbImage, type: .specialThanks, handle: .website(site: Global.mainSite)),
        Credit(name: "Alessandro Chiarlitti (aesign)", detail: "Icon and banner designer".localized(), base64Image: aesignImage, type: .specialThanks, handle: .website(site: "https://aesign.me")),
        Credit(name: "TNT 🇪🇸", detail: nil, base64Image: tntImage, type: .translations, handle: .twitter(username: "tnttaolin2"))
    ]

    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits".localized()

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.cellLayoutMarginsFollowReadableWidth = true

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView.rowHeight = 55
        tableView.sectionHeaderHeight = 150
        tableView.estimatedSectionHeaderHeight = 150

        // Hide the 'Back' text on back button
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem

        var sections = [Static.Section]()

        sections.append(Section(header: .autoLayoutView(CreditsIconView(text: "appdb v\(Global.appVersion)", base64Image: appdbImage))))

        for creditType in CreditType.allCases {
            var section: Static.Section = Section(header: .title(creditType.rawValue.localized()), rows: [])
            for credit in credits where credit.type == creditType {
                section.rows.append(
                    Row(text: credit.name.localized(), detailText: credit.detail, selection: { [unowned self] _ in
                        self.handleTap(for: credit.handle)
                    }, accessory: .disclosureIndicator, cellClass: CreditsStaticCell.self, context: ["base64Image": credit.base64Image])
                )
            }
            if !section.rows.isEmpty { sections.append(section) }
        }

        dataSource.sections = sections
    }

    private func handleTap(for handle: Handle) {
        switch handle {
        case .telegram(let username):
            let link = "tg://resolve?domain=\(username)"
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            } else if let url = URL(string: "https://t.me/\(username)") {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        case .twitter(let username):
            let tweetbotLink = "tweetbot:///user_profile/\(username)"
            if let url = URL(string: tweetbotLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return
            }
            let twitterLink = "twitter://user?screen_name=\(username)"
            if let url = URL(string: twitterLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return
            }
            if let url = URL(string: "https://twitter.com/\(username)") {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        case .website(let site):
            if let url = URL(string: site) {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
