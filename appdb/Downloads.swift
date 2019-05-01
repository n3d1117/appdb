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
        return [QueuedApps(), Library(), ActiveDownloads()]
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
        if let number = notification.userInfo?["number"] as? Int {
            if number == 0 {
                control.setTitle("Queued (\(number))", forSegmentAt: 0) // todo localize
            } else {
                control.setTitle("Queued", forSegmentAt: 0) // todo localize
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
            control.width == 360~~310
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
