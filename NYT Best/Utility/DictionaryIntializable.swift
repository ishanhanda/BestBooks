//
//  DictionaryIntializable.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation


protocol DictionaryInitializable {
    init?(dictionary: Dictionary<String, AnyObject>)
}