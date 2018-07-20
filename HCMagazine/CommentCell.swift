//
//  CommentCell.swift
//  HCMagazine
//
//  UITableViewCell for comment system in comment page (CommentVC.swift)
//
//  Created by ayobandung on 9/25/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentText: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
