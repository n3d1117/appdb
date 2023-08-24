//
//  PlusPurchaseCell.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit

class PlusPurchaseCell: UITableViewCell {

    private var iconWidth: CGFloat = 12
    private var iconHeight: CGFloat = 10
    private var margin: CGFloat = (15 ~~ 12)
    private var name: UILabel!
    private var payBy: UILabel!
    private var payByView: UIView!
    private var payByIcon: UIImageView!
    private var payByText: UILabel!

    private var price: UILabel!
    private var vatInfo: UILabel!

    func configure(with plusPurchaseOption: PlusPurchaseOption) {
        name.text = plusPurchaseOption.name
        payByText.text = plusPurchaseOption.type == "visa" ? "Visa/Mastercard/PayPal" : "Unknown".localized()

        price.text = plusPurchaseOption.price
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .none
        accessoryView = nil
        frame.size.height = 85

        self.setup()
    }

    func setup() {

        contentView.layer.cornerRadius = 8

        // Name
        name = UILabel()
        name.textColor = .white
        name.font = .boldSystemFont(ofSize: 16 ~~ 15)
        name.numberOfLines = 1
        name.makeDynamicFont()

        // Pay by Title
        payBy = UILabel()
        payBy.textColor = .white
        payBy.font = .systemFont(ofSize: 13 ~~ 12)
        payBy.numberOfLines = 1
        payBy.makeDynamicFont()
        payBy.text = "Pay by".localized()

        // Pay by Icon
        payByIcon = UIImageView()
        payByIcon.contentMode = .scaleAspectFit
        payByIcon.image = UIImage(named: "card-icon")

        payByText = UILabel()
        payByText.textColor = .white
        payByText.font = .systemFont(ofSize: 13 ~~ 12)
        payByText.numberOfLines = 1
        payByText.makeDynamicFont()

        payByView = UIView()
        payByView.addSubview(payByIcon)
        payByView.addSubview(payByText)
        payByView.layer.borderColor = UIColor.white.cgColor
        payByView.layer.borderWidth = 1.0

        // Price
        price = UILabel()
        price.textColor = .white
        price.font = .boldSystemFont(ofSize: 18 ~~ 17)
        price.numberOfLines = 1
        price.makeDynamicFont()

        // Vat Info
        vatInfo = UILabel()
        vatInfo.textColor = .white
        vatInfo.font = .systemFont(ofSize: 14 ~~ 13)
        vatInfo.numberOfLines = 1
        vatInfo.makeDynamicFont()
        vatInfo.text = "excl. VAT".localized()

        contentView.addSubview(name)
        contentView.addSubview(payBy)
        contentView.addSubview(payByView)
        contentView.addSubview(price)
        contentView.addSubview(vatInfo)

        constrain(name, payBy, payByView, payByIcon, payByText, price, vatInfo) { name, payBy, payByView, payByIcon, payByText, price, vatInfo in

            name.leading ~== name.superview!.leading ~+ margin
            name.top ~== name.superview!.top ~+ margin

            payBy.leading ~== name.leading
            payBy.bottom ~== payBy.superview!.bottom ~- margin

            payByView.leading ~== payBy.trailing ~+ (margin / 2)
            payByView.bottom ~== payBy.bottom

            payByIcon.width ~== iconWidth
            payByIcon.height ~== iconHeight
            payByIcon.centerY ~== payBy.centerY

            payByText.leading ~== payByIcon.trailing ~+ (margin / 2)
            payByText.centerY ~== payBy.centerY

            price.trailing ~== price.superview!.trailing ~- margin
            price.top ~== name.top ~+ (margin / 2)

            vatInfo.trailing ~== vatInfo.superview!.trailing ~- margin
            vatInfo.bottom ~== payBy.bottom
        }

        setGradient()
    }

    func setGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#404cff").cgColor, UIColor(rgba: "#1c3372").cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = layer.frame
        gradient.frame.size.width = UIScreen.main.bounds.width
        layer.insertSublayer(gradient, at: 0)
    }
}
