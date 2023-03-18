//
//  Details+Header.swift
//  appdb
//
//  Created by ned on 20/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import Cosmos

protocol DetailsHeaderDelegate: AnyObject {
    func sellerSelected(title: String, type: ItemType, devId: String)
    func installClicked(sender: RoundedButton)
}

extension DetailsHeaderDelegate {
    func sellerSelected(title: String, type: ItemType, devId: String) {
        fatalError("sellerSelected must be set")
    }
    
    func installClicked(sender: RoundedButton) {
        fatalError("installClicked must be set")
    }
}

class DetailsHeader: DetailsCell {

    var name: UILabel!
    var icon: UIImageView!
    var seller: UIButton!
    var tweaked: UILabel?
    var ipadOnly: UILabel?
    var stars: CosmosView?
    var additionalInfo: UILabel?
    
    var installButton: RoundedButton?

    var devId: String = ""
    weak var delegate: DetailsHeaderDelegate?

    private var _height = (132 ~~ 102) + Global.Size.margin.value
    private var _heightAltStore = (162 ~~ 132) + Global.Size.margin.value
    private var _heightBooks = round((132 ~~ 102) * 1.542) + Global.Size.margin.value
    override var height: CGFloat {
        switch type {
        case .ios, .cydia: return _height
        case .books: return _heightBooks
        case .altstore: return _heightAltStore
        default: return 0
        }
    }

    override var identifier: String { "header" }

    convenience init(type: ItemType, content: Item, delegate: DetailsHeaderDelegate) {
        self.init(style: .default, reuseIdentifier: "header")

        self.type = type
        self.delegate = delegate

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        separatorInset.left = 10000
        layoutMargins = .zero

        // UI
        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

        // Name
        name = UILabel()
        name.theme_textColor = Color.title
        name.font = .systemFont(ofSize: 18.5 ~~ 16.5)
        name.numberOfLines = type == .books ? 4 : 3
        name.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor

        switch type {
        case .ios: if let app = content as? App {
            name.text = app.name.decoded
            seller = ButtonFactory.createChevronButton(text: app.seller.isEmpty ? "Unknown".localized() : app.seller, color: Color.darkGray, size: (15 ~~ 13), bold: false)
            seller.addTarget(self, action: #selector(self.sellerTapped), for: .touchUpInside)
            icon.layer.cornerRadius = Global.cornerRadius(from: (130 ~~ 100))

            if app.itemHasStars {
                stars = buildStars()
                stars!.rating = app.numberOfStars
                stars!.text = app.numberOfRating
            }

            if app.screenshotsIphone.isEmpty && !app.screenshotsIpad.isEmpty {
                ipadOnly = buildPaddingLabel()
                ipadOnly!.text = "iPad only".localized().uppercased()
            }

            if let url = URL(string: app.image) {
                icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: (130 ~~ 100)), imageTransition: .crossDissolve(0.2))
            }

            self.devId = app.artistId
        }
        case .cydia: if let cydiaApp = content as? CydiaApp {
            name.text = cydiaApp.name.decoded
            if !cydiaApp.developer.isEmpty {
                seller = ButtonFactory.createChevronButton(text: cydiaApp.developer, color: Color.darkGray, size: (15 ~~ 13), bold: false)
                seller.addTarget(self, action: #selector(self.sellerTapped), for: .touchUpInside)
            }

            tweaked = buildPaddingLabel()
            tweaked!.text = API.categoryFromId(id: cydiaApp.categoryId, type: .cydia).uppercased()

            icon.layer.cornerRadius = Global.cornerRadius(from: (130 ~~ 100))
            if let url = URL(string: cydiaApp.image) {
                icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: (130 ~~ 100)), imageTransition: .crossDissolve(0.2))
            }

            self.devId = cydiaApp.developerId
        }
        case .books: if let book = content as? Book {
            name.text = book.name.decoded
            if !book.author.isEmpty {
                seller = ButtonFactory.createChevronButton(text: book.author, color: Color.darkGray, size: (15 ~~ 13), bold: false)
                seller.addTarget(self, action: #selector(self.sellerTapped), for: .touchUpInside)
            }
            icon.layer.cornerRadius = 0

            if book.itemHasStars {
                stars = buildStars()
                stars!.rating = book.numberOfStars
                stars!.text = book.numberOfRating
            }

            if !book.published.isEmpty {
                additionalInfo = UILabel()
                additionalInfo!.theme_textColor = Color.darkGray
                additionalInfo!.font = .systemFont(ofSize: (14 ~~ 12))
                additionalInfo!.numberOfLines = 1
                additionalInfo!.text = book.published
                additionalInfo!.makeDynamicFont()

                if !book.printLenght.isEmpty {
                    additionalInfo!.text = additionalInfo!.text! + Global.bulletPoint + book.printLenght
                }
            }

            if let url = URL(string: book.image) {
                icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderCover"), imageTransition: .crossDissolve(0.2))
            }

            self.devId = book.artistId
        }
        case .altstore: if let altstoreApp = content as? AltStoreApp {
            name.text = altstoreApp.name

            icon.layer.cornerRadius = Global.cornerRadius(from: (130 ~~ 100))
            if let url = URL(string: altstoreApp.image) {
                icon.af.setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: (130 ~~ 100)), imageTransition: .crossDissolve(0.2))
            }
            
            if !altstoreApp.developer.isEmpty {
                seller = UIButton(type: .custom)
                seller.titleLabel?.text = altstoreApp.developer
                seller.titleLabel?.font = UIFont.systemFont(ofSize: (15 ~~ 13))
                seller.titleLabel?.theme_textColor = Color.darkGray
                seller.setTitle(altstoreApp.developer, for: .normal)
                seller.theme_setTitleColor(Color.darkGray, forState: .normal)
            }
            
            if altstoreApp.beta {
                tweaked = buildPaddingLabel()
                tweaked!.text = "Beta Version".localized()
            }
            
            installButton = RoundedButton()
            installButton!.titleLabel?.font = .boldSystemFont(ofSize: 13)
            installButton!.makeDynamicFont()
            installButton!.setTitle("Install".localized().uppercased(), for: .normal)
            installButton!.theme_tintColor = Color.softGreen
            installButton!.addTarget(self, action: #selector(installTapped), for: .touchUpInside)
        }
        default:
            break
        }

        contentView.addSubview(name)
        contentView.addSubview(icon)
        if let seller = seller { contentView.addSubview(seller) }
        if let tweaked = tweaked { contentView.addSubview(tweaked) }
        if let stars = stars { contentView.addSubview(stars) }
        if let ipadOnly = ipadOnly { contentView.addSubview(ipadOnly) }
        if let additional = additionalInfo { contentView.addSubview(additional) }
        if let installButton = installButton { contentView.addSubview(installButton) }

        setConstraints()
    }

    @objc func sellerTapped() {
        delegate?.sellerSelected(title: seller.titleLabel?.text ?? "", type: self.type, devId: self.devId)
    }
    
    @objc func installTapped(sender: RoundedButton) {
        delegate?.installClicked(sender: sender)
    }

    override func setConstraints() {
        if let seller = seller {
            constrain(name, seller, icon) { name, seller, icon in
                icon.width ~== (130 ~~ 100)

                switch type {
                case .ios, .cydia: icon.height ~== icon.width
                case .books: icon.height ~== icon.width ~* 1.542
                default: break
                }

                icon.leading ~== icon.superview!.leading ~+ Global.Size.margin.value
                icon.top ~== icon.superview!.top ~+ Global.Size.margin.value

                name.leading ~== icon.trailing ~+ (15 ~~ 12)
                name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
                name.top ~== icon.top ~+ 3

                seller.leading ~== name.leading
                seller.top ~== name.bottom ~+ 3
                seller.trailing ~<= seller.superview!.trailing ~- Global.Size.margin.value
            }
        } else {
            constrain(name, icon) { name, icon in
                icon.width ~== (130 ~~ 100)

                switch type {
                case .ios, .cydia: icon.height ~== icon.width
                case .books: icon.height ~== icon.width ~* 1.542
                default: break
                }

                icon.leading ~== icon.superview!.leading ~+ Global.Size.margin.value
                icon.top ~== icon.superview!.top ~+ Global.Size.margin.value

                name.leading ~== icon.trailing ~+ (15 ~~ 12)
                name.trailing ~== name.superview!.trailing ~- Global.Size.margin.value
                name.top ~== icon.top ~+ 3
            }
        }

        if let tweaked = tweaked, type == .cydia || type == .altstore {
            if let seller = seller {
                constrain(tweaked, seller) { tweaked, seller in
                    tweaked.leading ~== seller.leading
                    tweaked.trailing ~<= tweaked.superview!.trailing ~- Global.Size.margin.value
                    tweaked.top ~== seller.bottom ~+ (7 ~~ 6)
                }
            } else {
                constrain(tweaked, name) { tweaked, name in
                    tweaked.leading ~== name.leading
                    tweaked.trailing ~<= tweaked.superview!.trailing ~- Global.Size.margin.value
                    tweaked.top ~== name.bottom ~+ (7 ~~ 6)
                }
            }
        }
        
        if let installButton = installButton {
            if let tweaked = tweaked {
                constrain(installButton, tweaked) { installButton, tweaked in
                    installButton.trailing ~== installButton.superview!.trailing ~- Global.Size.margin.value
                    installButton.top ~== tweaked.bottom ~+ (7 ~~ 6)
                }
            } else  if let seller = seller {
                constrain(installButton, seller) { installButton, seller in
                    installButton.trailing ~== installButton.superview!.trailing ~- Global.Size.margin.value
                    installButton.top ~== seller.bottom ~+ (7 ~~ 6)
                }
            } else {
                constrain(installButton, name) { installButton, name in
                    installButton.trailing ~== installButton.superview!.trailing ~- Global.Size.margin.value
                    installButton.top ~== name.bottom ~+ (7 ~~ 6)
                }
            }
        }

        if let stars = stars, (type == .ios || type == .books) {
            constrain(stars, seller) { stars, seller in
                stars.leading ~== seller.leading
                stars.trailing ~<= stars.superview!.trailing ~- Global.Size.margin.value

                if type == .books, let additional = additionalInfo {
                    constrain(additional) { additional in
                        additional.leading ~== seller.leading
                        additional.trailing ~<= additional.superview!.trailing ~- Global.Size.margin.value
                        additional.top ~== seller.bottom ~+ (7 ~~ 6)
                        stars.top ~== additional.bottom ~+ (7 ~~ 6)
                    }
                } else {
                    stars.top ~== seller.bottom ~+ (7 ~~ 6)
                }
            }
        }

        if let ipadOnly = ipadOnly, type == .ios {
            if let stars = stars {
                constrain(ipadOnly, stars) { ipadOnly, stars in
                    ipadOnly.leading ~== stars.leading
                    ipadOnly.trailing ~<= ipadOnly.superview!.trailing ~- Global.Size.margin.value
                    ipadOnly.top ~== stars.bottom ~+ (7 ~~ 6)
                    ipadOnly.bottom ~<= ipadOnly.superview!.bottom
                }
            } else {
                constrain(ipadOnly, seller) { ipadOnly, seller in
                    ipadOnly.leading ~== seller.leading
                    ipadOnly.trailing ~<= ipadOnly.superview!.trailing ~- Global.Size.margin.value
                    ipadOnly.top ~== seller.bottom + (7 ~~ 6)
                }
            }
        }
    }

    private func buildStars() -> CosmosView {
        let stars = CosmosView()
        stars.settings.starSize = 12
        stars.settings.updateOnTouch = false
        stars.settings.totalStars = 5
        stars.settings.fillMode = .half
        stars.settings.textMargin = 2
        stars.settings.starMargin = 0
        return stars
    }

    private func buildPaddingLabel() -> PaddingLabel {
        let label = PaddingLabel()
        label.theme_textColor = Color.invertedTitle
        label.font = .systemFont(ofSize: 10.0, weight: .semibold)
        label.makeDynamicFont()
        label.layer.backgroundColor = UIColor.gray.cgColor
        label.layer.cornerRadius = 6
        return label
    }
}
