//
//  LoadingCollectionView.swift
//  appdb
//
//  Created by ned on 03/10/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Cartography

class LoadingCollectionView: UICollectionViewController {
    
    enum State {
        case done(animated: Bool)
        case loading
        case error(first: String, second: String, animated: Bool)
        case hideIndicator
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
    
    var hasSegment: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        view.addSubview(errorMessage)
        view.addSubview(secondaryErrorMessage)
        
        errorMessage.isHidden = true
        secondaryErrorMessage.isHidden = true
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        constrain(activityIndicator, errorMessage, secondaryErrorMessage) { a, e, s in
            if !hasSegment {
                a.center == a.superview!.center
            } else {
                a.centerX == a.superview!.centerX
                a.centerY == a.superview!.centerY - 50
            }
            
            e.left == e.superview!.left + 30
            e.right == e.superview!.right - 30
            e.centerX == e.superview!.centerX
            if !hasSegment {
                e.centerY == e.superview!.centerY - 20
            } else {
                e.centerY == e.superview!.centerY - 55
            }
            
            s.left == e.left
            s.right == e.right
            s.top == e.bottom + 10
        }
    }
    
    var state: State = .hideIndicator {
        didSet {
            
            errorMessage.isHidden = true
            secondaryErrorMessage.isHidden = true

            switch state {
            case .hideIndicator:
                activityIndicator.stopAnimating()
                
            case .done(let animated):
                activityIndicator.stopAnimating()
                if animated { animate() }
                
            case .loading:
                activityIndicator.startAnimating()
                
            case .error(let first, let second, let animated):

                errorMessage.text = first
                secondaryErrorMessage.text = second.prettified
                
                errorMessage.isHidden = false
                secondaryErrorMessage.isHidden = second.isEmpty 
                
                activityIndicator.stopAnimating()
                
                if animated { animate() }
            }
        }
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
}

extension LoadingCollectionView {
    var isLoading: Bool {
        if case LoadingCollectionView.State.loading = state {
            return true
        } else {
            return false
        }
    }
    
    var isDone: Bool {
        if case LoadingCollectionView.State.done(_) = state {
            return true
        } else {
            return false
        }
    }
    
    var hasError: Bool {
        if case LoadingCollectionView.State.error(_, _, _) = state {
            return true
        } else {
            return false
        }
    }
}
