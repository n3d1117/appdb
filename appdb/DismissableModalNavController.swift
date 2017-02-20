//
//  DismissableModalNavController.swift
//  appdb
//
//  Created by ned on 20/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit

/* TODO - use presentation controller instead? */
class DismissableModalNavController : UINavigationController, UIGestureRecognizerDelegate {
    
    private var recognizer : UITapGestureRecognizer!
    
    // Content size for iPad popover
    var popoverContentSize : CGSize {
        get {
            if view.bounds.size.width > view.bounds.size.height {
                let proposedHeight = view.bounds.size.height*(3/4)
                return CGSize(width: proposedHeight, height: proposedHeight)
            } else {
                let proposedWidth = view.bounds.size.width*(3/4)
                return CGSize(width: proposedWidth, height: proposedWidth)
            }
        }
    }
    
    // Set popover size
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_IPAD { self.preferredContentSize = popoverContentSize }
        
    }
    
    // Add gesture recognizer if needed
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if IS_IPAD, recognizer == nil {
            recognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTapBehind))
            recognizer.delegate = self
            recognizer.numberOfTapsRequired = 1
            recognizer.cancelsTouchesInView = false
            self.view.window?.addGestureRecognizer(recognizer)
        }
    }
    
    // Remove gesture recognizer if needed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if IS_IPAD, recognizer != nil {
            view.window?.removeGestureRecognizer(recognizer)
            recognizer = nil
        }
    }
    
    // Dismiss view if tapped outside
    func handleTapBehind(sender: UIGestureRecognizer) {
        
        if IS_IPAD, sender.state == .ended {
            
            var location: CGPoint = sender.location(in: nil)
            
            // in landscape view you will have to swap the location coordinates
            if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
                location = CGPoint(x: location.y, y: location.x)
            }
            
            if !view.point(inside: view.convert(location, from: view.window), with: nil) {  dismiss(animated: true) }
        }
    }
    
    func gestureRecognizer(_ sender: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}
