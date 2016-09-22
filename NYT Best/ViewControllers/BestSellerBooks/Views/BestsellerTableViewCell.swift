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
        
        bookTitleLabel.font = UIFont.systemFontOfSize(18)
        bookTitleLabel.textColor = UIColor.flatPurpleColor()
        
        authorLabel.font = UIFont.systemFontOfSize(14)
        authorLabel.textColor = UIColor.grayColor()
        
        rankLabel.font = UIFont.systemFontOfSize(12)
        rankLabel.textColor = UIColor.grayColor()
        
        weekLabel.font = UIFont.systemFontOfSize(12)
        weekLabel.textColor = UIColor.grayColor()
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setAuthorLabelText(text: String) {
        let author = "Author"
        let authorString = "\(author) \(text)" as NSString
        let authorAttributedText = NSMutableAttributedString(string: authorString as String)
        let range = authorString.rangeOfString(author)
        authorAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
        authorAttributedText.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: range)
        self.authorLabel.attributedText = authorAttributedText
    }
    
    
    func setRankLabelText(value: Int) {
        let rank = "Rank"
        let rankString = "\(rank) \(value)" as NSString
        let rankAttributedText = NSMutableAttributedString(string: rankString as String)
        rankAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: rankString.rangeOfString(rank))
        self.rankLabel.attributedText = rankAttributedText        
    }
    
    
    func setWeekLabelText(value: Int) {
        if value == 0 {
            weekLabel.text = "Less than one week on list"
        } else {
            let week = value > 1 ? "Weeks on list" : "Week on list"
            let weekString = "\(value) \(week)" as NSString
            let weekAttributedText = NSMutableAttributedString(string: weekString as String)
            weekAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: weekString.rangeOfString(week))
            weekLabel.attributedText = weekAttributedText
        }
    }
    
    
    func setCoverImage(url: NSURL, placeHolderImage: UIImage) {
        self.coverImageView.sd_setImageWithURL(url, placeholderImage: placeHolderImage, completed: { (image, error, cacheType, url) in
            if error == nil && image != nil {
                self.backgroundColor = UIColor.init(averageColorFromImage: image).colorWithAlphaComponent(0.1)
            }
        })
    }
}
