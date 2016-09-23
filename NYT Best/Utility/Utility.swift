//
//  Utility.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit


// MARK: - Dispatch Utility helpers
/**
 Helper function to execute closure after time delay
 
 - parameter delay: Time in seconds
 - parameter closure: Closure to execute after delay
 */
func delay(time delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


// MARK: - UIViewController Utility Extension
extension UIViewController {
    /**
     Helper function show alert with single Button
     
     - parameter title: Title for Alert
     - parameter message: Message to display
     - parameter buttonTitle: Title for Button
     - parameter action: block to execute on button click.
     */
    func showSingleAlert(message: String?, title: String? = "Error", buttonTitle: String? = "OK", action: (Void -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .Default) { (alertAction) -> Void in
            if let someAction = action { someAction() }
        }
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


// MARK: - UITableView extension helpers
extension UITableView {
    func indexPathForView(view: AnyObject) -> NSIndexPath? {
        let originInTableView = self.convertPoint(CGPointZero, fromView: (view as! UIView))
        return self.indexPathForRowAtPoint(originInTableView)
    }
}


// MARK: - User Default Helpers

public func setUserDefault(key: String, value: AnyObject) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(value, forKey: key)
    userDefaults.synchronize()
}


public func setUserDefault(key: String, forBoolValue value: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(value, forKey: key)
    userDefaults.synchronize()
}


public func getUserDefault(key: String) -> AnyObject? {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    return userDefaults.valueForKey(key)
}


public func checkUserDefaultsForKey(key: String) -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    return userDefaults.boolForKey(key)
}