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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MainListsTableViewController: UIViewController {

    var listsDataSource = [BookListObject]()

    @IBOutlet var footerVEF: UIVisualEffectView!
    @IBOutlet var searchBarContainerView: UIView!
    @IBOutlet var tableView: UITableView!
    
    /// Falg to check if activity indicator is being displayed on view controller
    var showingAcitvityIndicator = false
    
    var searchController: UISearchController!
    var searchBar: UISearchBar!
    
    /// Section headers generated for Indexed sections
    var sectionHeaders: [String]!
    
    /// Books to displayed in each section.
    var tableSections: [[BookListObject]]!
    
    ///Search results.
    var searchResults: [BookListObject]!

    /// Flag to check if Search is active.
    var isSearching = false
    
    /// keyboard height used to adjust table view content insets
    var keyBoardHeight: CGFloat = 0
    
    /// Flag to check if the empty tableview should display message asking for pull to refresh
    var askRefresh = false
    
    var refreshControl: UIRefreshControl!
    
    /// The current computed content insets for the tableview
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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.sectionIndexColor = UIColor.flatPlum
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refreshControlChanged(_:)), for: .valueChanged)
        
        self.refresh()
    }
    
    
    // Fetch lists from api and update table view.
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
            if let response = listsResponse, error == nil {
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
                
                // If response was loaded from cache. Make request to update cache.
                if isResponseFromCache {
                    indicator.messageLabel.text = "Updating..."
                    
                    NYTBCachingManager.sharedInstance.updateCacheForLists( { [unowned self] (listsResponse, error) in
                        if let response = listsResponse, error == nil {
                            self.listsDataSource = response.lists.map({ (bookList) -> BookListObject in
                                let object = BookListObject()
                                object.bookList = bookList
                                object.displayName = bookList.displayName
                                return object
                            })
                            
                            self.setobjectsInSections(self.listsDataSource)
                            self.tableView.reloadData()
                        } else {
                            _ = self.showNotificationView("\(error!.localizedDescription)\nDisplaying cached data.", style: .alert, time: 3, animations: nil, completion: nil)
                            print(error?.localizedDescription as Any)
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
        
        tableView.sendSubview(toBack: refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Action Methods
    
    @IBAction func nytButtonTapped(_ sender: AnyObject) {
        if let url = URL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    func refreshControlChanged(_ refreshControl: UIRefreshControl) {
        
        var updating = true
        if self.listsDataSource.count == 0 { updating = false }
        
        NYTBCachingManager.sharedInstance.updateCacheForLists { [unowned self] (listsResponse, error) in
            if let response = listsResponse, error == nil {
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
            
            if error != nil {
                _ = self.showNotificationView(error?.localizedDescription, style: .alert, time: 3, animations: nil, completion: nil)
            } else if updating {
                _ = self.showNotificationView("List updated", style: .normal, time: 3, animations: nil, completion: nil)
            }
            
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
}


// MARK: - ISHShowsTopActivityIndicator protocol Methods
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


// MARK: - Search handling
extension MainListsTableViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    fileprivate func setUpSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.definesPresentationContext = true
        
        self.searchBar = self.searchController.searchBar
        self.searchBar.searchBarStyle = .minimal

        self.searchBar.frame = self.searchBarContainerView.bounds
        searchBar.autoresizingMask = .flexibleWidth
        self.searchBarContainerView.addSubview(self.searchBar)
        self.searchBar.sizeToFit()
        self.searchBar.tintColor = UIColor.purple
    }
    
    
    /// Set Book lists in sections for indexed display.
    fileprivate func setobjectsInSections(_ objects: [BookListObject]) {
        let selector = #selector(BookListObject.sortingFunction)
        let sectionTitlesCount = UILocalizedIndexedCollation.current().sectionTitles.count
        
        var mutableSections: [[BookListObject]] = []
        for _ in 0...sectionTitlesCount {
            mutableSections.append([BookListObject]())
        }
        
        for object in objects {
            UILocalizedIndexedCollation.current()
            let sectionNumber = UILocalizedIndexedCollation.current().section(for: object, collationStringSelector: selector)
            mutableSections[sectionNumber].append(object)
        }
        
        for idx in 0...sectionTitlesCount {
            let objectsForSection = mutableSections[idx] as [BookListObject]
            let sortedObjs = UILocalizedIndexedCollation.current().sortedArray(from: objectsForSection, collationStringSelector: selector) as! [BookListObject]
            mutableSections.replaceSubrange(idx...idx, with: [sortedObjs])
        }
        
        //Adding to Data Source if count is greater than zero
        let localizedHeaders = UILocalizedIndexedCollation.current().sectionTitles
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
        
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - UISearchControllerDelegate Protocol Functions
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.isSearching = true
        self.tableView.reloadData()
    }
    
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.isSearching = false
        self.tableView.reloadData()
    }
    
    // MARK: - ISearchResultsUpdating Protocol Functions
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        var searchResults = self.listsDataSource
        
        // strip out all the leading and trailing spaces
        let strippedString = searchText?.trimmingCharacters(in: CharacterSet.whitespaces)
        // break up the search terms (separated by spaces)
        var searchItems: [String]? = nil
        
        if strippedString?.characters.count > 0 {
            searchItems = strippedString?.components(separatedBy: " ")
        }
        
        var andMatchPredicates: [NSPredicate] = []
        
        searchItems?.forEach({ (searchString) -> () in
            var searchItemsPredicate: [NSPredicate] = []
            
            let lhs = NSExpression(forKeyPath: "displayName")   /// searching with book display name
            let rhs = NSExpression(forConstantValue: searchString)
            let finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .contains, options: .caseInsensitive)
            
            searchItemsPredicate.append(finalPredicate)
            
            let orMatchPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            andMatchPredicates.append(orMatchPredicates)
        })
        
        // match up the Book
        let finalCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        searchResults = searchResults.filter {finalCompoundPredicate.evaluate(with: $0)}
        
        self.searchResults = searchResults
        self.tableView.reloadData()
    }
}


// MARK: - Table view data source
extension MainListsTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        } else if let sections = self.tableSections {
            return sections.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.searchResults.count
        } else {
            return self.tableSections[section].count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idMainListsCell", for: indexPath) as! MainListsTableViewCell
        let list: BookListObject!
        
        if isSearching {
            list = self.searchResults[indexPath.row]
        } else {
            list = self.tableSections[indexPath.section][indexPath.row]
        }
        
        cell.textLabel?.text = list.bookList.displayName.uppercased()
        return cell
    }
}


//MARK: - UITableView Delegate Methods
extension MainListsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list: BookListObject!
        
        if isSearching {
            list = self.searchResults[indexPath.row]
        } else {
            list = self.tableSections[indexPath.section][indexPath.row]
        }
        
        let bestSellerBooksTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "idBestSellerBooksTableViewController") as! BestSellerBooksTableViewController
        bestSellerBooksTableViewController.bookList = list.bookList
        
        self.navigationController?.pushViewController(bestSellerBooksTableViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (isSearching) {
            return nil
        } else {
            return self.sectionHeaders[section]
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.flatPurpleDark
        let label = (view as! UITableViewHeaderFooterView).textLabel
        label?.textColor = UIColor.flatWhite
        label?.font = UIFont(name: BBFonts.JosefinSlab_Bold.rawValue, size: 16)
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if (isSearching) {
            return nil
        } else {
            return UILocalizedIndexedCollation.current().sectionIndexTitles
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearching {
            return 0
        } else {
            return 20
        }
    }
    
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
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


// MARK: - Keyboard Notification Functions
extension MainListsTableViewController {
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyBoardHeight = keyboardSize.height
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyBoardHeight = 0
    }
}


// MARK: - Empty Data Set Methods
extension MainListsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_small")
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "BestBooks", attributes: [
            NSForegroundColorAttributeName : UIColor.flatPlum,
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
            ])
    }
    
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = askRefresh ? "An error occured. Pull to refresh." : ""
        
        return NSAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName : UIColor.flatPurple,
            NSFontAttributeName: UIFont.systemFont(ofSize: 14)
            ])
    }
    
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return  -50
    }
    
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return !refreshControl.isRefreshing
    }
}
