//
//  Details+Information.swift
//  appdb
//
//  Created by ned on 02/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

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

    override var height: CGFloat { UITableView.automaticDimension }
    override var identifier: String { "information" }

    convenience init(type: ItemType, content: Item) {
        self.init(style: .default, reuseIdentifier: "information")

        self.type = type

        selectionStyle = .none
        preservesSuperviewLayoutMargins = false
        addSeparator()

        theme_backgroundColor = Color.veryVeryLightGray
        setBackgroundColor(Color.veryVeryLightGray)

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
            categoryText = buildLabel(text: API.categoryFromId(id: app.categoryId.description, type: .cydia), isContent: true)

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
            categoryText = buildLabel(text: API.categoryFromId(id: book.categoryId.description, type: .books), isContent: true)
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

        case .altstore: if let app = content as? AltStoreApp {
            seller = buildLabel(text: "Developer")
            sellerText = buildLabel(text: app.developer, isContent: true)

            bundleId = buildLabel(text: "Bundle ID")
            bundleIdText = buildLabel(text: app.bundleId, isContent: true)

            size = buildLabel(text: "Size")
            sizeText = buildLabel(text: app.formattedSize, isContent: true)

            updated = buildLabel(text: "Updated")
            updatedText = buildLabel(text: app.updated, isContent: true)

            version = buildLabel(text: "Version")
            versionText = buildLabel(text: app.version, isContent: true)

            contentView.addSubview(seller)
            contentView.addSubview(sellerText)
            contentView.addSubview(bundleId)
            contentView.addSubview(bundleIdText)
            contentView.addSubview(size)
            contentView.addSubview(sizeText)
            contentView.addSubview(updated)
            contentView.addSubview(updatedText)
            contentView.addSubview(version)
            contentView.addSubview(versionText)
        }

        default: break
        }

        setConstraints()
    }

    override func setConstraints() {
        constrain(title) { title in
            title.top ~== title.superview!.top ~+ 12
            title.leading ~== title.superview!.leading ~+ Global.Size.margin.value

            switch type {
            case .ios:
                constrain(seller, sellerText) { seller, sellerText in
                    (seller.top ~== title.bottom ~+ 9) ~ Global.notMaxPriority
                    seller.leading ~== title.leading
                    seller.trailing ~== seller.leading ~+ (100 ~~ 86)

                    sellerText.leading ~== seller.trailing ~+ (20 ~~ 15)
                    sellerText.trailing ~== sellerText.superview!.trailing ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(bundleId, bundleIdText) { bundleId, bundleIdText in
                        (bundleId.top ~== sellerText.bottom ~+ (5 ~~ 4)) ~ Global.notMaxPriority
                        bundleId.leading ~== seller.leading
                        bundleId.trailing ~== seller.trailing

                        bundleIdText.leading ~== bundleId.trailing ~+ (20 ~~ 15)
                        bundleIdText.trailing ~== bundleIdText.superview!.trailing ~- Global.Size.margin.value
                        bundleIdText.top ~== bundleId.top

                        constrain(category, categoryText) { category, categoryText in
                            category.top ~== bundleIdText.bottom ~+ (5 ~~ 4)
                            category.leading ~== bundleId.leading
                            category.trailing ~== bundleId.trailing

                            categoryText.leading ~== category.trailing ~+ (20 ~~ 15)
                            categoryText.trailing ~== categoryText.superview!.trailing ~- Global.Size.margin.value
                            categoryText.top ~== category.top

                            constrain(price, priceText) { price, priceText in
                                price.top ~== categoryText.bottom ~+ (5 ~~ 4)
                                price.leading ~== category.leading
                                price.trailing ~== category.trailing

                                priceText.leading ~== price.trailing ~+ (20 ~~ 15)
                                priceText.trailing ~== priceText.superview!.trailing ~- Global.Size.margin.value
                                priceText.top ~== price.top

                                constrain(updated, updatedText) { updated, updatedText in
                                    updated.top ~== priceText.bottom ~+ (5 ~~ 4)
                                    updated.leading ~== price.leading
                                    updated.trailing ~== price.trailing

                                    updatedText.leading ~== updated.trailing ~+ (20 ~~ 15)
                                    updatedText.trailing ~== updatedText.superview!.trailing ~- Global.Size.margin.value
                                    updatedText.top ~== updated.top

                                    constrain(version, versionText) { version, versionText in
                                        version.top ~== updatedText.bottom ~+ (5 ~~ 4)
                                        version.leading ~== updated.leading
                                        version.trailing ~== updated.trailing

                                        versionText.leading ~== version.trailing ~+ (20 ~~ 15)
                                        versionText.trailing ~== versionText.superview!.trailing ~- Global.Size.margin.value
                                        versionText.top ~== version.top

                                        constrain(size, sizeText) { size, sizeText in
                                            size.top ~== versionText.bottom ~+ (5 ~~ 4)
                                            size.leading ~== version.leading
                                            size.trailing ~== version.trailing

                                            sizeText.leading ~== size.trailing ~+ (20 ~~ 15)
                                            sizeText.trailing ~== sizeText.superview!.trailing ~- Global.Size.margin.value
                                            sizeText.top ~== size.top

                                            constrain(rating, ratingText) { rating, ratingText in
                                                rating.top ~== sizeText.bottom ~+ (5 ~~ 4)
                                                rating.leading ~== size.leading
                                                rating.trailing ~== size.trailing

                                                ratingText.leading ~== rating.trailing ~+ (20 ~~ 15)
                                                ratingText.trailing ~== ratingText.superview!.trailing ~- Global.Size.margin.value
                                                ratingText.top ~== rating.top

                                                constrain(compatibility, compatibilityText) { compatibility, compatibilityText in
                                                    compatibility.top ~== ratingText.bottom ~+ (5 ~~ 4)
                                                    compatibility.leading ~== rating.leading
                                                    compatibility.trailing ~== rating.trailing

                                                    compatibilityText.leading ~== compatibility.trailing ~+ (20 ~~ 15)
                                                    compatibilityText.trailing ~== compatibilityText.superview!.trailing ~- Global.Size.margin.value
                                                    compatibilityText.top ~== compatibility.top

                                                    constrain(languages, languagesText) { languages, languagesText in
                                                        languages.top ~== compatibilityText.bottom ~+ (5 ~~ 4)
                                                        languages.leading ~== compatibility.leading
                                                        languages.trailing ~== compatibility.trailing

                                                        languagesText.leading ~== languages.trailing ~+ (20 ~~ 15)
                                                        languagesText.trailing ~== languagesText.superview!.trailing ~- Global.Size.margin.value
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
                    seller.leading ~== title.leading
                    seller.trailing ~== seller.leading ~+ (100 ~~ 86)

                    sellerText.leading ~== seller.trailing ~+ (20 ~~ 15)
                    sellerText.trailing ~== sellerText.superview!.trailing ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(bundleId, bundleIdText) { bundleId, bundleIdText in
                        bundleId.top ~== sellerText.bottom ~+ (5 ~~ 4)
                        bundleId.leading ~== seller.leading
                        bundleId.trailing ~== seller.trailing

                        bundleIdText.leading ~== bundleId.trailing ~+ (20 ~~ 15)
                        bundleIdText.trailing ~== bundleIdText.superview!.trailing ~- Global.Size.margin.value
                        bundleIdText.top ~== bundleId.top

                        constrain(category, categoryText) { category, categoryText in
                            category.top ~== bundleIdText.bottom ~+ (5 ~~ 4)
                            category.leading ~== bundleId.leading
                            category.trailing ~== bundleId.trailing

                            categoryText.leading ~== category.trailing ~+ (20 ~~ 15)
                            categoryText.trailing ~== categoryText.superview!.trailing ~- Global.Size.margin.value
                            categoryText.top ~== category.top

                            constrain(updated, updatedText) { updated, updatedText in
                                updated.top ~== categoryText.bottom ~+ (5 ~~ 4)
                                updated.leading ~== category.leading
                                updated.trailing ~== category.trailing

                                updatedText.leading ~== updated.trailing ~+ (20 ~~ 15)
                                updatedText.trailing ~== updatedText.superview!.trailing ~- Global.Size.margin.value
                                updatedText.top ~== updated.top

                                constrain(version, versionText) { version, versionText in
                                    version.top == updatedText.bottom ~+ (5 ~~ 4)
                                    version.leading == updated.leading
                                    version.trailing == updated.trailing

                                    versionText.leading ~== version.trailing ~+ (20 ~~ 15)
                                    versionText.trailing ~== versionText.superview!.trailing ~- Global.Size.margin.value
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
                    seller.leading ~== title.leading
                    seller.trailing ~== seller.leading ~+ (100 ~~ 86)

                    sellerText.leading ~== seller.trailing ~+ (20 ~~ 15)
                    sellerText.trailing ~== sellerText.superview!.trailing ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(category, categoryText) { category, categoryText in
                        category.top ~== sellerText.bottom ~+ (5 ~~ 4)
                        category.leading ~== seller.leading
                        category.trailing ~== seller.trailing

                        categoryText.leading ~== category.trailing ~+ (20 ~~ 15)
                        categoryText.trailing ~== categoryText.superview!.trailing ~- Global.Size.margin.value
                        categoryText.top ~== category.top

                        constrain(updated, updatedText) { updated, updatedText in
                            updated.top ~== categoryText.bottom ~+ (5 ~~ 4)
                            updated.leading ~== category.leading
                            updated.trailing ~== category.trailing

                            updatedText.leading ~== updated.trailing ~+ (20 ~~ 15)
                            updatedText.trailing ~== updatedText.superview!.trailing ~- Global.Size.margin.value
                            updatedText.top ~== updated.top

                            constrain(price, priceText) { price, priceText in
                                price.top ~== updatedText.bottom ~+ (5 ~~ 4)
                                price.leading ~== updated.leading
                                price.trailing ~== updated.trailing

                                priceText.leading ~== price.trailing ~+ (20 ~~ 15)
                                priceText.trailing ~== priceText.superview!.trailing ~- Global.Size.margin.value
                                priceText.top ~== price.top

                                constrain(printLength, printLengthText) { printLength, printLengthText in
                                    printLength.top ~== priceText.bottom ~+ (5 ~~ 4)
                                    printLength.leading ~== price.leading
                                    printLength.trailing ~== price.trailing

                                    printLengthText.leading ~== printLength.trailing ~+ (20 ~~ 15)
                                    printLengthText.trailing ~== printLength.superview!.trailing ~- Global.Size.margin.value
                                    printLengthText.top ~== printLength.top

                                    constrain(languages, languagesText) { languages, languagesText in
                                        languages.top ~== printLengthText.bottom ~+ (5 ~~ 4)
                                        languages.leading ~== printLength.leading
                                        languages.trailing ~== printLength.trailing

                                        languagesText.leading ~== languages.trailing ~+ (20 ~~ 15)
                                        languagesText.trailing ~== languagesText.superview!.trailing ~- Global.Size.margin.value
                                        languagesText.top ~== languages.top

                                        constrain(compatibility, compatibilityText) { compatibility, compatibilityText in
                                            compatibility.top ~== languagesText.bottom ~+ (5 ~~ 4)
                                            compatibility.leading ~== languages.leading
                                            compatibility.trailing ~== languages.trailing

                                            compatibilityText.leading ~== compatibility.trailing ~+ (20 ~~ 15)
                                            compatibilityText.trailing ~== compatibilityText.superview!.trailing ~- Global.Size.margin.value
                                            compatibilityText.top ~== compatibility.top
                                            compatibilityText.bottom ~== compatibilityText.superview!.bottom ~- 15
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .altstore:
                constrain(seller, sellerText) { seller, sellerText in
                    (seller.top ~== title.bottom ~+ 9) ~ Global.notMaxPriority
                    seller.leading ~== title.leading
                    seller.trailing ~== seller.leading ~+ (100 ~~ 86)

                    sellerText.leading ~== seller.trailing ~+ (20 ~~ 15)
                    sellerText.trailing ~== sellerText.superview!.trailing ~- Global.Size.margin.value
                    sellerText.top ~== seller.top

                    constrain(bundleId, bundleIdText) { bundleId, bundleIdText in
                        bundleId.top ~== sellerText.bottom ~+ (5 ~~ 4)
                        bundleId.leading ~== seller.leading
                        bundleId.trailing ~== seller.trailing

                        bundleIdText.leading ~== bundleId.trailing ~+ (20 ~~ 15)
                        bundleIdText.trailing ~== bundleIdText.superview!.trailing ~- Global.Size.margin.value
                        bundleIdText.top ~== bundleId.top

                        constrain(updated, updatedText) { updated, updatedText in
                            updated.top ~== bundleIdText.bottom ~+ (5 ~~ 4)
                            updated.leading ~== bundleId.leading
                            updated.trailing ~== bundleId.trailing

                            updatedText.leading ~== updated.trailing ~+ (20 ~~ 15)
                            updatedText.trailing ~== updatedText.superview!.trailing ~- Global.Size.margin.value
                            updatedText.top ~== updated.top

                            constrain(version, versionText) { version, versionText in
                                version.top == updatedText.bottom ~+ (5 ~~ 4)
                                version.leading == updated.leading
                                version.trailing == updated.trailing

                                versionText.leading ~== version.trailing ~+ (20 ~~ 15)
                                versionText.trailing ~== versionText.superview!.trailing ~- Global.Size.margin.value
                                versionText.top ~== version.top
                                versionText.bottom ~== versionText.superview!.bottom ~- 15
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
        if let text = text?.localized() { label.text = (text.isEmpty || text == " ") ? "Unknown".localized() : text }
        label.font = .systemFont(ofSize: (13.5 ~~ 12.5))
        label.makeDynamicFont()
        label.textAlignment = isContent ? (Global.isRtl ? .right : .left) : (Global.isRtl ? .left : .right)
        label.numberOfLines = isContent ? 0 : 1
        return label
    }
}
