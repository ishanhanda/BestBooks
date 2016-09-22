//
//  NYTBCachingManager.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

class NYTBCachingManager: NSObject {
    
    static let sharedInstance = NYTBCachingManager()
    
    let ALL_LISTS = "ALL_LISTS"
    
    static let namespace = "default"
    var diskCachePath: NSURL!
    
    let cacheDirectoryPath: NSURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(namespace)
    
    let fullNamespace = "com.Ishan-Handa.NYT-Best.JSONCache.".stringByAppendingString(namespace)
    
    let maxCacheAge: Double = 60 * 60 * 24 // 1 day
    
    let ioQueue = dispatch_queue_create("com.Ishan-Handa.NYT-Best", DISPATCH_QUEUE_SERIAL)
    
    let fileManager = NSFileManager()
    
    private override init() {
        super.init()
        self.diskCachePath = self.cacheDirectoryPath
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NYTBCachingManager.cleanDisk as (NYTBCachingManager) -> () -> ()), name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NYTBCachingManager.backgroundCleanDisk), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    
    private func cacheJSON(listName: String, completion:(cached: Bool, bookResponseDict: Dictionary<String, AnyObject>?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            if !self.fileManager.fileExistsAtPath((self.diskCachePath?.absoluteString)!) {
                do {
                    try self.fileManager.createDirectoryAtURL(self.diskCachePath!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let cachedURL = self.createCacheURL(listName)
            
            NYTimesAPIWrapper.sharedInstance.getBestSellers(listName) { (apiResponse) in
                if apiResponse.isSuccessful {
                    guard let responseDict = apiResponse.responseObject else {
                        print("Response Parse error. Could not create Dictionary object.")
                        completion(cached: false, bookResponseDict: nil, error: NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response Parse error. Could not create Dictionary object."]))
                        return
                    }
                    
                    NSKeyedArchiver.archiveRootObject(responseDict, toFile: cachedURL.path!)
                    completion(cached: true, bookResponseDict: responseDict, error: nil)
                } else {
                    completion(cached: false, bookResponseDict: nil, error: NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.errorMsg ?? "Failed to fetch data."]))
                }
            }
        }
    }
    
    
    func cachedJSONURL(listName: String?) -> NSURL? {
        let fileURL = self.createCacheURL(listName)
        
        if NSFileManager.defaultManager().fileExistsAtPath((fileURL.path)!) {
            return fileURL
        } else {
            return nil
        }
    }
    
    
    private func createCacheURL(listName: String?) -> NSURL {
        return  self.diskCachePath.URLByAppendingPathComponent((listName?.stringByReplacingOccurrencesOfString("/", withString: "_"))!)
    }
    
    
    func cleanDisk() {
        self.cleanDisk(nil)
    }
    
    
    private func cleanDisk(completion: (Void -> Void)?) {
        let diskCacheURL = self.diskCachePath
        let resourceKeys = [NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey]
        
        let fileEnumerator = self.fileManager.enumeratorAtURL(diskCacheURL!, includingPropertiesForKeys: resourceKeys, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles, errorHandler: nil)
        
        let expirationDate = NSDate(timeIntervalSinceNow: -self.maxCacheAge)
        
        // Enumerate all of the files in the cache directory.
        //
        // Removing files that are older than the expiration date.
        var urlsToDelete: [NSURL] = []
        
        while let fileURL = fileEnumerator?.nextObject() as? NSURL {
            do {
                let resourceValues = try fileURL.resourceValuesForKeys(resourceKeys)
                
                // Skip directories.
                if (resourceValues[NSURLIsDirectoryKey]!.boolValue!) {
                    continue
                }
                
                // Remove files that are older than the expiration date;
                let modificationDate = resourceValues[NSURLContentModificationDateKey] as! NSDate
                if (modificationDate.laterDate(expirationDate).isEqualToDate(expirationDate)) {
                    urlsToDelete.append(fileURL)
                    continue
                }
                
            } catch {
                print(error)
            }
        }
        
        urlsToDelete.forEach { (fileURL) -> () in
            do {
                try self.fileManager.removeItemAtURL(fileURL)
                print("Removed cached file at url \(fileURL)")
            } catch {
                print(error)
            }
        }
        
        if (completion != nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion!()
            })
        }
    }
    
    
    func backgroundCleanDisk() {
        let application = UIApplication.sharedApplication()
        
        var bgTask: UIBackgroundTaskIdentifier? = nil
        
        bgTask = application.beginBackgroundTaskWithExpirationHandler { () -> Void in
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        }
        
        self.cleanDisk { Void -> Void in
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        }
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


extension NYTBCachingManager {
    func bookResponse(listName: String, completion: (bookResposne: BooksResponse?, error: NSError?, isResponseFromCache: Bool) -> ()) {
        if let url = self.cachedJSONURL(listName) {
            let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(url.path!) as! Dictionary<String, AnyObject>
            let bookResponse = BooksResponse(dictionary: dict)
            return completion(bookResposne: bookResponse, error: nil, isResponseFromCache: true)
        } else {
            self.cacheJSON(listName, completion: { (cached, bookRepsonse, error) in
                
                if let dict = bookRepsonse where error == nil {
                    let bookResponse = BooksResponse(dictionary: dict)
                    return completion(bookResposne: bookResponse, error: nil, isResponseFromCache: false)
                } else {
                    completion(bookResposne: nil, error: error, isResponseFromCache: false)
                }
            })
        }
    }
    
    func updateCacheForBook(listName: String, completion: (bookResposne: BooksResponse?, error: NSError?) -> ()) {
        self.cacheJSON(listName, completion: { (cached, bookRepsonse, error) in
            
            if let dict = bookRepsonse where error == nil {
                let bookResponse = BooksResponse(dictionary: dict)
                return completion(bookResposne: bookResponse, error: nil)
            } else {
                completion(bookResposne: nil, error: error)
            }
        })
    }
}



extension NYTBCachingManager {
    private func createAllListsCacheURL() -> NSURL {
        return  self.diskCachePath.URLByAppendingPathComponent(ALL_LISTS)
    }
    
    
    private func cachedListsURL() -> NSURL? {
        let fileURL = self.createAllListsCacheURL()
        
        if NSFileManager.defaultManager().fileExistsAtPath((fileURL.path)!) {
            return fileURL
        } else {
            return nil
        }
    }
    
    func listsResponse(completion: (listsResponse: ListResponse?, error: NSError?, isResponseFromCache: Bool) -> ()) {
        if let url = self.cachedListsURL() {
            let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(url.path!) as! Dictionary<String, AnyObject>
            let listsResponse = ListResponse(dictionary: dict)
            return completion(listsResponse: listsResponse, error: nil, isResponseFromCache: true)
        } else {
            self.cacheAllLists({ (cached, listsResponseDict, error) in
                if let dict = listsResponseDict where error == nil {
                    let listsResponse = ListResponse(dictionary: dict)
                    return completion(listsResponse: listsResponse, error: nil, isResponseFromCache: false)
                } else {
                    completion(listsResponse: nil, error: error, isResponseFromCache: false)
                }
            })
        }
    }
    
    
    func updateCacheForLists(completion: (listsResponse: ListResponse?, error: NSError?) -> ()) {
        self.cacheAllLists { (cached, listsResponseDict, error) in
            if let dict = listsResponseDict where error == nil {
                let listsResponse = ListResponse(dictionary: dict)
                return completion(listsResponse: listsResponse, error: nil)
            } else {
                completion(listsResponse: nil, error: error)
            }
        }
    }
    
    
    private func cacheAllLists(completion:(cached: Bool, listsResponseDict: Dictionary<String, AnyObject>?, error: NSError?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            if !self.fileManager.fileExistsAtPath((self.diskCachePath?.absoluteString)!) {
                do {
                    try self.fileManager.createDirectoryAtURL(self.diskCachePath!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let cachedURL = self.createAllListsCacheURL()
            
            NYTimesAPIWrapper.sharedInstance.getListNames(completionBlock: { (apiResponse) in
                if apiResponse.isSuccessful {
                    guard let responseDict = apiResponse.responseObject else {
                        print("Response Parse error. Could not create Dictionary object.")
                        completion(cached: false, listsResponseDict: nil, error: NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response Parse error. Could not create Dictionary object."]))
                        return
                    }
                    
                    NSKeyedArchiver.archiveRootObject(responseDict, toFile: cachedURL.path!)
                    completion(cached: true, listsResponseDict: responseDict, error: nil)
                } else {
                    completion(cached: false, listsResponseDict: nil, error: NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.errorMsg ?? "Failed to fetch data."]))
                }
            })
        }
    }
}