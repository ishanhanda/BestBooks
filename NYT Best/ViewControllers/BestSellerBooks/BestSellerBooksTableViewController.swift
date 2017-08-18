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
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        if let order = getUserDefault(K_UD_BOOKS_ORDER) as? String {
            self.booksOrder = BooksOrder(rawValue: order)
        } else {
            self.booksOrder = .Rank
            setUserDefault(K_UD_BOOKS_ORDER, value: self.booksOrder.rawValue as AnyObject)
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
    fileprivate func fetchBooks() {
        let indicator = self.showActivityIndicatorView("Loading...", animations: {
            self.showingAcitvityIndicator = true
            }, completion: nil)
        
        let hideActivity = {
            self.hideNotificationView(indicator, animations: {
                self.showingAcitvityIndicator = false
                }, completion: nil)
        }
        
        NYTBCachingManager.sharedInstance.bookResponse(bookList.listNameEchoed) { (bookResposne, error, isResponseFromCache) in
            if let response = bookResposne, error == nil {
                self.booksDataSource = response.books
                self.sortBooks()
                
                // If response was loaded from cache. Make request to update cache.
                if isResponseFromCache {
                    indicator.messageLabel.text = "Updating..."
                    NYTBCachingManager.sharedInstance.updateCacheForBook(self.bookList.listNameEchoed, completion: { [weak self] (bookResposne, error) in
                        if let response = bookResposne, error == nil {
                            self?.booksDataSource = response.books
                            self?.sortBooks()
                        } else {
                            _ = self?.showNotificationView("\(error!.localizedDescription)\nDisplaying cached data.", time: 3, animations: nil, completion: nil)
                            print(error?.localizedDescription as Any)
                        }
                        
                        hideActivity()
                    })
                } else {
                    hideActivity()
                }
                
            } else if let err = error {
                self.showSingleAlert(err.localizedDescription) {
                    self.navigationController?.popViewController(animated: true)
                }
                
                hideActivity()
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
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
    
    @IBAction func orderSegmentValueChanged(_ sender: AnyObject) {
        switch orderSegmentControl.selectedSegmentIndex {
        case 0:
            self.booksOrder = .Rank
        case 1:
            self.booksOrder = .Week
        default:
            break
        }
        
        setUserDefault(K_UD_BOOKS_ORDER, value: self.booksOrder.rawValue as AnyObject)
        self.sortBooks()
    }
    
    
    func sortBooks() {
        switch orderSegmentControl.selectedSegmentIndex {
        case 0:
            booksDataSource.sort { $0.rank < $1.rank }
        case 1:
            booksDataSource.sort { $0.weeksOnList > $1.weeksOnList }
        default:
            break
        }
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    

    @IBAction func nytButtonTapped(_ sender: AnyObject) {
        if let url = URL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            present(safariVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Table view data source Methods
extension BestSellerBooksTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return booksDataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idBestsellerCell", for: indexPath) as! BestsellerTableViewCell
        
        let book = booksDataSource[indexPath.row]
        cell.bookTitleLabel.text = book.title.uppercased()
        
        if let author = book.author {
            cell.setAuthorLabelText(author)
            cell.authorLabel.isHidden = false
        } else {
            cell.authorLabel.isHidden = true
        }
        
        cell.setWeekLabelText(book.weeksOnList)
        cell.setRankLabelText(book.rank)
        
        let placeHolderImage = UIImage(named: "book_cover")!
        cell.backgroundColor = UIColor(averageColorFrom: placeHolderImage).withAlphaComponent(0.1)
        
        cell.setCoverImage(book.imageURL, otherURLs: book.otherImageURLs, placeHolderImage: placeHolderImage)
        
        return cell
    }
}


// MARK: - Table View delegate Methods
extension BestSellerBooksTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = booksDataSource[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! BestsellerTableViewCell
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "idBookDetailViewController") as! BookDetailViewController
        detailVC.book = book
        let image = cell.coverImageView.image!
        detailVC.bookImage = image
        
        // calculate book image frame with respect to self.view
        let cellImageRect = AVMakeRect(aspectRatio: image.size, insideRect: cell.coverImageView.frame)
        let imageRect = cell.contentView.convert(cellImageRect, to: self.view)
        
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
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo_small")
    }
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "BestBooks", attributes: [
            NSForegroundColorAttributeName : UIColor.flatPlum,
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
            ])
    }
    
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return  -50
    }
}
