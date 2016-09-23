//
//  ISHTopNotificationView.swift
//  ISHTopNotificationView
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit

/// ISHTopNotificationView class to display non-intrusive notifications on UIViewControllers. Requires conformance to ISHShowsTopNotificationView protocol.
class ISHTopNotificationView: UIView, NibLoadable {
    
    @IBOutlet var messageLabel: UILabel!
    
    var heightConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
