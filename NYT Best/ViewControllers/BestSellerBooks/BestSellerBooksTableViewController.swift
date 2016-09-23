//
//  BestSellerBooksTableViewController.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import SDWebImage
import ChameleonFramework
import SafariServices
import DZNEmptyDataSet
import AVFoundation

class BestSellerBooksTableViewController: UIViewController {
    
    var bookList: BookList!
    
    var booksDataSource = [Book]()
    
    // MARK: - Outlets
    @IBOutlet var orderSegmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerViewVEF: UIVisualEffectView!
    @IBOutlet var footerVEF: UIVisualEffectView!
    @IBOutlet var nytButton: UIButton!
    
    var booksOrder: BooksOrder!
    
    /// Flag to check if activity indicator is being displayed currently
    var showingAcitvityIndicator = false
    
    /// The current computed content insets for the tableview
    var currentTableInsets: UIEdgeInsets {
        let top = !self.showingAcitvityIndicator ? topLayoutGuide.length + headerViewVEF.bounds.height : topLayoutGuide.length + headerViewVEF.bounds.height + self.heightForNotificationView()
        return UIEdgeInsets(top: top, left: 0, bottom: footerVEF.bounds.height, right: 0)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = bookList.displayName
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        if let order = getUserDefault(K_UD_BOOKS_ORDER) as? String {
            self.booksOrder = BooksOrder(rawValue: order)
        } else {
            self.booksOrder = .Rank
            setUserDefault(K_UD_BOOKS_ORDER, value: self.booksOrder.rawValue)
        }
        
        switch self.booksOrder! {
        case .Rank:
            self.orderSegmentControl.selectedSegmentIndex = 0
        case .Week:
            self.orderSegmentControl.selectedSegmentIndex = 1
        }
        
        self.fetchBooks()
    }
    
    
    /// Fetch books and update table view.
    private func fetchBooks() {
        let indicator = self.showActivityIndicatorView("Loading...", animations: {
            self.showingAcitvityIndicator = true
            }, completion: nil)
        
        let hideActivity = {
            self.hideNotificationView(indicator, animations: {
                self.showingAcitvityIndicator = false
                }, completion: nil)
        }
        
        NYTBCachingManager.sharedInstance.bookResponse(bookList.listNameEchoed) { (bookResposne, error, isResponseFromCache) in
            if let response = bookResposne where error == nil {
                self.booksDataSource = response.books
                self.sortBooks()
                
                // If response was loaded from cache. Make request to update cache.
                if isResponseFromCache {
                    indicator.messageLabel.text = "Updating..."
                    NYTBCachingManager.sharedInstance.updateCacheForBook(self.bookList.listNameEchoed, completion: { (bookResposne, error) in
                        if let response = bookResposne where error == nil {
                            self.booksDataSource = response.books
                            self.sortBooks()
                        } else {
                            self.showNotificationView("\(error!.localizedDescription)\nDisplaying cached data.", time: 3, animations: nil, completion: nil)
                            print(error)
                        }
                        
                        hideActivity()
                    })
                } else {
                    hideActivity()
                }
                
            } else if let err = error {
                self.showSingleAlert(err.localizedDescription) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                hideActivity()
            }
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.contentInset = currentTableInsets
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Button Actions
    
    @IBAction func orderSegmentValueChanged(sender: AnyObject) {
        switch orderSegmentControl.selectedSegmentIndex {
        case 0:
            self.booksOrder = .Rank
        case 1:
            self.booksOrder = .Week
        default:
            break
        }
        
        setUserDefault(K_UD_BOOKS_ORDER, value: self.booksOrder.rawValue)
        self.sortBooks()
    }
    
    
    func sortBooks() {
        switch orderSegmentControl.selectedSegmentIndex {
        case 0:
            booksDataSource.sortInPlace { $0.rank < $1.rank }
        case 1:
            booksDataSource.sortInPlace { $0.weeksOnList > $1.weeksOnList }
        default:
            break
        }
        
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
    }
    

    @IBAction func nytButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Table view data source Methods
extension BestSellerBooksTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return booksDataSource.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idBestsellerCell", forIndexPath: indexPath) as! BestsellerTableViewCell
        
        let book = booksDataSource[indexPath.row]
        cell.bookTitleLabel.text = book.title.uppercaseString
        
        if let author = book.author {
            cell.setAuthorLabelText(author)
            cell.authorLabel.hidden = false
        } else {
            cell.authorLabel.hidden = true
        }
        
        cell.setWeekLabelText(book.weeksOnList)
        cell.setRankLabelText(book.rank)
        
        let placeHolderImage = UIImage(named: "book_cover")!
        cell.backgroundColor = UIColor.init(averageColorFromImage: placeHolderImage).colorWithAlphaComponent(0.1)
        
        cell.setCoverImage(book.imageURL, otherURLs: book.otherImageURLs, placeHolderImage: placeHolderImage)
        
        return cell
    }
}


// MARK: - Table View delegate Methods
extension BestSellerBooksTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let book = booksDataSource[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BestsellerTableViewCell
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idBookDetailViewController") as! BookDetailViewController
        detailVC.book = book
        let image = cell.coverImageView.image!
        detailVC.bookImage = image
        
        // calculate book image frame with respect to self.view
        let cellImageRect = AVMakeRectWithAspectRatioInsideRect(image.size, cell.coverImageView.frame)
        let imageRect = cell.contentView.convertRect(cellImageRect, toView: self.view)
        
        detailVC.presentFromImageRect(imageRect, fromVC: self, completion: nil)
    }
}


// MARK: - ISHShowsTopActivityIndicator protocol Methods
extension BestSellerBooksTableViewController: ISHShowsTopActivityIndicator {
    func viewOnTopOfNotificationView() -> UIView {
        return self.headerViewVEF
    }
    
    
    func superViewOfNotificationView() -> UIView {
        return self.view
    }

    
    func heightForNotificationView() -> CGFloat {
        return 44
    }
}


// MARK: - Empty Data Set Methods
extension BestSellerBooksTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_small")
    }
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "BestBooks", attributes: [
            NSForegroundColorAttributeName : UIColor.flatPlumColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(20)
            ])
    }
    
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return  -50
    }
}
