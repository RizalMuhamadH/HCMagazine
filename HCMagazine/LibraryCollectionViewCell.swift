//
//  LibraryCollectionViewCell.swift
//  HCMagazine
//
//  UICollectionViewCell to setup each edition image and info content uniformly in Direktori Edisi page (LibraryCollectionViewController.swift)
//
//  Created by ayobandung on 4/19/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var editionCover: UIImageView!
    @IBOutlet weak var editionNum: UILabel!
    @IBOutlet weak var editionDate: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
