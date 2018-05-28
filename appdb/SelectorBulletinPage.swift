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
    
    /**
     * Called by the manager when the item is about to be removed from the bulletin.
     *
     * Use this function as an opportunity to do any clean up or remove tap gesture recognizers /
     * button targets from your views to avoid retain cycles.
     */
    
    override func tearDown() {
        firstButton?.removeTarget(self, action: nil, for: .touchUpInside)
        secondButton?.removeTarget(self, action: nil, for: .touchUpInside)
    }
    
    /**
     * Called by the manager to build the view hierachy of the bulletin.
     *
     * We need to return the view in the order we want them displayed. You should use a
     * `BulletinInterfaceFactory` to generate standard views, such as title labels and buttons.
     */
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        // We add choice cells to a group stack because they need less spacing
        let stack = interfaceBuilder.makeGroupStack(spacing: 15)

        let firstButton = createChoiceCell(title: "Yes, already linked".localized(), isSelected: true)
        firstButton.addTarget(self, action: #selector(linkedButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(firstButton)
        self.firstButton = firstButton

        let secondButton = createChoiceCell(title: "No, not yet linked".localized(), isSelected: false)
        secondButton.addTarget(self, action: #selector(notLinkedButtonTapped), for: .touchUpInside)
        stack.addArrangedSubview(secondButton)
        self.secondButton = secondButton
        
        descriptionLabel?.theme_textColor = Color.title
        
        return [stack]
        
    }
    
    // MARK: - Custom Views
    
    /**
     * Creates a custom choice button.
     */
    
    func createChoiceCell(title: String, isSelected: Bool) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
        firstButton.theme_setTitleColor(appearance.theme_actionButtonColor, forState:  .normal)
        
        secondButton.layer.theme_borderColor = Color.copyrightTextCgColor
        secondButton.theme_setTitleColor(Color.copyrightText, forState: .normal)
        
        // Set the next item
        next = DeviceLinkIntroBulletins.makeLinkCodeTextFieldPage()
        
    }
    
    @objc func notLinkedButtonTapped() {
        
        // Update UI
        
        secondButton.layer.theme_borderColor = Color.mainTintCgColor
        secondButton.theme_setTitleColor(appearance.theme_actionButtonColor, forState:  .normal)
        
        firstButton.layer.theme_borderColor = Color.copyrightTextCgColor
        firstButton.theme_setTitleColor(Color.copyrightText, forState: .normal)
        
        // Set the next item
        next = DeviceLinkIntroBulletins.makeEmailTextFieldPage()
        
    }
    
    override func actionButtonTapped(sender: UIButton) {
        manager?.displayNextItem()
    }
    
}
