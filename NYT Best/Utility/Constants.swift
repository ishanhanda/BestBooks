//
//  Constants.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation

let NYTIMES_BOOKS_API_BASE_URL = "https://api.nytimes.com/svc/books/v3"

let NYTIMES_API_KEY_PARAM = "api-key"
let NYTIMES_LIST_PARAM = "list"

let NYTIMES_LOGO_LINK = "https://developer.nytimes.com"

// MARK: - End points
enum NYTimesApiEndPoints: String {
    case NamesList = "/lists/names.json"
    case BestSellers = "/lists.json"
}


// MARK: - User Defaults keys
enum BooksOrder: String {
    case Rank = "BooksOrderRank"
    case Week = "BooksOrderWeek"
}

let K_UD_BOOKS_ORDER = "K_UD_BOOKS_ORDER"