//
//  NYTBCachingManager.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

/// Class to manage caching of api responses.
class NYTBCachingManager: NSObject {
    
    static let sharedInstance = NYTBCachingManager()
    
    let ALL_LISTS = "ALL_LISTS"
    
    static let namespace = "default"
    var diskCachePath: URL!
    
    let cacheDirectoryPath: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(namespace)
    
    let fullNamespace = "com.Ishan-Handa.NYT-Best.JSONCache." + namespace
    
    let maxCacheAge: Double = 60 * 60 * 24 // 1 day
    
    let ioQueue = DispatchQueue(label: "com.Ishan-Handa.NYT-Best", attributes: [])
    
    let fileManager = FileManager()
    
    fileprivate override init() {
        super.init()
        self.diskCachePath = self.cacheDirectoryPath
        
        NotificationCenter.default.addObserver(self, selector: #selector(NYTBCachingManager.cleanDisk as (NYTBCachingManager) -> () -> ()), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NYTBCachingManager.backgroundCleanDisk), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    
    fileprivate func cacheJSON(_ listName: String, completion:@escaping (_ cached: Bool, _ bookResponseDict: Dictionary<String, AnyObject>?, _ error: NSError?) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async { () -> Void in
            if !self.fileManager.fileExists(atPath: (self.diskCachePath?.absoluteString)!) {
                do {
                    try self.fileManager.createDirectory(at: self.diskCachePath!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let cachedURL = self.createCacheURL(listName)
            
            NYTimesAPIWrapper.sharedInstance.getBestSellers(listName) { (apiResponse) in
                if apiResponse.isSuccessful {
                    guard let responseDict = apiResponse.responseObject else {
                        print("Response Parse error. Could not create Dictionary object.")
                        completion(false, nil, NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response Parse error. Could not create Dictionary object."]))
                        return
                    }
                    
                    NSKeyedArchiver.archiveRootObject(responseDict, toFile: cachedURL.path)
                    completion(true, responseDict, nil)
                } else {
                    completion(false, nil, NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.errorMsg ?? "Failed to fetch data."]))
                }
            }
        }
    }
    
    
    fileprivate func cachedJSONURL(_ listName: String?) -> URL? {
        let fileURL = self.createCacheURL(listName)
        
        if FileManager.default.fileExists(atPath: (fileURL.path)) {
            return fileURL
        } else {
            return nil
        }
    }
    
    
    fileprivate func createCacheURL(_ listName: String?) -> URL {
        return  self.diskCachePath.appendingPathComponent((listName?.replacingOccurrences(of: "/", with: "_"))!)
    }
    
    
    func cleanDisk() {
        self.cleanDisk(nil)
    }
    
    
    fileprivate func cleanDisk(_ completion: ((Void) -> Void)?) {
        let diskCacheURL = self.diskCachePath
        let resourceKeys = [URLResourceKey.isDirectoryKey, URLResourceKey.contentModificationDateKey, URLResourceKey.totalFileAllocatedSizeKey]
        
        let fileEnumerator = self.fileManager.enumerator(at: diskCacheURL!, includingPropertiesForKeys: resourceKeys, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles, errorHandler: nil)
        
        let expirationDate = Date(timeIntervalSinceNow: -self.maxCacheAge)
        
        // Enumerate all of the files in the cache directory.
        // Removing files that are older than the expiration date.
        var urlsToDelete: [URL] = []
        
        while let fileURL = fileEnumerator?.nextObject() as? URL {
            do {
                let resourceValues = try (fileURL as NSURL).resourceValues(forKeys: resourceKeys)
                
                // Skip directories.
                if ((resourceValues[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue!) {
                    continue
                }
                
                // Remove files that are older than the expiration date;
                let modificationDate = resourceValues[URLResourceKey.contentModificationDateKey] as! Date
                if ((modificationDate as NSDate).laterDate(expirationDate) == expirationDate) {
                    urlsToDelete.append(fileURL)
                    continue
                }
                
            } catch {
                print(error)
            }
        }
        
        urlsToDelete.forEach { (fileURL) -> () in
            do {
                try self.fileManager.removeItem(at: fileURL)
                print("Removed cached file at url \(fileURL)")
            } catch {
                print(error)
            }
        }
        
        if (completion != nil) {
            DispatchQueue.main.async(execute: { () -> Void in
                completion!()
            })
        }
    }
    
    
    func backgroundCleanDisk() {
        let application = UIApplication.shared
        
        var bgTask: UIBackgroundTaskIdentifier? = nil
        
        bgTask = application.beginBackgroundTask (expirationHandler: { () -> Void in
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        })
        
        self.cleanDisk { Void -> Void in
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// MARK: - Public methods Book Response
extension NYTBCachingManager {
    func bookResponse(_ listName: String, completion: @escaping (_ bookResposne: BooksResponse?, _ error: NSError?, _ isResponseFromCache: Bool) -> ()) {
        if let url = self.cachedJSONURL(listName) {
            let dict = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as! Dictionary<String, AnyObject>
            let bookResponse = BooksResponse(dictionary: dict)
            return completion(bookResponse, nil, true)
        } else {
            self.cacheJSON(listName, completion: { (cached, bookRepsonse, error) in
                
                if let dict = bookRepsonse, error == nil {
                    let bookResponse = BooksResponse(dictionary: dict)
                    return completion(bookResponse, nil, false)
                } else {
                    completion(nil, error, false)
                }
            })
        }
    }
    
    func updateCacheForBook(_ listName: String, completion: @escaping (_ bookResposne: BooksResponse?, _ error: NSError?) -> ()) {
        self.cacheJSON(listName, completion: { (cached, bookRepsonse, error) in
            
            if let dict = bookRepsonse, error == nil {
                let bookResponse = BooksResponse(dictionary: dict)
                return completion(bookResponse, nil)
            } else {
                completion(nil, error)
            }
        })
    }
}


// MARK: - Lists Response caching and public methods
extension NYTBCachingManager {
    fileprivate func createAllListsCacheURL() -> URL {
        return  self.diskCachePath.appendingPathComponent(ALL_LISTS)
    }
    
    
    fileprivate func cachedListsURL() -> URL? {
        let fileURL = self.createAllListsCacheURL()
        
        if FileManager.default.fileExists(atPath: (fileURL.path)) {
            return fileURL
        } else {
            return nil
        }
    }
    
    func listsResponse(_ completion: @escaping (_ listsResponse: ListResponse?, _ error: NSError?, _ isResponseFromCache: Bool) -> ()) {
        if let url = self.cachedListsURL() {
            let dict = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as! Dictionary<String, AnyObject>
            let listsResponse = ListResponse(dictionary: dict)
            return completion(listsResponse, nil, true)
        } else {
            self.cacheAllLists({ (cached, listsResponseDict, error) in
                if let dict = listsResponseDict, error == nil {
                    let listsResponse = ListResponse(dictionary: dict)
                    return completion(listsResponse, nil, false)
                } else {
                    completion(nil, error, false)
                }
            })
        }
    }
    
    
    func updateCacheForLists(_ completion: @escaping (_ listsResponse: ListResponse?, _ error: NSError?) -> ()) {
        self.cacheAllLists { (cached, listsResponseDict, error) in
            if let dict = listsResponseDict, error == nil {
                let listsResponse = ListResponse(dictionary: dict)
                return completion(listsResponse, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    fileprivate func cacheAllLists(_ completion:@escaping (_ cached: Bool, _ listsResponseDict: Dictionary<String, AnyObject>?, _ error: NSError?) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async { () -> Void in
            if !self.fileManager.fileExists(atPath: (self.diskCachePath?.absoluteString)!) {
                do {
                    try self.fileManager.createDirectory(at: self.diskCachePath!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error)
                }
            }
            
            let cachedURL = self.createAllListsCacheURL()
            
            NYTimesAPIWrapper.sharedInstance.getListNames(completionBlock: { (apiResponse) in
                if apiResponse.isSuccessful {
                    guard let responseDict = apiResponse.responseObject else {
                        print("Response Parse error. Could not create Dictionary object.")
                        completion(false, nil, NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response Parse error. Could not create Dictionary object."]))
                        return
                    }
                    
                    NSKeyedArchiver.archiveRootObject(responseDict, toFile: cachedURL.path)
                    completion(true, responseDict, nil)
                } else {
                    completion(false, nil, NSError(domain: "ChacheError", code: -1, userInfo: [NSLocalizedDescriptionKey: apiResponse.errorMsg ?? "Failed to fetch data."]))
                }
            })
        }
    }
}
