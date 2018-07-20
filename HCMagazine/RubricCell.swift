//
//  RubricCell.swift
//  HCMagazine
//
//  UITableViewCell for each article in news feed page, one edition page and rubric page. Setup content, animation and display like a card.
//
//  Created by ayobandung on 6/8/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class RubricCell: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var articleThumb: UIImageView!
    @IBOutlet weak var rubricTitle: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
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
