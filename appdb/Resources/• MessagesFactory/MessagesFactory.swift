//
//  MessagesFactory.swift
//  appdb
//
//  Created by ned on 02/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import SwiftMessages
import SwiftTheme

struct Messages {

    static var shared = Messages()
    private init() { }

    func hideAll() {
        SwiftMessages.hideAll()
    }

    func getConfig(_ context: SwiftMessages.PresentationContext? = nil) -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = Preferences.adBannerHeight > 0 ? .top : .bottom
        config.presentationContext = context ?? .automatic
        config.dimMode = .none
        return config
    }

    @discardableResult
    private mutating func show(message: String, theme: Theme, context: SwiftMessages.PresentationContext? = nil, iconStyle: IconStyle = .subtle, color: ThemeColorPicker? = nil, duration: SwiftMessages.Duration = .seconds(seconds: 2.5)) -> MessageView {
        let view = MessageView.viewFromNib(layout: .cardView)
        var config = getConfig(context)
        config.duration = duration
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        if Global.isIpad { view.configureBackgroundView(width: 600) }
        view.configureTheme(theme, iconStyle: iconStyle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.backgroundView.theme_backgroundColor = color ?? (theme == .success ? Color.softGreen : Color.softRed)
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

    @discardableResult
    mutating func showMinimal(message: String, iconStyle: IconStyle, color: ThemeColorPicker, duration: SwiftMessages.Duration, context: SwiftMessages.PresentationContext? = nil) -> MessageView {
        return show(message: message, theme: .success, context: context, iconStyle: iconStyle, color: color, duration: duration)
    }

    func generateModalSegue(vc: UIViewController, source: UIViewController, trackKeyboard: Bool = false) -> SwiftMessagesSegue {
        let segue = SwiftMessagesSegue(identifier: nil, source: source, destination: vc)
        segue.configure(layout: .centered)
        if trackKeyboard { segue.keyboardTrackingView = KeyboardTrackingView() }
        segue.messageView.configureNoDropShadow()
        let dimColor: UIColor = Themes.isNight ? UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 0.8) : UIColor(red: 54 / 255, green: 54 / 255, blue: 54 / 255, alpha: 0.5)
        segue.dimMode = .color(color: dimColor, interactive: true)
        segue.interactiveHide = false
        return segue
    }
}
