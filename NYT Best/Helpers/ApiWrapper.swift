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
    
    var NYTIMES_API_KEY: String? {
        guard let info = Bundle.main.infoDictionary else {
            return nil
        }
        
        return info["nytimes_api_key"] as? String
    }
    
    /// Base URL for the New York Times Books api.
    fileprivate let baseURL = NYTIMES_BOOKS_API_BASE_URL

    typealias CompletionBlock = (AlamofireAPIResponse) -> Void
    
    fileprivate init() {
        Alamofire.SessionManager.default.startRequestsImmediately = false
    }

    
    /**
     This method is used to generate a Response closure to parse the response from api calls
     - parameter methodResponseBlock: Closure used to call the request.
     - returns: returns a common response block created by using the methodResponseBlock.
     */
    fileprivate func commonResponseBlock(_ methodResponseBlock: @escaping CompletionBlock) -> (_ response: DataResponse<Any>) -> Void {
        return { (response) -> Void in
            print(response.request.debugDescription)
            print(response.response.debugDescription)
            
            if let error = response.result.error {
                print(error.localizedDescription)
                let apiResponse = AlamofireAPIResponse.init(response: nil, errorCode: error._code, errorMessage: error.localizedDescription, successful: false)
                methodResponseBlock(apiResponse)
            } else if let jsonValue = response.result.value {
                print(jsonValue)
                let apiResponse = AlamofireAPIResponse.init(response: jsonValue as? Dictionary<String, AnyObject>, errorCode: 0, errorMessage: "", successful: true)
                methodResponseBlock(apiResponse)
            }
        }
    }
    
    
    /// Sets up and starts the request.
    fileprivate func finishRequest(_ request: Request, responseBlock: @escaping CompletionBlock) {
        let req = (request.request! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        req.httpShouldHandleCookies = false
        
        let finalRequest = Alamofire.request(req as URLRequest)
        finalRequest.responseJSON(completionHandler: self.commonResponseBlock(responseBlock))
        finalRequest.resume()
    }
}


// MARK: - API Interaction Methods

extension NYTimesAPIWrapper {
    
    /// Get list names New York Times api.
    func getListNames(completionBlock responseBlock: @escaping CompletionBlock) {
        let urlString = NYTimesApiEndPoints.NamesList.rawValue
        print("Starting List Names request with URL String: \(urlString)")
        
        let params = [NYTIMES_API_KEY_PARAM: NYTIMES_API_KEY ?? ""]
        print("Parameters: \(params)")
        
        let request = Alamofire.request(self.baseURL + urlString, method: .get, parameters: params, encoding: URLEncoding.default)
        self.finishRequest(request, responseBlock: responseBlock)
    }
    
    
    /// Get list names New York Times api.
    func getBestSellers(_ listName: String, completionBlock responseBlock: @escaping CompletionBlock) {
        let urlString = NYTimesApiEndPoints.BestSellers.rawValue
        print("Starting Best Seller request with URL String: \(urlString)")
        
        let params = [
            NYTIMES_API_KEY_PARAM: NYTIMES_API_KEY ?? "",
            NYTIMES_LIST_PARAM: listName
        ]
        print("Parameters: \(params)")
        
        let request = Alamofire.request(self.baseURL + urlString, method: .get, parameters: params, encoding: URLEncoding.default)
        self.finishRequest(request, responseBlock: responseBlock)
    }
}
