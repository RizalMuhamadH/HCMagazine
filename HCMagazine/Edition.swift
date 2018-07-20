//
//  Edition.swift
//  HCMagazine
//
//  Object to represent edition
//
//  Created by ayobandung on 5/9/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct Edition{
    
    var editionId:String
    var imgFileName:String
    var editionDate:String
    
    mutating func newEdition(id: String, img: String, date:String){
        editionId = id
        imgFileName = img
        editionDate = date
    }
    
}
