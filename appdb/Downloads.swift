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
        return [QueuedApps(), Library(), Downloading()]
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
        
        control = UISegmentedControl(items: ["Queued", "Library", "Downloading"]) // todo localize
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
        addSubview(subView: currentViewController!.view)
    }
    
    // Update queued apps title in segmented control
    @objc fileprivate func updateQueuedAppsTitle(_ notification: NSNotification) {
        if let number = notification.userInfo?["number"] as? Int, let tab = notification.userInfo?["tab"] as? Int {
            if tab == 0 {
                if number != 0 {
                    control.setTitle("Queued (\(number))", forSegmentAt: tab) // todo localize
                } else {
                    control.setTitle("Queued", forSegmentAt: tab) // todo localize
                }
            } else if tab == 2 {
                if number != 0 {
                    control.setTitle("Downloading (\(number))", forSegmentAt: tab) // todo localize
                } else {
                    control.setTitle("Downloading", forSegmentAt: tab) // todo localize
                }
            }
        }
    }
    
    // MARK: - Constraints
    
    fileprivate func setConstraints() {
        constrain(view, headerView, control, line, replace: group) { view, header, control, line in
            
            // Calculate navBar + status bar height
            var height: CGFloat = 0
            if let nav = navigationController {
                height = nav.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            }
            
            // Fixes hotspot status bar on non X devices
            if !Global.hasNotch, UIApplication.shared.statusBarFrame.height > 20.0 {
                height -= (UIApplication.shared.statusBarFrame.height - 20.0)
            }
            
            header.top == view.top + height
            header.left == view.left
            header.right == view.right
            header.height == 40
            
            line.height == 1/UIScreen.main.scale
            line.left == header.left
            line.right == header.right
            line.top == header.bottom - 0.5
            
            control.top == header.top
            control.centerX == header.centerX
            control.width == 370~~330
        }
    }
    
    // Update constraints to reflect orientation change (recalculate navigationBar + statusBar height)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
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
        self.addSubview(subView: new.view)
        new.view.alpha = 0
        new.view.layoutIfNeeded()
        self.navigationItem.rightBarButtonItem = new is Downloading ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped)) : nil
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
    func addSubview(subView: UIView) {
        view.addSubview(subView)
        constrain(view, subView, headerView) { v, s, h in
            s.top == h.bottom
            s.bottom == v.bottom
            s.right == v.right
            s.left == v.left
        }
    }
}

// MARK: - URL text input on add button tapped

extension Downloads {
    
    @objc fileprivate func addTapped() {
        // todo localize
        let alert = UIAlertController(title: "Enter URL", message: "Enter below the URL of the .ipa file you want to download", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.urlTextChanged), for: .editingChanged)
            textField.placeholder = "https://example.com/file.ipa" // todo localize
            textField.keyboardType = .URL
            textField.theme_keyboardAppearance = [.light, .dark]
            textField.clearButtonMode = .whileEditing
        })
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        let load = UIAlertAction(title: "Load".localized(), style: .default, handler: { _ in
            guard var text = alert.textFields?[0].text else { return }
            if !text.hasPrefix("http://"), !text.hasPrefix("https://") {
                text = "http://" + text
            }
            guard let url = URL(string: text) else { return }
            let webVc = IPAWebViewController(url, delegate: self)
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
        guard (detector != nil && urlString.count > 0) else { return false }
        return detector!.numberOfMatches(in: urlString, options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                         range: NSMakeRange(0, urlString.count)) > 0
    }
}

//
//   MARK: - IPAWebViewControllerDelegate
//   Show success message once download started
//
extension Downloads: IPAWebViewControllerDelegate {
    func didDismiss() {
        delay(0.8) {
            Messages.shared.showSuccess(message: "File download started successfully") // todo localize
        }
    }
}
