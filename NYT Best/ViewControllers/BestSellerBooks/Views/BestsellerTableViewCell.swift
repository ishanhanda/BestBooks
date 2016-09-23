//
//  BestsellerTableViewCell.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

class BestsellerTableViewCell: UITableViewCell {
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var weekLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        bookTitleLabel.font = UIFont(name: BBFonts.Cinzel_Regular.rawValue, size: 19)
        bookTitleLabel.textColor = UIColor.flatPlumColorDark()
        
        authorLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 16)
        authorLabel.textColor = UIColor.flatPlumColorDark()
        
        rankLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 15)
        rankLabel.textColor = UIColor.flatPlumColor()
        
        weekLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 14)
        weekLabel.textColor = UIColor.flatPlumColor()
    }
    
    
    func setAuthorLabelText(text: String) {
        let author = "by"
        let authorString = "\(author) \(text)" as NSString
        let authorAttributedText = NSMutableAttributedString(string: authorString as String)
        let range = authorString.rangeOfString(author)
        authorAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlumColor(), range: range)
        authorAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: range)
        self.authorLabel.attributedText = authorAttributedText
    }
    
    
    func setRankLabelText(value: Int) {
        let rank = "Rank"
        let rankString = "\(rank) \(value)" as NSString
        let rankAttributedText = NSMutableAttributedString(string: rankString as String)
        rankAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlumColorDark(), range: rankString.rangeOfString(rank))
        rankAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: rankString.rangeOfString(rank))
        self.rankLabel.attributedText = rankAttributedText        
    }
    
    
    func setWeekLabelText(value: Int) {
        if value == 0 {
            weekLabel.text = "New this week"
        } else {
            let week = value > 1 ? "Weeks on list" : "Week on list"
            let weekString = "\(value) \(week)" as NSString
            let weekAttributedText = NSMutableAttributedString(string: weekString as String)
            weekAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlumColorDark(), range: weekString.rangeOfString(week))
            weekAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: weekString.rangeOfString(week))
            weekLabel.attributedText = weekAttributedText
        }
    }
    
    
    func setCoverImage(url: NSURL?, otherURLs: [NSURL]?, placeHolderImage: UIImage) {
        
        func setImage(anImageURL: NSURL, completion: (success: Bool) -> ()) {
            self.coverImageView.sd_setImageWithURL(anImageURL, placeholderImage: placeHolderImage, completed: { (image, error, cacheType, url) in
                if error == nil && image != nil {
                    completion(success: true)
                    self.backgroundColor = UIColor.init(averageColorFromImage: image).colorWithAlphaComponent(0.1)
                } else {
                    completion(success: false)
                }
            })
        }
        
        var currentURL = 0
        
        func tryOtherURLs()  {
            guard let otherImageUrls = otherURLs else { return }
            if currentURL == otherImageUrls.count { return }
            setImage(otherImageUrls[currentURL], completion: { (success) in
                if success {
                    return
                } else {
                    currentURL += 1
                    tryOtherURLs()
                }
            })
        }
        
        if let aURL = url {
            setImage(aURL, completion: { (success) in
                if !success { tryOtherURLs() }
            })
        }
    }
}
