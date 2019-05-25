//
//  SelectorBulletinPage.swift
//  appdb
//
//  Created by ned on 09/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import BLTNBoard
import SwiftTheme

class SelectorBulletinPage: BLTNPageItem {
    private var firstButton: UIButton!
    private var secondButton: UIButton!

    override func tearDown() {
        firstButton?.removeTarget(self, action: nil, for: .touchUpInside)
        secondButton?.removeTarget(self, action: nil, for: .touchUpInside)
    }

    // Add image, descriptions and buttons to bulletin
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        let imageStack = interfaceBuilder.makeGroupStack(spacing: 10)

        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "mdm_installed")
        imageStack.addArrangedSubview(image)

        let description = UILabel()
        description.text = "Is your device already linked to appdb? You can check if you have appdb profile installed at Settings -> General -> Profiles.".localized()
        description.font = .systemFont(ofSize: (16 ~~ 15))
        description.textAlignment = .center
        description.numberOfLines = 0
        description.theme_textColor = Color.title
        imageStack.addArrangedSubview(description)

        let stack = interfaceBuilder.makeGroupStack(spacing: 10)

        let firstButton = createChoiceCell(title: "Yes, already linked".localized(), isSelected: true)
        firstButton.addTarget(self, action: #selector(linkedButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(firstButton)
        self.firstButton = firstButton

        let secondButton = createChoiceCell(title: "No, not yet linked".localized(), isSelected: false)
        secondButton.addTarget(self, action: #selector(notLinkedButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(secondButton)
        self.secondButton = secondButton

        return [imageStack, stack]
    }

    // MARK: - Custom Views

    /**
     * Creates a custom choice button.
     */

    func createChoiceCell(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .center

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2

        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 45)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        let buttonColor = isSelected ? appearance.theme_actionButtonColor : Color.copyrightText
        let buttonCGColor = isSelected ? Color.mainTintCgColor : Color.copyrightTextCgColor
        button.layer.theme_borderColor = buttonCGColor
        button.theme_setTitleColor(buttonColor, forState: .normal)

        if isSelected {
            next = DeviceLinkIntroBulletins.makeLinkCodeTextFieldPage()
        }

        return button
    }

    // MARK: - Touch Events

    @objc func linkedButtonTapped() {
        // Update UI
        firstButton.layer.theme_borderColor = Color.mainTintCgColor
        firstButton.theme_setTitleColor(appearance.theme_actionButtonColor, forState: .normal)

        secondButton.layer.theme_borderColor = Color.copyrightTextCgColor
        secondButton.theme_setTitleColor(Color.copyrightText, forState: .normal)

        // Set the next item
        next = DeviceLinkIntroBulletins.makeLinkCodeTextFieldPage()
    }

    @objc func notLinkedButtonTapped() {
        // Update UI
        secondButton.layer.theme_borderColor = Color.mainTintCgColor
        secondButton.theme_setTitleColor(appearance.theme_actionButtonColor, forState: .normal)

        firstButton.layer.theme_borderColor = Color.copyrightTextCgColor
        firstButton.theme_setTitleColor(Color.copyrightText, forState: .normal)

        // Set the next item
        next = DeviceLinkIntroBulletins.makeEmailTextFieldPage()
    }
}
