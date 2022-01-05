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

    enum Handle: Equatable {
        case twitter(username: String)
        case website(site: String)
        case telegram(username: String)
        case none
    }

    struct Credit {
        var name: String
        var detail: String?
        var imageName: String
        var type: CreditType
        var handle: Handle
    }

    lazy var credits: [Credit] = [
        Credit(name: "ned", imageName: "ned", type: .developer, handle: .none),
        Credit(name: "View project on GitHub".localized(), imageName: "github", type: .developer, handle: .website(site: Global.githubSite)),
        Credit(name: "Buy me a coffee".localized(), imageName: "bmac", type: .developer, handle: .website(site: Global.donateSite)),

        Credit(name: "appdb team", imageName: "appdb", type: .specialThanks, handle: .website(site: Global.mainSite)),
        Credit(name: "Alessandro Chiarlitti (aesign)", detail: "Icon and banner designer".localized(), imageName: "aesign", type: .specialThanks, handle: .website(site: "https://aesign.me")),

        Credit(name: "TNT 🇪🇸", imageName: "tnt", type: .translations, handle: .none),
        Credit(name: "ZonD80 🇷🇺", imageName: "zond", type: .translations, handle: .website(site: "https://github.com/ZonD80")),
        Credit(name: "Am1nCmd 🇮🇩", imageName: "Am1nCmd", type: .translations, handle: .website(site: "https://ams1gn.id")),
        Credit(name: "DzMohaipa 🇫🇷", imageName: "DzMoha_31", type: .translations, handle: .twitter(username: "DzMoha_31")),
        Credit(name: "Eskaseptian Team 🇮🇩", imageName: "EskaseptianTeam", type: .translations, handle: .website(site: "https://www.instagram.com/eskaseptian/")),
        Credit(name: "cryllical 🇩🇪", imageName: "cryllical", type: .translations, handle: .twitter(username: "cryllical")),
        Credit(name: "raaed-alharbi 🇦🇪", imageName: "placeholderIcon", type: .translations, handle: .website(site: "https://github.com/raaed-alharbi"))
    ]

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
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

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }

        if Global.isIpad {
            // Add 'Dismiss' button for iPad
            let dismissButton = UIBarButtonItem(title: "Dismiss".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
            self.navigationItem.rightBarButtonItems = [dismissButton]
        }

        dataSource = DataSource(tableViewDelegate: self)

        var sections = [Static.Section]()

        sections.append(Section(header: .autoLayoutView(CreditsIconView(text: "appdb v\(Global.appVersion)", imageName: "appdb", easterDelegate: self))))

        for (index, creditType) in CreditType.allCases.enumerated() {
            var section: Static.Section = Section(header: .title(creditType.rawValue.localized()), rows: [])
            for credit in credits where credit.type == creditType {
                section.rows.append(
                    Row(text: credit.name.localized(), detailText: credit.detail, selection: { [unowned self] _ in
                        self.handleTap(for: credit.handle)
                    }, accessory: credit.handle == .none ? .none : .disclosureIndicator, cellClass: CreditsStaticCell.self, context: ["imageName": credit.imageName])
                )
            }
            if index == CreditType.allCases.endIndex - 1 { section.footer = .title("\n\n") } // just to add some bottom padding
            if !section.rows.isEmpty { sections.append(section) }
        }

        dataSource.sections = sections
    }

    @objc func dismissAnimated() { dismiss(animated: true) }

    private func handleTap(for handle: Handle) {
        switch handle {
        case .telegram(let username):
            let link = "tg://resolve?domain=\(username)"
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let url = URL(string: "https://t.me/\(username)") {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.open(url)
                }
            }
        case .twitter(let username):
            let tweetbotLink = "tweetbot:///user_profile/\(username)"
            if let url = URL(string: tweetbotLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
            let twitterLink = "twitter://user?screen_name=\(username)"
            if let url = URL(string: twitterLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
            if let url = URL(string: "https://twitter.com/\(username)") {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.open(url)
                }
            }
        case .website(let site):
            if let url = URL(string: site) {
                if #available(iOS 9.0, *) {
                    let svc = SFSafariViewController(url: url)
                    present(svc, animated: true)
                } else {
                    UIApplication.shared.open(url)
                }
            }
        case .none: break
        }
    }
}

extension Credits: UITableViewDelegate {

    // Stick icon view to top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let headerView = tableView.subviews.first(where: { $0 is CreditsIconView }), let nav = navigationController {
            let minOff: CGFloat = (-nav.navigationBar.frame.height) ~~ (-nav.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
            if scrollView.contentOffset.y < minOff {
                headerView.bounds.origin.y = minOff - scrollView.contentOffset.y
            } else {
                headerView.bounds.origin.y = 0
            }
        }
    }
}

// It's easter time!
extension Credits: Easter {
    func easterTime() {
        Messages.shared.showMinimal(message: "Phew, for a minute there\nI lost myself, I lost myself", iconStyle: .none, color: Color.darkMainTint, duration: .forever, context: .viewController(self))
    }
}
