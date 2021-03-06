//
//  ISHActivityIndicatorView.swift
//  ISHTopNotificationView
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit


/// ISHTopNotificationView subclass to display an activity indicator with a message. Requires conformance to ISHShowsTopNotificationView protocol.
class ISHActivityIndicatorView: ISHTopNotificationView {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.clipsToBounds = true
        self.layer.masksToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }
}
