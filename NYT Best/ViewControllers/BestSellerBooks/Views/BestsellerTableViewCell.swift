//
//  BestsellerTableViewCell.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import ChameleonFramework
import SDWebImage

class BestsellerTableViewCell: UITableViewCell {
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var weekLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        
        bookTitleLabel.font = UIFont(name: BBFonts.Cinzel_Regular.rawValue, size: 19)
        bookTitleLabel.textColor = UIColor.flatPlumDark
        
        authorLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 16)
        authorLabel.textColor = UIColor.flatPlumDark
        
        rankLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 15)
        rankLabel.textColor = UIColor.flatPlum
        
        weekLabel.font = UIFont(name: BBFonts.JosefinSlab_SemiBold.rawValue, size: 14)
        weekLabel.textColor = UIColor.flatPlum
    }
    
    
    func setAuthorLabelText(_ text: String) {
        let author = "by"
        let authorString = "\(author) \(text)" as NSString
        let authorAttributedText = NSMutableAttributedString(string: authorString as String)
        let range = authorString.range(of: author)
        authorAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlum, range: range)
        authorAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: range)
        self.authorLabel.attributedText = authorAttributedText
    }
    
    
    func setRankLabelText(_ value: Int) {
        let rank = "Rank"
        let rankString = "\(rank) \(value)" as NSString
        let rankAttributedText = NSMutableAttributedString(string: rankString as String)
        rankAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlumDark, range: rankString.range(of: rank))
        rankAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: rankString.range(of: rank))
        self.rankLabel.attributedText = rankAttributedText        
    }
    
    
    func setWeekLabelText(_ value: Int) {
        if value == 0 {
            weekLabel.text = "New this week"
        } else {
            let week = value > 1 ? "Weeks on list" : "Week on list"
            let weekString = "\(value) \(week)" as NSString
            let weekAttributedText = NSMutableAttributedString(string: weekString as String)
            weekAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatPlumDark, range: weekString.range(of: week))
            weekAttributedText.addAttribute(NSFontAttributeName, value: UIFont(name: BBFonts.JosefinSlab.rawValue, size: 13)!, range: weekString.range(of: week))
            weekLabel.attributedText = weekAttributedText
        }
    }
    
    
    func setCoverImage(_ url: URL?, otherURLs: [URL]?, placeHolderImage: UIImage) {
        
        func setImage(_ anImageURL: URL, completion: @escaping (_ success: Bool) -> ()) {
            self.coverImageView.sd_setImage(with: anImageURL,
                                            placeholderImage: placeHolderImage,
                                            options: []) { (image, error, cacheType, url) in
                if error == nil && image != nil {
                    completion(true)
                    self.backgroundColor = UIColor(averageColorFrom: image!).withAlphaComponent(0.1)
                } else {
                    completion(false)
                }
            }
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
