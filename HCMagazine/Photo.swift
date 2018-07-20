//
//  Photo.swift
//  HCMagazine
//
//  Object to represent photo in Galeri Foto page
//
//  Created by ayobandung on 5/11/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct Photo{
    
    var photoId:Int
    var photoFile:String
    var photoThumb:String
    var photoCaption:String
    var photoCourtesy:String
    var editionId:String
    
    mutating func newPhoto(id: Int, thumb: String, content:String, caption:String, courtesy:String, edition:String){
        photoId = id
        photoFile = content
        photoThumb = thumb
        photoCaption = caption
        photoCourtesy = courtesy
        editionId = edition
    }
    
}
