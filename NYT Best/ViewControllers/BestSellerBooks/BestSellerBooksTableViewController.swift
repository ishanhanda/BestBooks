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

class BestSellerBooksTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var bookList: BookList!
    var booksDataSource = [Book]()
    @IBOutlet var orderSegmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerViewVEF: UIVisualEffectView!
    @IBOutlet var footerVEF: UIVisualEffectView!
    @IBOutlet var nytButton: UIButton!
    
    var showingAcitvityIndicator = false
    
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
                self.booksDataSource.sortInPlace { $0.rank < $1.rank }
                self.orderSegmentControl.setEnabled(true, forSegmentAtIndex: 0)
                self.tableView.reloadData()
                
                if isResponseFromCache {
                    indicator.messageLabel.text = "Updating..."
                    NYTBCachingManager.sharedInstance.updateCacheForBook(self.bookList.listNameEchoed, completion: { (bookResposne, error) in
                        if let response = bookResposne where error == nil {
                            self.booksDataSource = response.books
                            self.booksDataSource.sortInPlace { $0.rank < $1.rank }
                            self.orderSegmentControl.setEnabled(true, forSegmentAtIndex: 0)
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
                
            } else if let err = error {
                self.showSingleAlert(err.localizedDescription) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
                hideActivity()
            }
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

    // MARK: - Table view data source

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
        cell.bookTitleLabel.text = book.title
        
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
                
        if let imgURL = book.imageURLString {
            cell.setCoverImage(imgURL, placeHolderImage: placeHolderImage)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        detailVC.bookImage = cell.coverImageView.image
        
        let aNavVC = UINavigationController(rootViewController: detailVC)
        aNavVC.navigationBar.barStyle = .Black
        aNavVC.navigationBar.tintColor = UIColor.flatWhiteColor()
        
        self.presentViewController(aNavVC, animated: true, completion: nil)
    }
    
    // MARK: - Button Actions
    
    @IBAction func orderSegmentValueChanged(sender: AnyObject) {
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
