//
//  PhotoCollectionViewCell.swift
//  HCMagazine
//
//  UICollectionViewCell to setup each photo uniformly in Galeri Foto page (PhotoGalleryCollectionViewController.swift)
//
//  Created by ayobandung on 5/11/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo_thumb: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photo_thumb.image = nil
    }
    
}
