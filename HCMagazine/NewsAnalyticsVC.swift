//
//  NewsAnalyticsVC.swift
//  HCMagazine
//
//  Display statistics of each news from edition, rubric, title, total read, total likes and last viewed with ability to send the list to email in form of csv (News Analytics Scene)
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class NewsAnalyticsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // MARk: - Properties
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Variables
    var convertMutable: NSMutableString!
    let newsURL = "http://mobs.ayobandung.com/index.php/admin_controller/getNewsAnalytic"
    // Background thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    var newsAdmin:[NewsAdmin]=[]
    var refreshControl:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        newsTable.addSubview(refreshControl) // not required when using UITableViewController
        
        UITabBar.appearance().tintColor = UIColor.white
        
        // Set table footer eliminates empty cells
        self.newsTable.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view and search bar.
        newsTable.delegate = self
        newsTable.dataSource = self
        
        getData(newsURL)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // Send list to email
    @IBAction func sendNewsReport(_ sender: Any) {
        convertMutable = NSMutableString();
        convertMutable.appendFormat("%@\r","Edisi;Judul Rubrik;Judul Artikel;Jumlah Dibaca;Jumlah Disukai;Jumlah Komentar;Terkahir Dibaca")
        for item in newsAdmin
        {
            convertMutable.appendFormat("%@\r","\(item.editionId);\(item.rubricTitle);\(item.newsTitle);\(item.newsSeen);\(item.newsLiked);\(item.newsComment);\(item.lastView)")
        }
        
        let data = convertMutable.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        if let d = data {
            let mailComposeViewController = configuredMailComposeViewController(d)
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                alertPop("Cancel", "Can't Send Email")
            }
        }
    }
    
    func configuredMailComposeViewController(_ data: Data) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        // get the current date and time
        let currentDateTime = Date()
        
        // get the user's calendar
        let userCalendar = Calendar.current
        
        // choose which date and time components are needed
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        
        let messageBody = "Terlampir report news analytics per tanggal \(dateTimeComponents.day!)-\(dateTimeComponents.month!)-\(dateTimeComponents.year!) \(dateTimeComponents.hour!):\(dateTimeComponents.minute!)"
        
        mailComposerVC.setSubject("Report News Analytics")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        mailComposerVC.addAttachmentData(data, mimeType: "text/csv", fileName: "news_analytics.csv")
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        newsAdmin = []
        getData(newsURL)
        if (newsAdmin.count == 0) {
            newsTable.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 4)
                
                OperationQueue.main.addOperation() {
                    self.newsTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.newsTable.reloadData()
                }
            }
        }
        
    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (newsAdmin.count == 0) {
            newsTable.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 4)
                OperationQueue.main.addOperation() {
                    self.newsTable.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.newsTable.reloadData()
                }
            }
        }
    }


    
    // MARK - Connection to API
    
    func getData(_ link:String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.setValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request){ (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil else{
                print("error calling GET")
                print(error!)
                self.alertPop("Batal", "Gagal mengambil data")
                return
            }
            
            guard let responseData = data else{
                print("Error: did not receive data")
                self.alertPop("Batal", "Gagal menerima data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                let json = try JSON(data: responseData)
                let state = json["status"].stringValue
                print("The state is: \(state)")
                if(state=="success"){
                    var i = 0
                    let list = json["data"].arrayValue
                    
                    while(i<list.count){
                        let newNewsAdm = NewsAdmin(newsTitle: list[i]["news_title"].stringValue,rubricTitle:list[i]["rubric_title"].stringValue, editionId:list[i]["edition_id"].intValue, newsSeen:list[i]["hits"].intValue, newsLiked:list[i]["likes"].intValue, newsComment:list[i]["comment"].intValue, lastView: list[i]["last_viewed"].stringValue)
                        self.newsAdmin.append(newNewsAdm)
                        i += 1
                    }
                }else{
                    self.alertPop("Batal", "Gagal menampilkan data")
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ArticleAdminCell = tableView.dequeueReusableCell(withIdentifier: "newsAdminCell", for: indexPath) as! ArticleAdminCell
        
        //configure cell
        cell.editionLabel.text = "Edisi \(newsAdmin[indexPath.row].editionId)"
        cell.rubricLabel.text = newsAdmin[indexPath.row].rubricTitle
        cell.articleLabel.text = newsAdmin[indexPath.row].newsTitle
        cell.seenLabel.text = "\(newsAdmin[indexPath.row].newsSeen)"
        cell.likeLabel.text = "\(newsAdmin[indexPath.row].newsLiked)"
        cell.commentLabel.text = "\(newsAdmin[indexPath.row].newsComment)"
        cell.lastReadLabel.text = reverseDateTime(newsAdmin[indexPath.row].lastView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //retrieve from database
        return newsAdmin.count
    }

    func reverseDateTime(_ stamp: String)->String{
        let arrStamp = stamp.components(separatedBy: " ")
        let arrDate = arrStamp[0].components(separatedBy: "-")
        return "\(arrDate[2])-\(arrDate[1])-\(arrDate[0]) \(arrStamp[1])"
    }
    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }


}
