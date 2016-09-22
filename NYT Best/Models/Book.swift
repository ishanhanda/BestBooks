//
//  Book.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

struct Book {
    var amazonProductURLString: String?
    var bestsellersDate: NSDate
    var title: String
    var description: String
    var contributor: String?
    var author: String?
    var publisher: String?
    var primaryISBN13: String?
    var primaryISBN10: String?
    var publishedDate: NSDate
    var rank: Int
    var rankLastWeek: Int
    var bookReviewURLString: String?
    var sundayReviewURLSrring: String?
    var weeksOnList: Int
    
    var imageURLString: NSURL? {
        if let isbn13 = self.primaryISBN13 {
            if let url = NSURL(string: "https://s1.nyt.com/du/books/images/\(isbn13).jpg") {
                return url
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}


extension Book: DictionaryInitializable {
    
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let
            bestsellersDate = dictionary["bestsellers_date"] as? String,
            bookDetails = dictionary["book_details"] as? [Dictionary<String, AnyObject>],
            publishedDate = dictionary["published_date"] as? String,
            rank = dictionary["rank"] as? Int,
            rankLastWeek = dictionary["rank_last_week"] as? Int,
            weeksOnList = dictionary["weeks_on_list"] as? Int else {
                return nil
        }
        
        guard let detail = bookDetails.first else { return nil }
        
        guard let
            title = detail["title"] as? String,
            description = detail["description"] as? String else {
                return nil
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd"
        
        self.bestsellersDate = dateFormatter.dateFromString(bestsellersDate)!
        self.title = title.capitalizedString
        self.description = description
        self.author = detail["author"] as? String
        self.publishedDate = dateFormatter.dateFromString(publishedDate)!
        self.rank = rank
        self.rankLastWeek = rankLastWeek
        self.weeksOnList = weeksOnList
        
        self.amazonProductURLString = dictionary["amazon_product_url"] as? String
        self.contributor = detail["contributor"] as? String
        self.publisher = detail["publisher"] as? String
        self.primaryISBN13 = detail["primary_isbn13"] as? String
        self.primaryISBN10 = detail["primary_isbn10"] as? String
        self.author = detail["author"] as? String
        if self.author == "" {
            self.author = nil
        }
        
        if let reviews = dictionary["reviews"] as? Dictionary<String, String> {
            self.bookReviewURLString = reviews["book_review_link"]
            self.sundayReviewURLSrring = reviews["sunday_review_link"]
        }
    }
}