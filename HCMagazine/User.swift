//
//  User.swift
//  HCMagazine
//
//  Object to represent user
//
//  Created by ayobandung on 5/9/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct User{
    
    var userId:String
    var userName:String
    var userEmail:String
    var userNameReal:String
    
    mutating func newUser(id: String, user_name: String, email:String, name:String){
        userId = id
        userName = user_name
        userEmail = email
        userNameReal = name
    }
    
}
