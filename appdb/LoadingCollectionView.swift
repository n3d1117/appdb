//
//  LoadingCollectionView.swift
//  appdb
//
//  Created by ned on 07/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Cartography

class LoadingCollectionView: UICollectionViewController {
    
    var animated: Bool = false
    var showsErrorButton: Bool = true
    
    enum State {
        case done
        case loading
        case error
        case justHideIndicator
    }
    
    var activityIndicator: UIActivityIndicatorView!
    var errorMessage: UILabel!
    var secondaryErrorMessage: UILabel!
    var refreshButton: UIButton!
    var group = ConstraintGroup()
    
    // Bounce animation
    fileprivate func animate() {
        self.view.transform = CGAffineTransform.identity.scaledBy(x: 0.96, y: 0.96)
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.01, y: 1.01)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            }, completion: nil)
        })
    }
    
    var state: State = .done {
        didSet {
            guard let collectionView = collectionView else { return }
            switch state {
            case .justHideIndicator:
                if let a = activityIndicator { a.stopAnimating() }
            case .done:
                if let a = activityIndicator { a.stopAnimating() }
                collectionView.isScrollEnabled = true
                collectionView.reloadData()
                if animated { animate() }
                
            case .loading:
                // Set Up
                collectionView.isScrollEnabled = false
                
                //Set up Activity Indicator View
                activityIndicator = UIActivityIndicatorView()
                activityIndicator.theme_activityIndicatorViewStyle = [.gray, .white]
                activityIndicator.hidesWhenStopped = true
                activityIndicator.startAnimating()
                
                if let refreshButton = refreshButton, let error = errorMessage, let secondary = secondaryErrorMessage {
                    refreshButton.isHidden = true
                    error.isHidden = true
                    secondary.isHidden = true
                }
                
                view.addSubview(activityIndicator)
                
                setConstraints(.loading)
                
            case .error:
                //Set up Error Message
                errorMessage = UILabel()
                errorMessage.theme_textColor = Color.copyrightText
                if #available(iOS 8.2, *) {
                    errorMessage.font = .systemFont(ofSize: (26~~24), weight: UIFont.Weight.semibold)
                } else {
                    errorMessage.font = .systemFont(ofSize: (26~~24))
                }
                errorMessage.numberOfLines = 0
                errorMessage.textAlignment = .center
                errorMessage.isHidden = false
                errorMessage.makeDynamicFont()
                
                //Set up Secondary Error Message
                secondaryErrorMessage = UILabel()
                secondaryErrorMessage.theme_textColor = Color.copyrightText
                secondaryErrorMessage.font = .systemFont(ofSize: (19~~17))
                secondaryErrorMessage.numberOfLines = 0
                secondaryErrorMessage.textAlignment = .center
                secondaryErrorMessage.isHidden = false
                secondaryErrorMessage.makeDynamicFont()
                
                // Set up 'Retry' button
                if showsErrorButton {
                    refreshButton = ButtonFactory.createRetryButton(text: "Retry".localized(), color: Color.copyrightText)
                    refreshButton.isHidden = false
                }
                
                activityIndicator.stopAnimating()
                
                if showsErrorButton { view.addSubview(refreshButton) }
                view.addSubview(errorMessage)
                view.addSubview(secondaryErrorMessage)
                
                if animated { animate() }
                
                setConstraints(.error)
            }
        }
    }
    
    // MARK: - Orientation
    
    func setConstraints(_ state: State) {
        
        switch state {
        case .loading:
            constrain(activityIndicator, replace: group) { indicator in
                indicator.center == indicator.superview!.center
            }
        case .error:
            if showsErrorButton {
                constrain(errorMessage, secondaryErrorMessage, refreshButton, replace: group) { message, secondaryMessage, button in
                    message.left == message.superview!.left + 30
                    message.right == message.superview!.right - 30
                    message.centerX == message.superview!.centerX
                    message.centerY == message.superview!.centerY - 35
                    
                    secondaryMessage.left == message.left
                    secondaryMessage.right == message.right
                    secondaryMessage.top == message.bottom + 10
                    
                    button.top == secondaryMessage.bottom + 30
                    button.centerX == button.superview!.centerX
                    button.width == CGFloat(refreshButton.tag + 20)
                }
            } else {
                constrain(errorMessage, secondaryErrorMessage, replace: group) { message, secondaryMessage in
                    message.left == message.superview!.left + 30
                    message.right == message.superview!.right - 30
                    message.centerX == message.superview!.centerX
                    message.centerY == message.superview!.centerY - 20
                    
                    secondaryMessage.left == message.left
                    secondaryMessage.right == message.right
                    secondaryMessage.top == message.bottom + 10
                }
            }
        default: break
        }
    }
    
    func hideAllElements() {
        collectionView?.alpha = 0
        if let e = errorMessage { e.alpha = 0 }
        if let s = secondaryErrorMessage { s.alpha = 0 }
        if let r = refreshButton { r.alpha = 0 }
    }
    
    func showAllElements() {
        collectionView?.alpha = 1
        if let e = errorMessage { e.alpha = 1 }
        if let s = secondaryErrorMessage { s.alpha = 1 }
        if let r = refreshButton { r.alpha = 1 }
    }
    
    // Update constraints to reflect orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            if self.state != .done { self.setConstraints(self.state) }
        }, completion: nil)
    }
    
    // MARK: - error Screen
    func showErrorMessage(text: String = "", secondaryText: String = "", animated: Bool = true) {
        let shouldAnimate: Bool = self.animated
        if animated { self.animated = true }
        state = .error
        secondaryErrorMessage.text = secondaryText
        errorMessage.text = text
        if animated { self.animated = shouldAnimate }
    }
    
}
