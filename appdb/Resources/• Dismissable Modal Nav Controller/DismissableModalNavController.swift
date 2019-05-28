//
//  DismissableModalNavController.swift
//  appdb
//
//  Created by ned on 20/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

/* TODO - use presentation controller instead? */
class DismissableModalNavController: UINavigationController, UIGestureRecognizerDelegate {

    private var recognizer: UITapGestureRecognizer!
    private var keyboardShown: Bool = false

    // Content size for iPad popover
    var popoverContentSize: CGSize {
        if view.bounds.size.width > view.bounds.size.height {
            let proposedHeight = view.bounds.size.height * (3 / 4)
            return CGSize(width: proposedHeight + 50, height: proposedHeight)
        } else {
            let proposedWidth = view.bounds.size.width * (3 / 4)
            return CGSize(width: proposedWidth + 50, height: proposedWidth)
        }
    }

    deinit {
        guard Global.isIpad else { return }

        // Remove gesture recognizer if needed
        if recognizer != nil {
            view.window?.removeGestureRecognizer(recognizer)
            recognizer = nil
        }

        // Remove observer
        NotificationCenter.default.removeObserver(self)
    }

    // Set popover size
    override func viewDidLoad() {
        super.viewDidLoad()

        if Global.isIpad { self.preferredContentSize = popoverContentSize }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard Global.isIpad else { return }

        // Add gesture recognizer if needed
        if recognizer == nil {
            recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapBehind))
            recognizer.delegate = self
            recognizer.numberOfTapsRequired = 1
            recognizer.cancelsTouchesInView = false
            self.view.window?.addGestureRecognizer(recognizer)
        }

        // Subscribe to keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // Adjust content if keyboard is active
    @objc func adjustForKeyboard(notification: Notification) {
        keyboardShown = notification.name == UIResponder.keyboardWillShowNotification
    }

    // Dismiss view if tapped outside
    @objc func handleTapBehind(sender: UIGestureRecognizer) {
        guard UIApplication.topNavigation(UIApplication.topViewController()) is DismissableModalNavController else { return }

        if Global.isIpad, sender.state == .ended {
            var location: CGPoint = sender.location(in: nil)

            // in landscape view you will have to swap the location coordinates
            if UIApplication.shared.statusBarOrientation.isLandscape {
                location = CGPoint(x: location.y, y: location.x)

                // Increase height if keyboard is active, to avoid dismissing view by accident
                if keyboardShown { location.y -= 120 }
            }

            if !view.point(inside: view.convert(location, from: view.window), with: nil) {  dismiss(animated: true) }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
