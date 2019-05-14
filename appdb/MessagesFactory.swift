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
    
    mutating func showSuccess(message: String, context: SwiftMessages.PresentationContext? = nil) {
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        let config = getConfig(context)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        if Global.isIpad { view.configureBackgroundView(width: 600) }
        view.configureTheme(.success, iconStyle: .subtle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.bodyLabel?.makeDynamicFont()
        view.backgroundView.theme_backgroundColor = Color.softGreen
        SwiftMessages.show(config: config, view: view)
    }
    
    mutating func showError(message: String, context: SwiftMessages.PresentationContext? = nil) {
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        let config = getConfig(context)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        if Global.isIpad { view.configureBackgroundView(width: 600) }
        view.configureTheme(.error, iconStyle: .subtle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.bodyLabel?.makeDynamicFont()
        view.backgroundView.theme_backgroundColor = Color.softRed
        SwiftMessages.show(config: config, view: view)
    }
    
    func generateModalSegue(vc: UIViewController, source: UIViewController) -> SwiftMessagesSegue {
        let nav = UINavigationController(rootViewController: vc)
        let segue = SwiftMessagesSegue(identifier: nil, source: source, destination: nav)
        segue.configure(layout: .centered)
        segue.messageView.backgroundHeight = 194
        let dimColor: UIColor = Themes.isNight ? UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.8) : UIColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 0.5)
        segue.dimMode = .color(color: dimColor, interactive: true)
        segue.interactiveHide = false
        return segue
    }
}
