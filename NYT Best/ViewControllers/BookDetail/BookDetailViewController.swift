//
//  BookDetailViewController.swift
//  NYT Best
//
//  Created by Ishan Handa on 22/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import SDWebImage

class BookDetailViewController: UIViewController {

    var book: Book!
    var bookImage: UIImage!
    
    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var bookTitle: UILabel!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var bookDescriptionLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var coverImageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        coverImageView.image = self.bookImage
        bookTitle.text = book.title
        bookTitle.textColor = UIColor.flatWhiteColor()
        authorLabel.text = book.author
        authorLabel.textColor = UIColor.flatWhiteColor()
        bookDescriptionLabel.text = book.description
        bookDescriptionLabel.textColor = UIColor.flatWhiteColor()
        
        view.backgroundColor = UIColor.flatBlackColor()
        
        self.coverImageHeightConstraint.constant = max(250, (self.bookImage.size.height / UIScreen.mainScreen().scale))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Action Methods
    
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
