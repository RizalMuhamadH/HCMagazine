//
//  NewsAdmin.swift
//  HCMagazine
//
//  Object to represent news in news analytics
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct NewsAdmin{
    
    var newsTitle:String
    var rubricTitle:String
    var editionId:Int
    var newsSeen:Int
    var newsLiked:Int
    var newsComment:Int
    var lastView:String
    
    mutating func newNewsAdmin(title: String,rubTitle:String, edition:Int, read:Int, likes:Int, comments:Int, last: String ){
        newsTitle = title
        rubricTitle = rubTitle
        editionId = edition
        newsSeen = read
        newsLiked = likes
        newsComment = comments
        lastView = last
    }
}
