//
//  ISHShowsTopNotificationView.swift
//  ISHTopNotificationView
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

/// This protocol is required for a UIViewController to display ISHTopNotificationView
protocol ISHShowsTopNotificationView {
    
    /**
     - returns: The view under which the notification view is to be displayed
    */
    func viewOnTopOfNotificationView() -> UIView
    
    /**
     - returns: The height for ISHTopNotificationView
     */
    func heightForNotificationView() -> CGFloat
    
    /**
     - returns: The superview which contains the view returned by viewOnTopOfNotificationView() and on which the ISHTopNotificationView will be added.
     */
    func superViewOfNotificationView() -> UIView
}

/// Style for notification view message
enum ISHNotificationStyle {
    case normal
    case alert
}


/*
 This extension defines the methods for showing and hiding ISHTopNotificationView
 */
extension ISHShowsTopNotificationView where Self: UIViewController {
    
    /**
    Shows the ISHTopNotificationView on UIViewController
     - parameter message: The message to be displayed.
     - parameter style: Style for the notification.
     - parameter time: The time after which the notificatin is dismissed. Default -1, indicating that the notification will not be dismissed automatically.
     - parameter animations: Optional animations to run along with presenting of the notification
     - parameter completion: Block to execute after presentation finishes.
     -returns: The instance of ISHTopNotificationView which was added.
     */
    func showNotificationView(_ message: String?, style: ISHNotificationStyle = .normal , time: TimeInterval = -1, animations: (() -> ())? = nil, completion: (() -> ())? = nil) -> ISHTopNotificationView {
        let topView = viewOnTopOfNotificationView()
        let superView = superViewOfNotificationView()
        let height = heightForNotificationView()
        
        let notificationView = ISHTopNotificationView.loadFromNib()
        notificationView.messageLabel.text = message
        
        switch style {
        case .alert:
            notificationView.messageLabel.textColor = UIColor.red
        case .normal:
            notificationView.messageLabel.textColor = UIColor.white
        }
        
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDict = [
            "notificationView": notificationView,
            "topView": topView
        ]
        
        superView.addSubview(notificationView)
        
        var constraintsToAdd = [NSLayoutConstraint]()
        
        constraintsToAdd += NSLayoutConstraint.constraints(
            withVisualFormat: "V:[topView][notificationView]",
            options: [],
            metrics: nil,
            views: viewsDict
        )
        
        constraintsToAdd += [NSLayoutConstraint(
            item: notificationView,
            attribute: .width,
            relatedBy: .equal,
            toItem: superView,
            attribute: .width,
            multiplier: 1, constant: 0)
        ]
        
        let heightConstraint = NSLayoutConstraint(
            item: notificationView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1, constant: 0
        )
        
        notificationView.heightConstraint = heightConstraint
        constraintsToAdd += [heightConstraint]
        
        superView.addConstraints(constraintsToAdd)
        superView.layoutIfNeeded()
        
        heightConstraint.constant = height
        notificationView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            notificationView.alpha = 1
            superView.layoutIfNeeded()
        }, completion: { (finished) in
            
            if let compBlock = completion {
                compBlock()
            }
            
            if time >= 0 {
                delay(time: time, closure: {
                    self.hideNotificationView(notificationView, animations: nil, completion: nil)
                })
            }
        }) 
        
        return notificationView
    }
    
    
    /**
     Removes the ISHTopNotificationView from UIViewController
     - parameter notificationView: The ISHTopNotificationView to be removed.
     - parameter animations: Optional animations to run along with removal of the notification
     - parameter completion: Block to execute after notification is reomved.
     */
    func hideNotificationView(_ notificationView: ISHTopNotificationView, animations: (() -> ())? , completion: (() -> ())?) {
        
        let superView = superViewOfNotificationView()
        superView.layoutIfNeeded()
        
        notificationView.heightConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            notificationView.alpha = 0
            superView.layoutIfNeeded()
        }, completion: { (finished) in
            if finished {
                notificationView.removeFromSuperview()
                if let compBlock = completion {
                    compBlock()
                }
            }
        }) 
    }
}


/// Inherits from ISHShowsTopNotificationView. Used specifically to display Message notification with activity indicator.
protocol ISHShowsTopActivityIndicator : ISHShowsTopNotificationView {}


/*
 This extension defines the methods for showing activity indicator based notification
 */
extension ISHShowsTopActivityIndicator where Self: UIViewController {
    
    /**
     Shows the ISHTopNotificationView on UIViewController
     - parameter message: The message to be displayed.
     - parameter style: Style for the notification.
     - parameter animations: Optional animations to run along with presenting of the notification
     - parameter completion: Block to execute after presentation finishes.
     -returns: The instance of ISHActivityIndicatorView which was added.
     */
    func showActivityIndicatorView(_ message: String?, style: ISHNotificationStyle = .normal , animations: (() -> ())? , completion: (() -> ())?) -> ISHActivityIndicatorView {
        let topView = viewOnTopOfNotificationView()
        let superView = superViewOfNotificationView()
        let height = heightForNotificationView()
        
        let activityIndicatorView = ISHActivityIndicatorView.loadFromNib()
        activityIndicatorView.messageLabel.text = message
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .alert:
            activityIndicatorView.messageLabel.textColor = UIColor.red
        case .normal:
            activityIndicatorView.messageLabel.textColor = UIColor.white
        }

        let viewsDict = [
            "activityIndicatorView": activityIndicatorView,
            "topView": topView
        ]
        
        superView.addSubview(activityIndicatorView)
        
        var constraintsToAdd = [NSLayoutConstraint]()
        
        constraintsToAdd += NSLayoutConstraint.constraints(
            withVisualFormat: "V:[topView][activityIndicatorView]",
            options: [],
            metrics: nil,
            views: viewsDict
        )
        
        constraintsToAdd += [NSLayoutConstraint(
            item: activityIndicatorView,
            attribute: .width,
            relatedBy: .equal,
            toItem: superView,
            attribute: .width,
            multiplier: 1, constant: 0)
        ]
        
        let heightConstraint = NSLayoutConstraint(
            item: activityIndicatorView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1, constant: 0
        )
        
        activityIndicatorView.heightConstraint = heightConstraint
        constraintsToAdd += [heightConstraint]
        
        superView.addConstraints(constraintsToAdd)
        superView.layoutIfNeeded()
        
        heightConstraint.constant = height
        activityIndicatorView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            if let givenAnimations = animations {
                givenAnimations()
            }
            
            activityIndicatorView.alpha = 1
            superView.layoutIfNeeded()
        }, completion: { (finished) in
            if finished {
                if let compBlock = completion {
                    compBlock()
                }
            }
        }) 
        
        return activityIndicatorView
    }
}
