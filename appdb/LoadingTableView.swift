//
//  LoadingTableView.swift
//  appdb
//
//  Created by ned on 06/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

/*
 *    USAGE FOR FUTURE NED
 *    subclass LoadingTableView, set state.
 *
 *    STATES:
 *      .loading to make spinner appear in center (make sure to return 0 cells)
 *      .done to hide spinner and reload data
 *      use showErrorMessage() to trigger state .error, which will display error message in center
 *
 *    ADDITIONAL PROPERTIES:
 *      animated - enable/disable bounce on reload
 *      showsErrorButton - enable/disable retry button in .error
 *
 */

class LoadingTableView: UITableViewController {

    var animated: Bool = false
    var showsErrorButton: Bool = true
    var showsSpinner: Bool = true
    
    let group = ConstraintGroup()
    
    enum State {
        case done
        case loading
        case error
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.theme_activityIndicatorViewStyle = [.gray, .white]
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    lazy var errorMessage: UILabel = {
        let errorMessage = UILabel()
        errorMessage.theme_textColor = Color.copyrightText
        errorMessage.font = .systemFont(ofSize: (26~~24), weight: UIFont.Weight.semibold)
        errorMessage.numberOfLines = 0
        errorMessage.textAlignment = .center
        errorMessage.makeDynamicFont()
        return errorMessage
    }()
    
    lazy var secondaryErrorMessage: UILabel = {
        let secondaryErrorMessage = UILabel()
        secondaryErrorMessage.theme_textColor = Color.copyrightText
        secondaryErrorMessage.font = .systemFont(ofSize: (19~~17))
        secondaryErrorMessage.numberOfLines = 0
        secondaryErrorMessage.textAlignment = .center
        secondaryErrorMessage.makeDynamicFont()
        return secondaryErrorMessage
    }()
    
    lazy var refreshButton: UIButton = {
        let refreshButton = ButtonFactory.createRetryButton(text: "Retry".localized(), color: Color.copyrightText)
        return refreshButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        view.addSubview(errorMessage)
        view.addSubview(secondaryErrorMessage)
        view.addSubview(refreshButton)
        
        errorMessage.isHidden = true
        secondaryErrorMessage.isHidden = true
        refreshButton.isHidden = true
        
        setConstraints(.loading)
    }

    fileprivate func animate() {
        // Bounce animation
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
            
            errorMessage.isHidden = true
            secondaryErrorMessage.isHidden = true
            refreshButton.isHidden = true
            
            switch state {
            case .done:
                activityIndicator.stopAnimating()
                tableView.isScrollEnabled = true
                tableView.reloadData()
                if animated { animate() }
            case .loading:
                if showsSpinner {
                    activityIndicator.startAnimating()
                }
                tableView.isScrollEnabled = false
                
            case .error:
                
                errorMessage.isHidden = false
                secondaryErrorMessage.isHidden = false
                if showsErrorButton {
                    refreshButton.isHidden = false
                }
                
                activityIndicator.stopAnimating()
                
                tableView.isScrollEnabled = true
                
                setConstraints(.error)
            }
        }
    }
    
    // MARK: - Orientation

    func setConstraints(_ state: State) {

        let offset = (navigationController?.navigationBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.height
        
        switch state {
        case .loading:
            constrain(activityIndicator) { indicator in
                indicator.centerX == indicator.superview!.centerX
                indicator.centerY == indicator.superview!.centerY - offset
            }
        case .error:
            if showsErrorButton {
                constrain(errorMessage, secondaryErrorMessage, refreshButton, replace: group) { message, secondaryMessage, button in
                    message.left == message.superview!.left + 30
                    message.right == message.superview!.right - 30
                    message.centerX == message.superview!.centerX
                    message.centerY == message.superview!.centerY - offset - 35
                    
                    secondaryMessage.left == message.left
                    secondaryMessage.right == message.right
                    secondaryMessage.top == message.bottom + 10
                    
                    button.top == secondaryMessage.bottom + 30
                    button.centerX == button.superview!.centerX
                    button.width == CGFloat(refreshButton.tag + 20)
                }
            } else if secondaryErrorMessage.text?.isEmpty ?? false {
                constrain(errorMessage, replace: group) { message in
                    message.left == message.superview!.left + 30
                    message.right == message.superview!.right - 30
                    message.centerX == message.superview!.centerX
                    message.centerY == message.superview!.centerY - offset - 25
                }
            } else {
                constrain(errorMessage, secondaryErrorMessage, replace: group) { message, secondaryMessage in
                    message.left == message.superview!.left + 30
                    message.right == message.superview!.right - 30
                    message.centerX == message.superview!.centerX
                    message.centerY == message.superview!.centerY - offset - 20
                    
                    secondaryMessage.left == message.left
                    secondaryMessage.right == message.right
                    secondaryMessage.top == message.bottom + 10
                }
            }
        default: break
        }
    }
    
    // MARK: - Display error message
    
    func showErrorMessage(text: String = "", secondaryText: String = "", animated: Bool = true) {
        errorMessage.text = text
        secondaryErrorMessage.text = secondaryText.prettified
        state = .error
        
        if animated { animate() }
    }
    
    // MARK: - Handle rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if self.state != .done { self.setConstraints(self.state) }
        }, completion: nil)
    }

}
