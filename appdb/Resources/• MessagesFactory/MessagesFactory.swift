//
//  MessagesFactory.swift
//  appdb
//
//  Created by ned on 02/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import SwiftMessages

struct Messages {
    
    static var shared = Messages()
    private init() { }

    func hideAll() {
        SwiftMessages.hideAll()
    }

    func getConfig(_ context: SwiftMessages.PresentationContext? = nil) -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.presentationContext = context ?? .automatic
        config.duration = .seconds(seconds: 2.5)
        config.dimMode = .none
        return config
    }

    @discardableResult
    private mutating func show(message: String, theme: Theme, context: SwiftMessages.PresentationContext? = nil) -> MessageView {
        let view = MessageView.viewFromNib(layout: .cardView)
        let config = getConfig(context)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        if Global.isIpad { view.configureBackgroundView(width: 600) }
        view.configureTheme(theme, iconStyle: .subtle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.backgroundView.theme_backgroundColor = theme == .success ? Color.softGreen : Color.softRed
        SwiftMessages.show(config: config, view: view)
        return view
    }

    @discardableResult
    mutating func showSuccess(message: String, context: SwiftMessages.PresentationContext? = nil) -> MessageView {
        return show(message: message, theme: .success, context: context)
    }

    @discardableResult
    mutating func showError(message: String, context: SwiftMessages.PresentationContext? = nil) -> MessageView {
        return show(message: message, theme: .error, context: context)
    }

    func generateModalSegue(vc: UIViewController, source: UIViewController) -> SwiftMessagesSegue {
        let segue = SwiftMessagesSegue(identifier: nil, source: source, destination: vc)
        segue.configure(layout: .centered)
        segue.keyboardTrackingView = KeyboardTrackingView()
        segue.messageView.configureNoDropShadow()
        let dimColor: UIColor = Themes.isNight ? UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 0.8) : UIColor(red: 54 / 255, green: 54 / 255, blue: 54 / 255, alpha: 0.5)
        segue.dimMode = .color(color: dimColor, interactive: true)
        segue.interactiveHide = false
        return segue
    }
}
