//
//  Details+Information.swift
//  appdb
//
//  Created by ned on 02/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

/* This ugly af */
class DetailsInformation: DetailsCell {
    
    var title: UILabel!

    var seller: UILabel!
    var sellerText: UILabel!
    var bundleId: UILabel!
    var bundleIdText: UILabel!
    var category: UILabel!
    var categoryText: UILabel!
    var price: UILabel!
    var priceText: UILabel!
    var updated: UILabel!
    var updatedText: UILabel!
    var version: UILabel!
    var versionText: UILabel!
    var size: UILabel!
    var sizeText: UILabel!
    var rating: UILabel!
    var ratingText: UILabel!
    var compatibility: UILabel!
    var compatibilityText: UILabel!
    var languages: UILabel!
    var languagesText: UILabel!
    var printLength: UILabel!
    var printLengthText: UILabel!

    override var height: CGFloat { return UITableView.automaticDimension }
    override var identifier: String { return "information" }

    convenience init(type: ItemType, content: Item) {
        self.init(style: .default, reuseIdentifier: "information")

        self.type = type

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        title = UILabel()
        title.theme_textColor = Color.title
        title.text = "Information".localized()
        title.font = .systemFont(ofSize: (16 ~~ 15))
        title.makeDynamicFont()
        contentView.addSubview(title)

        switch type {
        case .ios: if let app = content as? App {
            seller = buildLabel(text: "Seller")
            sellerText = buildLabel(text: app.seller, isContent: true)

            bundleId = buildLabel(text: "Bundle ID")
            bundleIdText = buildLabel(text: app.bundleId, isContent: true)

            category = buildLabel(text: "Category")
            categoryText = buildLabel(text: app.category?.name, isContent: true)

            price = buildLabel(text: "Price")
            priceText = buildLabel(text: app.price, isContent: true)

            updated = buildLabel(text: "Updated")
            updatedText = buildLabel(text: app.published, isContent: true)

            version = buildLabel(text: "Version")
            versionText = buildLabel(text: app.version, isContent: true)

            size = buildLabel(text: "Size")
            sizeText = buildLabel(text: app.size, isContent: true)

            rating = buildLabel(text: "Rating")
            ratingText = buildLabel(text: app.rated, isContent: true)

            compatibility = buildLabel(text: "Compatibility")
            compatibilityText = buildLabel(text: app.compatibility, isContent: true)

            languages = buildLabel(text: "Languages")
            languagesText = buildLabel(text: app.languages, isContent: true)

            contentView.addSubview(seller)
            contentView.addSubview(sellerText)
            contentView.addSubview(bundleId)
            contentView.addSubview(bundleIdText)
            contentView.addSubview(category)
            contentView.addSubview(categoryText)
            contentView.addSubview(price)
            contentView.addSubview(priceText)
            contentView.addSubview(updated)
            contentView.addSubview(updatedText)
            contentView.addSubview(version)
            contentView.addSubview(versionText)
            contentView.addSubview(size)
            contentView.addSubview(sizeText)
            contentView.addSubview(rating)
            contentView.addSubview(ratingText)
            contentView.addSubview(compatibility)
            contentView.addSubview(compatibilityText)
            contentView.addSubview(languages)
            contentView.addSubview(languagesText)
        }

        case .cydia: if let app = content as? CydiaApp {
            seller = buildLabel(text: "Developer")
            sellerText = buildLabel(text: app.developer, isContent: true)

            bundleId = buildLabel(text: "Bundle ID")
            bundleIdText = buildLabel(text: app.bundleId, isContent: true)

            category = buildLabel(text: "Category")
            categoryText = buildLabel(text: API.categoryFromId(id: app.categoryId, type: .cydia), isContent: true)

            updated = buildLabel(text: "Updated")
            updatedText = buildLabel(text: app.updated.unixToString, isContent: true)

            version = buildLabel(text: "Version")
            versionText = buildLabel(text: app.version, isContent: true)

            contentView.addSubview(seller)
            contentView.addSubview(sellerText)
            contentView.addSubview(bundleId)
            contentView.addSubview(bundleIdText)
            contentView.addSubview(category)
            contentView.addSubview(categoryText)
            contentView.addSubview(updated)
            contentView.addSubview(updatedText)
            contentView.addSubview(version)
            contentView.addSubview(versionText)
        }

        case .books: if let book = content as? Book {
            seller = buildLabel(text: "Author")
            sellerText = buildLabel(text: book.author, isContent: true)

            category = buildLabel(text: "Category")
            categoryText = buildLabel(text: API.categoryFromId(id: book.categoryId, type: .books), isContent: true)
            if categoryText.text!.isEmpty { categoryText.text = "Unknown".localized() }

            updated = buildLabel(text: "Updated")
            updatedText = buildLabel(text: book.updated.unixToString, isContent: true)

            price = buildLabel(text: "Price")
            priceText = buildLabel(text: book.price, isContent: true)

            printLength = buildLabel(text: "Print Length")
            printLengthText = buildLabel(text: book.printLenght, isContent: true)

            languages = buildLabel(text: "Language")
            languagesText = buildLabel(text: book.language, isContent: true)

            compatibility = buildLabel(text: "Requirements")
            compatibilityText = buildLabel(text: book.requirements, isContent: true)

            contentView.addSubview(seller)
            contentView.addSubview(sellerText)
            contentView.addSubview(category)
            contentView.addSubview(categoryText)
            contentView.addSubview(updated)
            contentView.addSubview(updatedText)
            contentView.addSubview(price)
            contentView.addSubview(priceText)
            contentView.addSubview(printLength)
            contentView.addSubview(printLengthText)
            contentView.addSubview(languages)
            contentView.addSubview(languagesText)
            contentView.addSubview(compatibility)
            contentView.addSubview(compatibilityText)
        }

        default: break
        }

        setConstraints()
    }

    override func setConstraints() {
        constrain(title) { title in
            title.top ~== title.superview!.top ~+ 12
            title.left ~== title.superview!.left ~+ Global.Size.margin.value

            switch type {
            case .ios:
                constrain(seller, sellerText) { seller, sellerText in
                    (seller.top ~== title.bottom ~+ 9) ~ Global.notMaxPriority
                    seller.left ~== title.left
                    seller.right ~== seller.left ~+ (100 ~~ 86)

                    sellerText.left ~== seller.right ~+ (20 ~~ 15)
                    sellerText.right ~== sellerText.superview!.right ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(bundleId, bundleIdText) { bundleId, bundleIdText in
                        (bundleId.top ~== sellerText.bottom ~+ (5 ~~ 4)) ~ Global.notMaxPriority
                        bundleId.left ~== seller.left
                        bundleId.right ~== seller.right

                        bundleIdText.left ~== bundleId.right ~+ (20 ~~ 15)
                        bundleIdText.right ~== bundleIdText.superview!.right ~- Global.Size.margin.value
                        bundleIdText.top ~== bundleId.top

                        constrain(category, categoryText) { category, categoryText in
                            category.top ~== bundleIdText.bottom ~+ (5 ~~ 4)
                            category.left ~== bundleId.left
                            category.right ~== bundleId.right

                            categoryText.left ~== category.right ~+ (20 ~~ 15)
                            categoryText.right ~== categoryText.superview!.right ~- Global.Size.margin.value
                            categoryText.top ~== category.top

                            constrain(price, priceText) { price, priceText in
                                price.top ~== categoryText.bottom ~+ (5 ~~ 4)
                                price.left ~== category.left
                                price.right ~== category.right

                                priceText.left ~== price.right ~+ (20 ~~ 15)
                                priceText.right ~== priceText.superview!.right ~- Global.Size.margin.value
                                priceText.top ~== price.top

                                constrain(updated, updatedText) { updated, updatedText in
                                    updated.top ~== priceText.bottom ~+ (5 ~~ 4)
                                    updated.left ~== price.left
                                    updated.right ~== price.right

                                    updatedText.left ~== updated.right ~+ (20 ~~ 15)
                                    updatedText.right ~== updatedText.superview!.right ~- Global.Size.margin.value
                                    updatedText.top ~== updated.top

                                    constrain(version, versionText) { version, versionText in
                                        version.top ~== updatedText.bottom ~+ (5 ~~ 4)
                                        version.left ~== updated.left
                                        version.right ~== updated.right

                                        versionText.left ~== version.right ~+ (20 ~~ 15)
                                        versionText.right ~== versionText.superview!.right ~- Global.Size.margin.value
                                        versionText.top ~== version.top

                                        constrain(size, sizeText) { size, sizeText in
                                            size.top ~== versionText.bottom ~+ (5 ~~ 4)
                                            size.left ~== version.left
                                            size.right ~== version.right

                                            sizeText.left ~== size.right ~+ (20 ~~ 15)
                                            sizeText.right ~== sizeText.superview!.right ~- Global.Size.margin.value
                                            sizeText.top ~== size.top

                                            constrain(rating, ratingText) { rating, ratingText in
                                                rating.top ~== sizeText.bottom ~+ (5 ~~ 4)
                                                rating.left ~== size.left
                                                rating.right ~== size.right

                                                ratingText.left ~== rating.right ~+ (20 ~~ 15)
                                                ratingText.right ~== ratingText.superview!.right ~- Global.Size.margin.value
                                                ratingText.top ~== rating.top

                                                constrain(compatibility, compatibilityText) { compatibility, compatibilityText in
                                                    compatibility.top ~== ratingText.bottom ~+ (5 ~~ 4)
                                                    compatibility.left ~== rating.left
                                                    compatibility.right ~== rating.right

                                                    compatibilityText.left ~== compatibility.right ~+ (20 ~~ 15)
                                                    compatibilityText.right ~== compatibilityText.superview!.right ~- Global.Size.margin.value
                                                    compatibilityText.top ~== compatibility.top

                                                    constrain(languages, languagesText) { languages, languagesText in
                                                        languages.top ~== compatibilityText.bottom ~+ (5 ~~ 4)
                                                        languages.left ~== compatibility.left
                                                        languages.right ~== compatibility.right

                                                        languagesText.left ~== languages.right ~+ (20 ~~ 15)
                                                        languagesText.right ~== languagesText.superview!.right ~- Global.Size.margin.value
                                                        languagesText.top ~== languages.top
                                                        languagesText.bottom ~== languagesText.superview!.bottom ~- 15
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .cydia:
                constrain(seller, sellerText) { seller, sellerText in
                    (seller.top ~== title.bottom ~+ 9) ~ Global.notMaxPriority
                    seller.left ~== title.left
                    seller.right ~== seller.left ~+ (100 ~~ 86)

                    sellerText.left ~== seller.right ~+ (20 ~~ 15)
                    sellerText.right ~== sellerText.superview!.right ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(bundleId, bundleIdText) { bundleId, bundleIdText in
                        bundleId.top ~== sellerText.bottom ~+ (5 ~~ 4)
                        bundleId.left ~== seller.left
                        bundleId.right ~== seller.right

                        bundleIdText.left ~== bundleId.right ~+ (20 ~~ 15)
                        bundleIdText.right ~== bundleIdText.superview!.right ~- Global.Size.margin.value
                        bundleIdText.top ~== bundleId.top

                        constrain(category, categoryText) { category, categoryText in
                            category.top ~== bundleIdText.bottom ~+ (5 ~~ 4)
                            category.left ~== bundleId.left
                            category.right ~== bundleId.right

                            categoryText.left ~== category.right ~+ (20 ~~ 15)
                            categoryText.right ~== categoryText.superview!.right ~- Global.Size.margin.value
                            categoryText.top ~== category.top

                            constrain(updated, updatedText) { updated, updatedText in
                                updated.top ~== categoryText.bottom ~+ (5 ~~ 4)
                                updated.left ~== category.left
                                updated.right ~== category.right

                                updatedText.left ~== updated.right ~+ (20 ~~ 15)
                                updatedText.right ~== updatedText.superview!.right ~- Global.Size.margin.value
                                updatedText.top ~== updated.top

                                constrain(version, versionText) { version, versionText in
                                    version.top == updatedText.bottom ~+ (5 ~~ 4)
                                    version.left == updated.left
                                    version.right == updated.right

                                    versionText.left ~== version.right ~+ (20 ~~ 15)
                                    versionText.right ~== versionText.superview!.right ~- Global.Size.margin.value
                                    versionText.top ~== version.top
                                    versionText.bottom ~== versionText.superview!.bottom ~- 15
                                }
                            }
                        }
                    }
                }
            case .books:
                constrain(seller, sellerText) { seller, sellerText in
                    (seller.top ~== title.bottom ~+ 9) ~ Global.notMaxPriority
                    seller.left ~== title.left
                    seller.right ~== seller.left ~+ (100 ~~ 86)

                    sellerText.left ~== seller.right ~+ (20 ~~ 15)
                    sellerText.right ~== sellerText.superview!.right ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(category, categoryText) { category, categoryText in
                        category.top ~== sellerText.bottom ~+ (5 ~~ 4)
                        category.left ~== seller.left
                        category.right ~== seller.right

                        categoryText.left ~== category.right ~+ (20 ~~ 15)
                        categoryText.right ~== categoryText.superview!.right ~- Global.Size.margin.value
                        categoryText.top ~== category.top

                        constrain(updated, updatedText) { updated, updatedText in
                            updated.top ~== categoryText.bottom ~+ (5 ~~ 4)
                            updated.left ~== category.left
                            updated.right ~== category.right

                            updatedText.left ~== updated.right ~+ (20 ~~ 15)
                            updatedText.right ~== updatedText.superview!.right ~- Global.Size.margin.value
                            updatedText.top ~== updated.top

                            constrain(price, priceText) { price, priceText in
                                price.top ~== updatedText.bottom ~+ (5 ~~ 4)
                                price.left ~== updated.left
                                price.right ~== updated.right

                                priceText.left ~== price.right ~+ (20 ~~ 15)
                                priceText.right ~== priceText.superview!.right ~- Global.Size.margin.value
                                priceText.top ~== price.top

                                constrain(printLength, printLengthText) { printLength, printLengthText in
                                    printLength.top ~== priceText.bottom ~+ (5 ~~ 4)
                                    printLength.left ~== price.left
                                    printLength.right ~== price.right

                                    printLengthText.left ~== printLength.right ~+ (20 ~~ 15)
                                    printLengthText.right ~== printLength.superview!.right ~- Global.Size.margin.value
                                    printLengthText.top ~== printLength.top

                                    constrain(languages, languagesText) { languages, languagesText in
                                        languages.top ~== printLengthText.bottom ~+ (5 ~~ 4)
                                        languages.left ~== printLength.left
                                        languages.right ~== printLength.right

                                        languagesText.left ~== languages.right ~+ (20 ~~ 15)
                                        languagesText.right ~== languagesText.superview!.right ~- Global.Size.margin.value
                                        languagesText.top ~== languages.top

                                        constrain(compatibility, compatibilityText) { compatibility, compatibilityText in
                                            compatibility.top ~== languagesText.bottom ~+ (5 ~~ 4)
                                            compatibility.left ~== languages.left
                                            compatibility.right ~== languages.right

                                            compatibilityText.left ~== compatibility.right ~+ (20 ~~ 15)
                                            compatibilityText.right ~== compatibilityText.superview!.right ~- Global.Size.margin.value
                                            compatibilityText.top ~== compatibility.top
                                            compatibilityText.bottom ~== compatibilityText.superview!.bottom ~- 15
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            default:
                break
            }
        }
    }

    private func buildLabel(text: String?, isContent: Bool = false) -> UILabel {
        let label = UILabel()
        label.theme_textColor = isContent ? Color.darkGray : Color.informationParameter
        if let text = text?.localized() { label.text = (text.isEmpty || text==" ") ? "Unknown".localized() : text }
        label.font = .systemFont(ofSize: (13.5 ~~ 12.5))
        label.makeDynamicFont()
        label.textAlignment = isContent ? .left : .right
        label.numberOfLines = isContent ? 0 : 1
        return label
    }
}
