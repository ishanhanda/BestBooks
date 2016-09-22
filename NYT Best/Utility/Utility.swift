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


// MARK: - UICollectionView extension helpers
extension UICollectionView {
    func indexPathForView(view: AnyObject) -> NSIndexPath? {
        let originInCollectioView = self.convertPoint(CGPointZero, fromView: (view as! UIView))
        return self.indexPathForItemAtPoint(originInCollectioView)
    }
}


// MARK: - UITableView extension helpers
extension UITableView {
    func indexPathForView(view: AnyObject) -> NSIndexPath? {
        let originInTableView = self.convertPoint(CGPointZero, fromView: (view as! UIView))
        return self.indexPathForRowAtPoint(originInTableView)
    }
}


//MARK: - User Default Helpers

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


// MARK: - General Utility helpers

func getDictionaryFromJSON(jsonFileName: String) -> [String: AnyObject]? {
    guard let filepath = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json") else {
        return nil
    }
    
    guard let data = NSData(contentsOfFile: filepath) else {
        return nil
    }
    
    do {
        let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        return dict
    } catch {
        print(error)
        return nil
    }
}


public func colorFromHexString(hexString: String) -> UIColor {
    var cString:String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substringFromIndex(1)
    }
    
    if (cString.characters.count != 6) {
        return UIColor.grayColor()
    }
    
    let rString = (cString as NSString).substringToIndex(2)
    let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
    let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    NSScanner(string: rString).scanHexInt(&r)
    NSScanner(string: gString).scanHexInt(&g)
    NSScanner(string: bString).scanHexInt(&b)
    
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}


extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}


extension Float {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return round(self * divisor) / divisor
    }
}