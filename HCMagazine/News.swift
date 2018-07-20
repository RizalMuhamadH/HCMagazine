//
//  News.swift
//  HCMagazine
//
//  Object to represent news
//
//  Created by ayobandung on 6/9/17.
//  Last modified on 10/12/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation

struct News{
    
    var newsId:Int
    var newsTitle:String
    var newsSummary:String
    var newsContent:String
    var newsGimmick:String
    var rubricId:Int
    var rubricTitle:String
    var rubricSummary:String
    var editionId:Int
    var newsThumb:String
    var newsLiked:Int
    var newsHits:Int
    var newsComment:Int

    mutating func newNews(id: Int, title: String, summary:String, content:String, gimmick:String ,rubric:Int, rubTitle:String, rubSummary:String, edition:Int, thumb:String, counter:Int, hits:Int, totalComment:Int ){
        newsId = id
        newsTitle = title
        newsSummary = summary
        newsContent = content
        newsGimmick = gimmick
        rubricId = rubric
        rubricTitle = rubTitle
        rubricSummary = rubSummary
        editionId = edition
        newsThumb = thumb
        newsLiked = counter // Like counter
        newsHits = hits
        newsComment = totalComment
    }
    
}
