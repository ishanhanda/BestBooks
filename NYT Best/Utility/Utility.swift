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
func delay(time delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
    func showSingleAlert(_ message: String?, title: String? = "Error", buttonTitle: String? = "OK", action: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { (alertAction) -> Void in
            if let someAction = action { someAction() }
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}


// MARK: - UITableView extension helpers
extension UITableView {
    func indexPathForView(_ view: AnyObject) -> IndexPath? {
        let originInTableView = self.convert(CGPoint.zero, from: (view as! UIView))
        return self.indexPathForRow(at: originInTableView)
    }
}


// MARK: - User Default Helpers

public func setUserDefault(_ key: String, value: AnyObject) {
    let userDefaults = UserDefaults.standard
    userDefaults.setValue(value, forKey: key)
    userDefaults.synchronize()
}


public func setUserDefault(_ key: String, forBoolValue value: Bool) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(value, forKey: key)
    userDefaults.synchronize()
}


public func getUserDefault(_ key: String) -> AnyObject? {
    let userDefaults = UserDefaults.standard
    return userDefaults.value(forKey: key) as AnyObject
}


public func checkUserDefaultsForKey(_ key: String) -> Bool {
    let userDefaults = UserDefaults.standard
    return userDefaults.bool(forKey: key)
}
