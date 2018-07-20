//
//  DrawerMenuCell.swift
//  HCMagazine
//
//  UITableViewCell to setup each entry(rubric/home) in drawer menu (BackTableVC.swift)
//
//  Created by ayobandung on 6/7/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class DrawerMenuCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var menuTitle: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
