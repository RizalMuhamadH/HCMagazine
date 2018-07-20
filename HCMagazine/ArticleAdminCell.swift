//
//  ArticleAdminCell.swift
//  HCMagazine
//
//  UITableViewCell to setup each article statistics from edition, rubric, title, total read, total likes and last viewed article date time (NewsAnalyticsVC.swift)
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class ArticleAdminCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var rubricLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var lastReadLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
