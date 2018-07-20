//
//  RelatedNewsColCell.swift
//  HCMagazine
//
//  UICollectionViewCell for related news article page (ArticleViewController.swift and ArticleNotifViewController.swift)
//
//  Created by ayobandung on 9/26/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class RelatedNewsColCell: UICollectionViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var relatedImg: UIImageView!
    @IBOutlet weak var relatedTitle: UILabel!
    @IBOutlet weak var readCounter: UILabel!
    @IBOutlet weak var commentCounter: UILabel!
    @IBOutlet weak var likesCounter: UILabel!
    
    // add shadow effect
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
}
