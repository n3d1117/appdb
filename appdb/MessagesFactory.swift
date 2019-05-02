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

    lazy var config: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .seconds(seconds: 2)
        config.dimMode = .none
        return config
    }()
    
    mutating func showSuccess(message: String) {
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        view.configureTheme(.success, iconStyle: .subtle)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        SwiftMessages.show(config: config, view: view)
    }
    
    mutating func showError(message: String) {
        let view: MessageView = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: nil, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        view.configureTheme(.error, iconStyle: .subtle)
        view.configureDropShadow()
        view.button?.isHidden = true
        view.titleLabel?.isHidden = true
        SwiftMessages.show(config: config, view: view)
    }
}
