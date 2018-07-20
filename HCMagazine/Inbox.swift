//
//  Inbox.swift
//  HCMagazine
//
//  Object for announcement/message/inbox
//
//  Created by ayobandung on 5/9/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
struct Inbox{
    
    var inboxId:String
    var inboxTitle:String
    var inboxBody:String
    var inboxDate:String
    
    mutating func newEdition(id: String, title: String, body:String, date:String){
        inboxId = id
        inboxTitle = title
        inboxBody = body
        inboxDate = date
    }
    
}
