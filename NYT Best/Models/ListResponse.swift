//
//  ListResponse.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

/// Model to store Lists response fetched from api
struct ListResponse {
    var listCount: Int
    var lists: [BookList]
}


extension ListResponse: DictionaryInitializable {
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let
            resultCount = dictionary["num_results"] as? Int,
            results =  dictionary["results"] as? [Dictionary<String, AnyObject>] else {
            return nil
        }
        
        listCount = resultCount
        
        lists = [BookList]()
        results.forEach { (dict) in
            if let bookList = BookList(dictionary: dict) {
                lists.append(bookList)
            }
        }
        
        lists.sortInPlace { $0.displayName < $1.displayName }
    }
}