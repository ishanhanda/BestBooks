//
//  MainListsTableViewCell.swift
//  NYT Best
//
//  Created by Ishan Handa on 21/09/16.
//  Copyright © 2016 Ishan Handa. All rights reserved.
//

import UIKit
import ChameleonFramework

class MainListsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.textLabel?.textColor = UIColor.flatPlumColorDark()
        self.textLabel?.font = UIFont(name: BBFonts.Cinzel_Regular.rawValue, size: 16)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
