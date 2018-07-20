//
//  InactiveCell.swift
//  HCMagazine
//
//  UITableViewCell to setup each inactive account (UserAnalyticsVC.swift)
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class InactiveCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
