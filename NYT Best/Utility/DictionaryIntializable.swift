//
//  DictionaryIntializable.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

/// Protocol to initialize objects with a Dictionary parameter.
protocol DictionaryInitializable {
    
    /**
     Initializer with a Dictionary parameter.
     - parameter dictionary: The dicitonary with which the object will be initialized.
    */
    init?(dictionary: Dictionary<String, AnyObject>)
}