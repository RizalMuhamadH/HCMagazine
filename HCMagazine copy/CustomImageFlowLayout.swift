//
//  CustomImageFlowLayout.swift
//  HCMagazine
//
//  Setup grid layout to only use 3 columns for Galeri Foto page (PhotoGalleryCollectionViewController.swift) like instagram
//
//  Created by ayobandung on 5/11/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 3
            
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = .vertical
    }
}
