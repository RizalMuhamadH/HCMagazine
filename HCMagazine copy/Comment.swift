//
//  Comment.swift
//  HCMagazine
//
//  Object to represent comment
//
//  Created by ayobandung on 9/25/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct Comment{
    
    var id:Int
    var username:String
    var name:String
    var date:String
    var tbody:String
    
    mutating func newComment(commentId: Int, userId: String, userName:String, commentDate:String,commentText:String){
        id = commentId
        username = userId
        name = userName
        date = commentDate
        tbody = commentText
    }
    
}
