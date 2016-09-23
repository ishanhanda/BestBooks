//
//  BooksResponse.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

/// Model to store Books response fetched from api
struct BooksResponse {
    var bookCount: Int
    var books: [Book]
}


extension BooksResponse: DictionaryInitializable {
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let
            resultCount = dictionary["num_results"] as? Int,
            results =  dictionary["results"] as? [Dictionary<String, AnyObject>] else {
                return nil
        }
        
        bookCount = resultCount
        
        books = [Book]()
        results.forEach { (dict) in
            if let bookList = Book(dictionary: dict) {
                books.append(bookList)
            }
        }
    }
}