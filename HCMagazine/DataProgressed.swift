//
//  DataProgressed.swift
//  HCMagazine
//
//  Internal database to track which article user has read. Method called throughout the app.
//  3rd party plugin: Github by stephencelis/SQLite.swift
//
//  Created by ayobandung on 9/4/17.
//  Last modified on 10/12/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import Foundation
import SQLite

class DataProgressed{
    
    static let instance = DataProgressed()
    private let db: Connection?
    
    private let newsTrack = Table("news")
    private let id = Expression<Int>("id")
    private let title = Expression<String?>("title")
    private let edition = Expression<Int>("edition")
    private let rubric = Expression<Int>("rubric")
    private let hasRead = Expression<Int?>("read")
    
    private let allNewsURL = "http://mobs.ayobandung.com/index.php/news_controller/getAllEditionNews"
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/bjbTrack.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(newsTrack.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(title, unique: true)
                table.column(edition)
                table.column(rubric)
                table.column(hasRead)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    // MARK: CRUD Database
    
    // Insert news tracker
    func addNewsTracker(cid:Int, ctitle: String, cedition: Int, crubric: Int, chasRead: Int) -> Int {
        do {
            let id = try db!.run(newsTrack.insert(self.id <- cid, title <- ctitle, edition <- cedition, rubric <- crubric, hasRead <- chasRead))
            return Int(id)
        } catch {
            print("Insert failed")
            return -1
        }
    }
    
    // Retrun list News from sql
    func getNewsTracker() -> [News] {
        var newsTracklist = [News]()
        
        do {
            for news in try db!.prepare(newsTrack) {
                newsTracklist.append(News(newsId: news[id], newsTitle: news[title]!, newsSummary:"", newsContent:"",newsGimmick: "", rubricId:news[rubric], rubricTitle:"", rubricSummary: "", editionId:news[edition], newsThumb:"", newsLiked:0, newsHits: 0, newsComment: 0))
            }
        } catch {
            print("Select failed")
        }
        
        return newsTracklist
    }
    
    // Print tracking list
    func printNewsTracker(){
        do {
            for news in try db!.prepare(newsTrack) {
                print("id: \(news[id]), hasRead: \(news[hasRead]!)")
            }
        } catch {
            print("Print failed")
        }

    }
    
    // Upadate record as read
    func updateNewsTracker(cid:Int) -> Bool {
        let newstrack = newsTrack.filter(id == cid)
        do {
            let update = newstrack.update([
                hasRead <- 1
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
    }
    
    // Check if record existed or not
    func checkNewsTracker(cid:Int) -> Bool{
        let newstrack = newsTrack.filter(id == cid)
        do {
            for news in try db!.prepare(newstrack) {
                if news[id] != 0{
                    return true
                }
            }
        } catch {
            print("Not Found: \(error)")
        }
        
        return false
    }
    
    // Get unread news
    func getUnreadNews() -> News{
        var newsTracklist = [News]()
        var retNews = News(newsId: 0, newsTitle: "", newsSummary: "", newsContent: "", newsGimmick: "", rubricId: 0, rubricTitle: "", rubricSummary: "", editionId: 0, newsThumb: "", newsLiked: 0, newsHits: 0, newsComment: 0)
        let query = newsTrack.select(*)
                             .filter(hasRead == 0)
                             .order(edition.desc)
        do {
            for news in try db!.prepare(query) {
                newsTracklist.append(News(newsId: news[id], newsTitle: news[title]!, newsSummary:"", newsContent:"", newsGimmick: "", rubricId:news[rubric], rubricTitle:"", rubricSummary: "", editionId:news[edition], newsThumb:"", newsLiked:0, newsHits: 0, newsComment: 0))
            }
            let randomNum = Int(arc4random_uniform(UInt32(newsTracklist.count)))
            retNews = newsTracklist[randomNum]
        } catch {
            print("Error \(error)")
        }
        
        return retNews
    }
    
    
    // MARK: - Connection to API
    
    func getData() {
        let url:URL = URL(string: allNewsURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request){ (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil else{
                print("error calling POST")
                print(error!)
                return
            }
            
            guard let responseData = data else{
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                let json = try JSON(data: responseData)
                let state = json["status"].stringValue
                print("The state is: \(state)")
                let newsData = json["data"].arrayValue
                var i = 0
                if(state=="success"){
                    while (i<newsData.count){
                        if !(self.checkNewsTracker(cid: newsData[i]["news_id"].intValue)){
                            let retId = self.addNewsTracker(cid: newsData[i]["news_id"].intValue, ctitle: newsData[i]["news_title"].stringValue, cedition: newsData[i]["edition_id"].intValue, crubric: newsData[i]["rubric_id"].intValue, chasRead: 0)
                            print("add news \(retId)")
                        }
                        i += 1
                    }
                }else{
                   print("JSON Failed")
                }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
    }

}
