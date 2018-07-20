//
//  HeadlineCell.swift
//  HCMagazine
//
//  UITableViewCell for headline only in news feed page (DisplayViewController.swift)
//
//  Created by ayobandung on 6/12/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class HeadlineCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var headlineCover: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var headlineTitle: UILabel!
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var commentCounter: UILabel!
    @IBOutlet weak var readCounter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor =  UIColor.init(red: 230, green: 231, blue: 232)
        backgroundCardView.layer.cornerRadius = 5.0
        backgroundCardView.layer.masksToBounds = false
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowOpacity = 0.8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
