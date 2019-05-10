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
        view.configureTheme(.success, iconStyle: .subtle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.bodyLabel?.makeDynamicFont()
        SwiftMessages.show(config: config, view: view)
    }
    
    mutating func showError(message: String, context: SwiftMessages.PresentationContext? = nil) {
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        let config = getConfig(context)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        view.configureTheme(.error, iconStyle: .subtle)
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        view.bodyLabel?.makeDynamicFont()
        SwiftMessages.show(config: config, view: view)
    }
}
