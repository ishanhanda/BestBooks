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
    
    /// The image of the book that is displayed in the Best Seller list.
    var bookImage: UIImage!
    
    // MARK: - Outlets
    @IBOutlet var topHeaderView: UIView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var bookDescriptionLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var coverImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var amazonButton: UIButton!
    @IBOutlet var reviewButton: UIButton!
    
    /// Transitioning delegate used for custom presentation of this View Controller.
    let detailViewControllerTransitioningDelegate = DetailViewControllerTransitioningDelegate()
    
    /// Gradient layer added to the top of the view.
    var gradientLayer: CAGradientLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coverImageView.image = self.bookImage
        
        bookTitle.text = book.title.uppercased()
        bookTitle.textColor = UIColor.flatWhite
        bookTitle.font = UIFont(name: BBFonts.Cinzel_Bold.rawValue, size: 22)
        
        // Display author name label only if it exists in model.
        if let authorName = book.author {
            authorLabel.isHidden = false
            authorLabel.textColor = UIColor.flatWhite
            authorLabel.font = UIFont(name: BBFonts.Cinzel_Bold.rawValue, size: 17)
            
            let author = "by"
            let authorString = "\(author) \(authorName)" as NSString
            let authorAttributedText = NSMutableAttributedString(string: authorString as String)
            let range = authorString.range(of: author)
            authorAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatGray, range: range)
            authorAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 16)!, range: range)
            self.authorLabel.attributedText = authorAttributedText
        } else {
            authorLabel.isHidden = true
        }
        
        bookDescriptionLabel.text = book.description
        bookDescriptionLabel.textColor = UIColor.lightGray
        bookDescriptionLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 17)
        
        // Display amazon button only if link exists in model.
        if let url = book.amazonProductURLString, url != "" {
            amazonButton.tintColor = UIColor.flatOrange
            amazonButton.titleLabel?.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 14)
        } else {
            amazonButton.isHidden = true
        }
        
        // Display Review button only if link exists in model.
        if (book.bookReviewURLString != nil && book.bookReviewURLString != "") || (book.sundayReviewURLSring != nil && book.bookReviewURLString != "") {
            reviewButton.tintColor = UIColor.lightGray
            reviewButton.titleLabel?.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 14)
        } else {
            reviewButton.isHidden = true
        }
        
        view.backgroundColor = UIColor.black
        
        self.transitioningDelegate = detailViewControllerTransitioningDelegate
        self.modalPresentationStyle = .custom
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.gradientLayer == nil {
            addGradient(view.bounds.width)
        }
        
        scrollView.flashScrollIndicators()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if let layer = gradientLayer {
            layer.removeFromSuperlayer()
        }
        
        // Resizing gradient on top.
        addGradient(size.width)
    }
    
    
    fileprivate func addGradient(_ width: CGFloat) {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0 , 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: 80)
        
        view.layer.addSublayer(gradientLayer)
        view.bringSubview(toFront: topHeaderView)
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
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        self.detailViewControllerTransitioningDelegate.animator.presenting = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nytButtonTapped(_ sender: AnyObject) {
        if let url = URL(string: NYTIMES_LOGO_LINK) {
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func readReviewButtonTapped(_ sender: AnyObject) {
        // Showing either one of two reviews available
        var urlString = book.bookReviewURLString
        if urlString ==  nil { urlString = book.sundayReviewURLSring }
        
        if let url = URL(string: urlString!) {
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func buyButtonTapped(_ sender: AnyObject) {
        if let url = URL(string: book.amazonProductURLString!) {
            let safariVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            present(safariVC, animated: true, completion: nil)
        }
    }
}


// MARK: - Custom presentation
extension BookDetailViewController {

    func presentFromImageRect(_ imageframe: CGRect, fromVC: BestSellerBooksTableViewController, completion: (() -> Void)? ) {
        self.detailViewControllerTransitioningDelegate.animator.imageOriginFrame = imageframe
        self.detailViewControllerTransitioningDelegate.animator.presenting = true
        self.detailViewControllerTransitioningDelegate.animator.previousSelectedIndexPath = fromVC.tableView.indexPathForSelectedRow!
        fromVC.present(self, animated: true) {
            if let givenCompletiton = completion {
                givenCompletiton()
            }
        }
    }
}
