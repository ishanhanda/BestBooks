//
//  Book.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

/// Model to store Books fetched from api
struct Book {
    var amazonProductURLString: String?
    var bestsellersDate: Date
    var title: String
    var description: String
    var contributor: String?
    var author: String?
    var publisher: String?
    var primaryISBN13: String?
    var primaryISBN10: String?
    var publishedDate: Date
    var rank: Int
    var rankLastWeek: Int
    var bookReviewURLString: String?
    var sundayReviewURLSring: String?
    var weeksOnList: Int
    
    var otherIsbn13: [String]?
    
    /// Computed NSURL to guess the image url for the book from the ISBN number returned from api.
    var imageURL: URL? {
        if let isbn13 = self.primaryISBN13 {
            if let url = URL(string: "https://s1.nyt.com/du/books/images/\(isbn13).jpg") {
                return url
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    /// Computed NSURLs to guess the image url for the book from other ISBN numbers returned from api.
    var otherImageURLs: [URL]? {
        if let otherISBNS = self.otherIsbn13, otherISBNS.count > 0 {
            var urls = [URL]()
            otherISBNS.forEach({ (isbn) in
                if let url = URL(string: "https://s1.nyt.com/du/books/images/\(isbn).jpg") {
                    urls.append(url)
                }
            })
            
            return urls.count > 0 ? urls : nil
        } else {
            return nil
        }
    }
}


extension Book: DictionaryInitializable {
    
    init?(dictionary: Dictionary<String, AnyObject>) {
        guard let
            bestsellersDate = dictionary["bestsellers_date"] as? String,
            let bookDetails = dictionary["book_details"] as? [Dictionary<String, AnyObject>],
            let publishedDate = dictionary["published_date"] as? String,
            let rank = dictionary["rank"] as? Int,
            let rankLastWeek = dictionary["rank_last_week"] as? Int,
            let weeksOnList = dictionary["weeks_on_list"] as? Int else {
                return nil
        }
        
        guard let detail = bookDetails.first else { return nil }
        
        guard let
            title = detail["title"] as? String,
            let description = detail["description"] as? String else {
                return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-mm-dd"
        
        self.bestsellersDate = dateFormatter.date(from: bestsellersDate)!
        self.title = title.capitalized
        self.description = description
        self.author = detail["author"] as? String
        self.publishedDate = dateFormatter.date(from: publishedDate)!
        self.rank = rank
        self.rankLastWeek = rankLastWeek
        self.weeksOnList = weeksOnList
        
        if let otherISBNS = dictionary["isbns"] as? [[String: String]] {
            var isbns = [String]()
            
            otherISBNS.forEach({ (aDict) in
                if let isbn13 = aDict["isbn13"] {
                    isbns.append(isbn13)
                }
            })
            
            self.otherIsbn13 = isbns
        }
        
        self.amazonProductURLString = dictionary["amazon_product_url"] as? String
        self.contributor = detail["contributor"] as? String
        self.publisher = detail["publisher"] as? String
        self.primaryISBN13 = detail["primary_isbn13"] as? String
        self.primaryISBN10 = detail["primary_isbn10"] as? String
        self.author = detail["author"] as? String
        if self.author == "" {
            self.author = nil
        }
        
        if let reviewsArray = dictionary["reviews"] as? [Dictionary<String, String>] {
            if let first = reviewsArray.first {
                self.bookReviewURLString = first["book_review_link"]
                self.sundayReviewURLSring = first["sunday_review_link"]
            }
        }
    }
}
