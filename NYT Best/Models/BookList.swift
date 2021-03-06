//
//  BookList.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

/// Model to store Book lists fetched from api
struct BookList {
    var displayName: String
    var listName: String
    var listNameEchoed: String
    var newestPublishedDate: Date
    var oldestPublishedDate: Date
    var updated: String
}


extension BookList: DictionaryInitializable {
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let
            displayName = dictionary["display_name"] as? String,
            let listName = dictionary["list_name"]as? String,
            let listNameEchoed = dictionary["list_name_encoded"] as? String,
            let newestPublishedDate = dictionary["newest_published_date"] as? String,
            let oldestPublishedDate = dictionary["oldest_published_date"] as? String,
            let updated = dictionary["updated"] as? String else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd"
        
        self.displayName = displayName
        self.listName = listName
        self.listNameEchoed = listNameEchoed
        self.newestPublishedDate = dateFormatter.date(from: newestPublishedDate)!
        self.oldestPublishedDate = dateFormatter.date(from: oldestPublishedDate)!
        self.updated = updated
    }
}


/// Wrapper around the BookList struct to help with section indexing.
class BookListObject: NSObject {
    var bookList: BookList!
    var displayName: String!
    
    
    /**
     This function is used to sort the Book lists by the valie returned here.
     - returns: Key to sort the lists with (Currently the displayName).
     */
    @objc func sortingFunction() -> String {
        return self.bookList.displayName
    }
}
