//
//  Downloads.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class Downloads: UIViewController {

    var currentViewController: UIViewController?

    var headerView: ILTranslucentView!
    var control: UISegmentedControl!
    var line: UIView!

    // Constraints group, will be replaced when orientation changes
    var group = ConstraintGroup()

    lazy var viewControllersArray: [UIViewController] = {
        [QueuedApps(), Library(), Downloading()]
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide bottom hairline
        if let nav = navigationController { nav.navigationBar.hideBottomHairline() }

        headerView = ILTranslucentView(frame: .zero)
        headerView.translucentAlpha = 1

        control = UISegmentedControl(items: ["Queued".localized(), "Library".localized(), "Downloading".localized()])
        control.addTarget(self, action: #selector(self.indexDidChange), for: .valueChanged)
        control.selectedSegmentIndex = 0

        line = UIView(frame: .zero)
        line.theme_backgroundColor = Color.borderColor

        headerView.addSubview(line)
        headerView.addSubview(control)
        view.addSubview(headerView)

        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        title = "Downloads".localized()

        // Subscribe to changes to the number of currently queued apps
        NotificationCenter.default.addObserver(self, selector: #selector(updateQueuedAppsTitle(_:)), name: .UpdateQueuedSegmentTitle, object: nil)

        // Set constraints
        setConstraints()

        // Add first view controller
        currentViewController = viewControllersArray[0]
        addChild(currentViewController!)
        addSubview(currentViewController!.view)

        // Preload Library view controller
        _ = viewControllersArray[1].view
    }

    // Update queued apps title in segmented control
    @objc private func updateQueuedAppsTitle(_ notification: NSNotification) {
        if let number = notification.userInfo?["number"] as? Int, let tab = notification.userInfo?["tab"] as? Int {
            if tab == 0 {
                if number != 0 {
                    control.setTitle("Queued".localized() + " (\(number))", forSegmentAt: tab)
                } else {
                    control.setTitle("Queued".localized(), forSegmentAt: tab)
                }
            } else if tab == 2 {
                if number != 0 {
                    control.setTitle("Downloading".localized() + " (\(number))", forSegmentAt: tab)
                } else {
                    control.setTitle("Downloading".localized(), forSegmentAt: tab)
                }
            }
        }
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

            let screenWidth: CGFloat = min(CGFloat(UIScreen.main.bounds.width), CGFloat(UIScreen.main.bounds.height))
            let width = (370 ~~ 330) > screenWidth ? (screenWidth - Global.Size.margin.value * 2) : (370 ~~ 330)
            control.width ~== width
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

    // Called from AppDelegate
    func switchToIndex(i: Int) {
        guard let control = control else { delay(0.8) { self.switchToIndex(i: i) }; return }
        if control.selectedSegmentIndex != i {
            control.selectedSegmentIndex = i
            let new: UIViewController = viewControllersArray[i]
            self.cycle(from: self.currentViewController!, to: new)
            self.currentViewController = new
        }
    }
}

extension Downloads {

    //
    // Switch between table views with fade animation
    // Credits: https://github.com/woelmer/SwitchChildViewControllersWithAutoLayout
    //
    func cycle(from old: UIViewController, to new: UIViewController) {
        control.isUserInteractionEnabled = false
        old.willMove(toParent: nil)
        self.addChild(new)
        self.addSubview(new.view)
        new.view.alpha = 0
        new.view.layoutIfNeeded()

        // Set add right bar button item if selected tab is Downloading
        self.navigationItem.leftBarButtonItem = new is Downloading ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped)) : nil

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

// MARK: - URL text input on add button tapped

extension Downloads {
    @objc private func addTapped() {
        let alert = UIAlertController(title: "Enter URL".localized(), message: "Enter below the URL of the .ipa file you want to download".localized(), preferredStyle: .alert, adaptive: true)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.urlTextChanged), for: .editingChanged)
            textField.placeholder = "https://example.com/file.ipa".localized()
            textField.keyboardType = .URL
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.clearButtonMode = .whileEditing
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        let load = UIAlertAction(title: "Load".localized(), style: .default, handler: { _ in
            guard var text = alert.textFields?[0].text else { return }
            if !text.hasPrefix("http://"), !text.hasPrefix("https://") {
                text = "http://" + text
            }
            guard let url = URL(string: text) else { return }
            let webVc = IPAWebViewController(delegate: self, url: url)
            let nav = IPAWebViewNavController(rootViewController: webVc)
            self.present(nav, animated: true)
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

//
// MARK: - IPAWebViewControllerDelegate
// Show success message once download started
//
extension Downloads: IPAWebViewControllerDelegate {
    func didDismiss() {
        if #available(iOS 10.0, *) { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        delay(0.8) {
            Messages.shared.showSuccess(message: "File download has started".localized())
        }
    }
}
