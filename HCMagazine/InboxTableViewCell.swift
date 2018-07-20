//
//  InboxTableViewCell.swift
//  HCMagazine
//
//  UITableViewCell to setup each announcement/message/inbox in Pengumuman page (InboxViewController.swift)
//
//  Created by ayobandung on 4/19/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var inboxSubjectLabel: UILabel!
    @IBOutlet weak var inboxDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
