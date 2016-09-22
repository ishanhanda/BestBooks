//
//  ISHShowsTopNotificationView.swift
//  ISHTopNotificationView
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

protocol ISHShowsTopNotificationView {
    func viewOnTopOfNotificationView() -> UIView
    func heightForNotificationView() -> CGFloat
    func superViewOfNotificationView() -> UIView
}


extension ISHShowsTopNotificationView where Self: UIViewController {
    
    func showNotificationView(message: String?, time: NSTimeInterval = -1, animations: (() -> ())? , completion: (() -> ())?) -> ISHTopNotificationView {
        let topView = viewOnTopOfNotificationView()
        let superView = superViewOfNotificationView()
        let height = heightForNotificationView()
        
        let notificationView = ISHTopNotificationView.loadFromNib()
        notificationView.messageLabel.text = message
        notificationView.messageLabel.textColor = UIColor.redColor()
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDict = [
            "notificationView": notificationView,
            "topView": topView
        ]
        
        superView.addSubview(notificationView)
        
        var constraintsToAdd = [NSLayoutConstraint]()
        
        constraintsToAdd += NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[topView][notificationView]",
            options: [],
            metrics: nil,
            views: viewsDict
        )
        
        constraintsToAdd += [NSLayoutConstraint(
            item: notificationView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: superView,
            attribute: .Width,
            multiplier: 1, constant: 0)
        ]
        
        let heightConstraint = NSLayoutConstraint(
            item: notificationView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1, constant: 0
        )
        
        notificationView.heightConstraint = heightConstraint
        constraintsToAdd += [heightConstraint]
        
        superView.addConstraints(constraintsToAdd)
        superView.layoutIfNeeded()
        
        heightConstraint.constant = height
        notificationView.alpha = 0
        UIView.animateWithDuration(0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            notificationView.alpha = 1
            superView.layoutIfNeeded()
        }) { (finished) in
            
            if let compBlock = completion {
                compBlock()
            }
            
            delay(time: time, closure: { 
                self.hideNotificationView(notificationView, animations: nil, completion: nil)
            })
        }
        
        return notificationView
    }
    
    
    func hideNotificationView(notificationView: ISHTopNotificationView, animations: (() -> ())? , completion: (() -> ())?) {
        
        let superView = superViewOfNotificationView()
        superView.layoutIfNeeded()
        
        notificationView.heightConstraint.constant = 0
        UIView.animateWithDuration(0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            notificationView.alpha = 0
            superView.layoutIfNeeded()
        }) { (finished) in
            if finished {
                notificationView.removeFromSuperview()
                if let compBlock = completion {
                    compBlock()
                }
            }
        }
    }
}


protocol ISHShowsTopActivityIndicator : ISHShowsTopNotificationView {}

extension ISHShowsTopActivityIndicator where Self: UIViewController {
    
    func showActivityIndicatorView(message: String?, animations: (() -> ())? , completion: (() -> ())?) -> ISHActivityIndicatorView {
        let topView = viewOnTopOfNotificationView()
        let superView = superViewOfNotificationView()
        let height = heightForNotificationView()
        
        let activityIndicatorView = ISHActivityIndicatorView.loadFromNib()
        activityIndicatorView.messageLabel.text = message
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDict = [
            "activityIndicatorView": activityIndicatorView,
            "topView": topView
        ]
        
        superView.addSubview(activityIndicatorView)
        
        var constraintsToAdd = [NSLayoutConstraint]()
        
        constraintsToAdd += NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[topView][activityIndicatorView]",
            options: [],
            metrics: nil,
            views: viewsDict
        )
        
        constraintsToAdd += [NSLayoutConstraint(
            item: activityIndicatorView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: superView,
            attribute: .Width,
            multiplier: 1, constant: 0)
        ]
        
        let heightConstraint = NSLayoutConstraint(
            item: activityIndicatorView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1, constant: 0
        )
        
        activityIndicatorView.heightConstraint = heightConstraint
        constraintsToAdd += [heightConstraint]
        
        superView.addConstraints(constraintsToAdd)
        superView.layoutIfNeeded()
        
        heightConstraint.constant = height
        activityIndicatorView.alpha = 0
        UIView.animateWithDuration(0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            activityIndicatorView.alpha = 1
            superView.layoutIfNeeded()
        }) { (finished) in
            if finished {
                if let compBlock = completion {
                    compBlock()
                }
            }
        }
        
        return activityIndicatorView
    }
}