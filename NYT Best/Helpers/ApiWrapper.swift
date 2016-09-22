//
//  ApiWrapper.swift
//  NYT Best
//
//  Created by Ishan Handa on 20/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import Foundation
import Alamofire

class NYTimesAPIWrapper  {
    static let sharedInstance = NYTimesAPIWrapper()

    /// Base URL for the New York Times Books api.
    private let baseURL = NYTIMES_BOOKS_API_BASE_URL

    typealias CompletionBlock = AlamofireAPIResponse -> Void
    
    private init() {
        Alamofire.Manager.sharedInstance.startRequestsImmediately = false
    }

    
    /**
     This method is used to generate a Response closure to parse the response from api calls
     - parameter methodResponseBlock: Closure used to call the request.
     - returns: returns a common response block created by using the methodResponseBlock.
     */
    private func commonResponseBlock(methodResponseBlock: CompletionBlock) -> (response: Response<AnyObject, NSError>) -> Void {
        return { (response: Response<AnyObject, NSError>) -> Void in
            print(response.request)
            print(response.response)
            
            if let error = response.result.error {
                print(error.localizedDescription)
                let apiResponse = AlamofireAPIResponse.init(response: nil, errorCode: error.code, errorMessage: error.localizedDescription, successful: false)
                methodResponseBlock(apiResponse)
            } else if let jsonValue = response.result.value {
                print(jsonValue)
                let apiResponse = AlamofireAPIResponse.init(response: jsonValue as? Dictionary<String, AnyObject>, errorCode: 0, errorMessage: "", successful: true)
                methodResponseBlock(apiResponse)
            }
        }
    }
    
    
    /// Sets up and starts the request.
    private func finishRequest(request: Request, responseBlock: CompletionBlock) {
        let req = request.request!.mutableCopy() as! NSMutableURLRequest
        req.HTTPShouldHandleCookies = false
        
        let finalRequest = Alamofire.request(req)
        finalRequest.responseJSON(completionHandler: self.commonResponseBlock(responseBlock))
        finalRequest.resume()
    }
}


// MARK: - API Interaction Methods

extension NYTimesAPIWrapper {
    
    /// Get list names New York Times api.
    func getListNames(completionBlock responseBlock: CompletionBlock) {
        let urlString = NYTimesApiEndPoints.NamesList.rawValue
        print("Starting List Names request with URL String: \(urlString)")
        
        let params = [NYTIMES_API_KEY_PARAM: NYTIMES_API_KEY]
        print("Parameters: \(params)")
        
        let request = Alamofire.request(.GET, self.baseURL + urlString, parameters: params, encoding: .URL)
        self.finishRequest(request, responseBlock: responseBlock)
    }
    
    
    /// Get list names New York Times api.
    func getBestSellers(listName: String, completionBlock responseBlock: CompletionBlock) {
        let urlString = NYTimesApiEndPoints.BestSellers.rawValue
        print("Starting Best Seller request with URL String: \(urlString)")
        
        let params = [
            NYTIMES_API_KEY_PARAM: NYTIMES_API_KEY,
            NYTIMES_LIST_PARAM: listName
        ]
        print("Parameters: \(params)")
        
        let request = Alamofire.request(.GET, self.baseURL + urlString, parameters: params, encoding: .URL)
        self.finishRequest(request, responseBlock: responseBlock)
    }
}