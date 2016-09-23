//
//  MainListsTableViewController.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SafariServices

class MainListsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var listsDataSource = [BookListObject]()
    
    @IBOutlet var footerVEF: UIVisualEffectView!
    @IBOutlet var searchBarContainerView: UIView!
    
    @IBOutlet var tableView: UITableView!
    
    var showingAcitvityIndicator = false
    
    var searchController: UISearchController!
    var searchBar: UISearchBar!
    var sectionHeaders: [String]!
    var tableSections: [[BookListObject]]!
    var searchResults: [BookListObject]!
    var isSearching = false
    
    var keyBoardHeight: CGFloat = 0
    
    var askRefresh = false
    
    var refreshControl: UIRefreshControl!
    
    var currentTableInsets: UIEdgeInsets {
        let top = !showingAcitvityIndicator ? topLayoutGuide.length + searchBarContainerView.bounds.height : topLayoutGuide.length + searchBarContainerView.bounds.height + self.heightForNotificationView()
        return UIEdgeInsets(top: top, left: 0, bottom: max(footerVEF.bounds.height, keyBoardHeight), right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Categories"
        
        self.setUpSearchController()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.sectionIndexColor = UIColor.flatPlumColor()
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refreshControlChanged(_:)), forControlEvents: .ValueChanged)
        
        self.refresh()
    }
    
    
    func refreshControlChanged(refreshControl: UIRefreshControl) {
        
        NYTBCachingManager.sharedInstance.listsResponse { (listsResponse, error, isResponseFromCache) in
            if let response = listsResponse where error == nil {
                self.listsDataSource = response.lists.map({ (bookList) -> BookListObject in
                    let object = BookListObject()
                    object.bookList = bookList
                    object.displayName = bookList.displayName
                    return object
                })
                
                self.askRefresh = false
                self.setobjectsInSections(self.listsDataSource)
            } else if let _ = error {
                self.askRefresh = true
            }
            
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    
    func refresh() {
        let indicator = self.showActivityIndicatorView("Loading...", animations: {
            self.showingAcitvityIndicator = true
            }, completion: nil)
        
        let hideActivity = {
            self.hideNotificationView(indicator, animations: {
                self.showingAcitvityIndicator = false
                }, completion: nil)
        }
        
        NYTBCachingManager.sharedInstance.listsResponse { (listsResponse, error, isResponseFromCache) in
            if let response = listsResponse where error == nil {
                self.listsDataSource = response.lists.map({ (bookList) -> BookListObject in
                    let object = BookListObject()
                    object.bookList = bookList
                    object.displayName = bookList.displayName
                    self.askRefresh = true
                    self.tableView.reloadData()
                    return object
                })
                
                self.askRefresh = false
                self.setobjectsInSections(self.listsDataSource)
                self.tableView.reloadData()
                
                if isResponseFromCache {
                    indicator.messageLabel.text = "Updating..."
                    
                    NYTBCachingManager.sharedInstance.updateCacheForLists({ (listsResponse, error) in
                        if let response = listsResponse where error == nil {
                            self.listsDataSource = response.lists.map({ (bookList) -> BookListObject in
                                let object = BookListObject()
                                object.bookList = bookList
                                object.displayName = bookList.displayName
                                return object
                            })
                            
                            self.setobjectsInSections(self.listsDataSource)
                            self.tableView.reloadData()
                        } else {
                            self.showNotificationView("\(error!.localizedDescription)\nDisplaying cached data.", time: 3, animations: nil, completion: nil)
                            print(error)
                        }
                        
                        hideActivity()
                    })
                } else {
                    hideActivity()
                }
                
            } else if let _ = error {
                self.askRefresh = true
                self.tableView.reloadData()
                hideActivity()
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = currentTableInsets
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: true)
        }
        
        tableView.sendSubviewToBack(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else if let sections = self.tableSections {
            return sections.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.searchResults.count
        } else {
            return self.tableSections[section].count
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idMainListsCell", forIndexPath: indexPath) as! MainListsTableViewCell

        let list: BookListObject!
        
        if isSearching {
            list = self.searchResults[indexPath.row]
        } else {
            list = self.tableSections[indexPath.section][indexPath.row]
        }
        
        cell.textLabel?.text = list.bookList.displayName.uppercaseString

        return cell
    }
 
    // MARK: -
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let list: BookListObject!
        
        if isSearching {
            list = self.searchResults[indexPath.row]
        } else {
            list = self.tableSections[indexPath.section][indexPath.row]
        }
        
        let bestSellerBooksTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idBestSellerBooksTableViewController") as! BestSellerBooksTableViewController
        bestSellerBooksTableViewController.bookList = list.bookList
        
        self.navigationController?.pushViewController(bestSellerBooksTableViewController, animated: true)
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (isSearching) {
            return nil
        } else {
            return self.sectionHeaders[section]
        }
    }
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.flatPurpleColorDark()
        let label = (view as! UITableViewHeaderFooterView).textLabel
        label?.textColor = UIColor.flatWhiteColor()
        label?.font = UIFont(name: BBFonts.JosefinSlab_Bold.rawValue, size: 16)
    }
    
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if (isSearching) {
            return nil
        } else {
            return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching {
            return 0
        } else {
            return 20
        }
    }
    
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        var returnVal = index
        
        if returnVal >= self.sectionHeaders.count {
            returnVal = self.sectionHeaders.count - 1
        }
        
        while returnVal >= 0 {
            if self.sectionHeaders[returnVal] == title {break}
            returnVal -= 1
        }
        
        return returnVal
    }
}


extension MainListsTableViewController: ISHShowsTopActivityIndicator {
    func viewOnTopOfNotificationView() -> UIView {
        return self.searchBarContainerView
    }
    
    func superViewOfNotificationView() -> UIView {
        return self.view
    }
    
    
    func heightForNotificationView() -> CGFloat {
        return 44
    }
}


extension MainListsTableViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    private func setUpSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.definesPresentationContext = true
        
        self.searchBar = self.searchController.searchBar
        self.searchBar.searchBarStyle = .Minimal

        self.searchBar.frame = self.searchBarContainerView.bounds
        searchBar.autoresizingMask = .FlexibleWidth
        self.searchBarContainerView.addSubview(self.searchBar)
        self.searchBar.sizeToFit()
        self.searchBar.tintColor = UIColor.purpleColor()
    }
    
    
    func setobjectsInSections(objects: [BookListObject]) {
        let selector = #selector(BookListObject.sortingFunction)
        let sectionTitlesCount = UILocalizedIndexedCollation.currentCollation().sectionTitles.count
        
        var mutableSections: [[BookListObject]] = []
        for _ in 0...sectionTitlesCount {
            mutableSections.append([BookListObject]())
        }
        
        for object in objects {
            UILocalizedIndexedCollation.currentCollation()
            let sectionNumber = UILocalizedIndexedCollation.currentCollation().sectionForObject(object, collationStringSelector: selector)
            mutableSections[sectionNumber].append(object)
        }
        
        for idx in 0...sectionTitlesCount {
            let objectsForSection = mutableSections[idx] as [BookListObject]
            let sortedObjs = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(objectsForSection, collationStringSelector: selector) as! [BookListObject]
            mutableSections.replaceRange(idx...idx, with: [sortedObjs])
        }
        
        //Adding to Data Source if count is greater than zero
        let localizedHeaders = UILocalizedIndexedCollation.currentCollation().sectionTitles
        var validHeaders: [String] = []
        var validSections: [[BookListObject]] = []
        
        for idx in 0...sectionTitlesCount {
            let objectsForSection = mutableSections[idx]
            if objectsForSection.count > 0 {
                validHeaders.append(localizedHeaders[idx])
                validSections.append(objectsForSection)
            }
        }
        
        self.sectionHeaders = validHeaders
        self.tableSections = validSections
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - UISearchControllerDelegate Protocol Functions
    
    func didPresentSearchController(searchController: UISearchController) {
        self.isSearching = true
        self.tableView.reloadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        self.isSearching = false
        self.tableView.reloadData()
    }
    
    // MARK: - ISearchResultsUpdating Protocol Functions
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        var searchResults = self.listsDataSource
        
        // strip out all the leading and trailing spaces
        let strippedString = searchText?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        // break up the search terms (separated by spaces)
        var searchItems: [String]? = nil
        
        if strippedString?.characters.count > 0 {
            searchItems = strippedString?.componentsSeparatedByString(" ")
        }
        
        var andMatchPredicates: [NSPredicate] = []
        
        searchItems?.forEach({ (searchString) -> () in
            var searchItemsPredicate: [NSPredicate] = []
            
            let lhs = NSExpression(forKeyPath: "displayName")
            let rhs = NSExpression(forConstantValue: searchString)
            let finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type: .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
            
            searchItemsPredicate.append(finalPredicate)
            
            let orMatchPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        })
        
        // match up the fields of the Product object
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        searchResults = searchResults.filter {finalCompoundPredicate.evaluateWithObject($0)}
        
        self.searchResults = searchResults
        self.tableView.reloadData()
    }
}


// MARK: - Keyboard Notification Functions
extension MainListsTableViewController {
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            keyBoardHeight = keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        keyBoardHeight = 0
    }
}


extension MainListsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_small")
    }
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "BestBooks", attributes: [
            NSForegroundColorAttributeName : UIColor.flatPlumColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(20)
            ])
    }
    
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = askRefresh ? "An error occured. Pull to refresh." : ""
        
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName : UIColor.flatPurpleColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(14)
            ])
    }
    
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return  -50
    }
    
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return !refreshControl.refreshing
    }
    
    
    @IBAction func nytButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }
}