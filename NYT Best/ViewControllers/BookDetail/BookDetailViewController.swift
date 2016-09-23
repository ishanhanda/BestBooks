//
//  BookDetailViewController.swift
//  NYT Best
//
//  Created by Ishan Handa on 22/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices

class BookDetailViewController: UIViewController {

    var book: Book!
    var bookImage: UIImage!
    
    @IBOutlet var topHeaderView: UIView!
    
    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var bookTitle: UILabel!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var bookDescriptionLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var coverImageHeightConstraint: NSLayoutConstraint!
    
    let detailViewControllerTransitioningDelegate = DetailViewControllerTransitioningDelegate()
    
    var gradientLayer: CAGradientLayer!
    
//    private var backImageFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        coverImageView.image = self.bookImage
        
        bookTitle.text = book.title.uppercaseString
        bookTitle.textColor = UIColor.flatWhiteColor()
        bookTitle.font = UIFont(name: BBFonts.Cinzel_Bold.rawValue, size: 22)
        
        if let authorName = book.author {
            authorLabel.hidden = false
            authorLabel.textColor = UIColor.flatWhiteColor()
            authorLabel.font = UIFont(name: BBFonts.Cinzel_Bold.rawValue, size: 17)
            
            let author = "by"
            let authorString = "\(author) \(authorName)" as NSString
            let authorAttributedText = NSMutableAttributedString(string: authorString as String)
            let range = authorString.rangeOfString(author)
            authorAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatGrayColor(), range: range)
            authorAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 16)!, range: range)
            self.authorLabel.attributedText = authorAttributedText
        } else {
            authorLabel.hidden = true
        }
        
        bookDescriptionLabel.text = book.description
        bookDescriptionLabel.textColor = UIColor.lightGrayColor()
        bookDescriptionLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 17)
        
        view.backgroundColor = UIColor.blackColor()
        
        self.transitioningDelegate = detailViewControllerTransitioningDelegate
        self.modalPresentationStyle = .Custom
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
            gradientLayer.locations = [0.0 , 1.0]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.3)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 80)
            
            view.layer.addSublayer(gradientLayer)
            view.bringSubviewToFront(topHeaderView)
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentInset = UIEdgeInsetsMake(70, 0, 0, 0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Action Methods
    
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.detailViewControllerTransitioningDelegate.animator.presenting = false
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func nytButtonTapped(sender: AnyObject) {
        if let url = NSURL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: false)
            presentViewController(safariVC, animated: true, completion: nil)
        }
    }
}



extension BookDetailViewController {

    func presentFromImageRect(imageframe: CGRect, fromVC: BestSellerBooksTableViewController, completion: (() -> Void)? ) {
        self.detailViewControllerTransitioningDelegate.animator.imageOriginFrame = imageframe
        self.detailViewControllerTransitioningDelegate.animator.presenting = true
        self.detailViewControllerTransitioningDelegate.animator.previousSelectedIndexPath = fromVC.tableView.indexPathForSelectedRow!
        fromVC.presentViewController(self, animated: true) {
            if let givenCompletiton = completion {
                givenCompletiton()
            }
        }
    }
}