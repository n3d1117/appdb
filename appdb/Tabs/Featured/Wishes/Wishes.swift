//
//  Wishes.swift
//  appdb
//
//  Created by ned on 07/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography

class Wishes: UIViewController {

    var currentViewController: UIViewController?

    var headerView: ILTranslucentView!
    var control: UISegmentedControl!
    var line: UIView!

    // Constraints group, will be replaced when orientation changes
    var group = ConstraintGroup()

    lazy var viewControllersArray: [UIViewController] = {
        [NewWishes(), FulfilledWishes()]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide bottom hairline
        if let nav = navigationController { nav.navigationBar.hideBottomHairline() }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(self.dismissAnimated))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))

        headerView = ILTranslucentView(frame: .zero)
        headerView.translucentAlpha = 1

        control = UISegmentedControl(items: ["New".localized(), "Fulfilled".localized()])
        control.addTarget(self, action: #selector(self.indexDidChange), for: .valueChanged)
        control.selectedSegmentIndex = 0

        line = UIView(frame: .zero)
        line.theme_backgroundColor = Color.borderColor

        headerView.addSubview(line)
        headerView.addSubview(control)
        view.addSubview(headerView)

        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        title = "Wishes".localized()

        // Set constraints
        setConstraints()

        // Add first view controller
        currentViewController = viewControllersArray[0]
        addChild(currentViewController!)
        addSubview(currentViewController!.view)
    }

    // MARK: - Constraints

    private func setConstraints() {
        constrain(headerView, control, line, replace: group) { header, control, line in

            header.top ~== header.superview!.topMargin
            header.leading ~== header.superview!.leading
            header.trailing ~== header.superview!.trailing
            header.height ~== 40

            line.height ~== 1 / UIScreen.main.scale
            line.leading ~== header.leading
            line.trailing ~== header.trailing
            line.top ~== header.bottom ~- 0.5

            control.top ~== header.top
            control.centerX ~== header.centerX
            control.width ~== (300 ~~ 260)
        }
    }

    // Update constraints to reflect orientation change (recalculate navigationBar + statusBar height)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.headerView != nil else { return }
            self.setConstraints()
        }, completion: nil)
    }

    // MARK: - Segmented Control index did change

    // Switch table view based on segment index
    @objc func indexDidChange(sender: UISegmentedControl) {
        let new: UIViewController = viewControllersArray[sender.selectedSegmentIndex]
        self.cycle(from: self.currentViewController!, to: new)
        self.currentViewController = new
    }

    @objc func dismissAnimated() {
        dismiss(animated: true)
    }
}

extension Wishes {

    // Switch between table views with fade animation
    func cycle(from old: UIViewController, to new: UIViewController) {
        control.isUserInteractionEnabled = false
        old.willMove(toParent: nil)
        self.addChild(new)
        self.addSubview(new.view)
        new.view.alpha = 0
        new.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: {
            new.view.alpha = 1
            old.view.alpha = 0
        }, completion: { _ in
            old.view.removeFromSuperview()
            old.removeFromParent()
            new.didMove(toParent: self)
            self.control.isUserInteractionEnabled = true
        })
    }

    // Add subview and constraints
    func addSubview(_ subview: UIView) {
        view.addSubview(subview)
        constrain(view, subview, headerView) { view, subview, header in
            subview.top ~== header.bottom
            subview.bottom ~== view.bottom
            subview.trailing ~== view.trailing
            subview.leading ~== view.leading
        }
    }
}

// MARK: - Request AppStore app for automatic cracking

extension Wishes {
    @objc private func addTapped() {
        let alert = UIAlertController(title: "Enter AppStore URL".localized(), message: "Enter below the AppStore URL of the app you'd like to request".localized(), preferredStyle: .alert, adaptive: true)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.urlTextChanged), for: .editingChanged)
            textField.placeholder = "https://apps.apple.com/us/app/...".localized()
            textField.keyboardType = .URL
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let load = UIAlertAction(title: "Add".localized(), style: .default, handler: { _ in
            guard var text = alert.textFields?[0].text else { return }
            if !text.hasPrefix("http://"), !text.hasPrefix("https://") {
                text = "https://" + text
            }
            guard let url = URL(string: text) else {
                Messages.shared.showError(message: "Error: malformed url".localized(), context: .viewController(self))
                return
            }
            API.createPublishRequest(appStoreUrl: url.absoluteString) { error in
                if let error = error {
                    Messages.shared.showError(message: error.prettified, context: .viewController(self))
                } else {
                    Messages.shared.showSuccess(message: "App has been requested successfully!".localized(), context: .viewController(self))
                }
            }
        })

        alert.addAction(load)
        load.isEnabled = false

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    @objc func urlTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            // Enable 'Load' button if text input is a valid url
            if let text = sender.text, isValidUrl(urlString: text) {
                (alert.actions[1] as UIAlertAction).isEnabled = true
            } else {
                (alert.actions[1] as UIAlertAction).isEnabled = false
            }
        }
    }

    func isValidUrl(urlString: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard detector != nil && !urlString.isEmpty else { return false }
        return detector!.numberOfMatches(in: urlString, options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                         range: NSRange(location: 0, length: urlString.count)) > 0
    }
}
