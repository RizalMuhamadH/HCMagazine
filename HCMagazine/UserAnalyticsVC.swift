//
//  UserAnalyticsVC.swift
//  HCMagazine
//
//  Display statistics of total active and inactive user with inactive users list with ability to send the list to email in form of csv (News Analytics Scene)
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import MessageUI
import Foundation

class UserAnalyticsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var inactiveLabel: UILabel!
    @IBOutlet weak var inactiveList: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Variables
    var convertMutable: NSMutableString!
    let userURL = "http://mobs.ayobandung.com/index.php/admin_controller/getUserAnalytic"
    // Background thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    var totalActive = ""
    var totalInactive = ""
    var inactiveUsername:[String] = []
    var inactiveName:[String] = []
    var inactiveEmail:[String] = []
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        inactiveList.addSubview(refreshControl) // not required when using UITableViewController

        UITabBar.appearance().tintColor = UIColor.white
        
        // Set table footer eliminates empty cells
        self.inactiveList.tableFooterView = UIView()
                
        // This view controller itself will provide the delegate methods and row data for the table view and search bar.
        inactiveList.delegate = self
        inactiveList.dataSource = self

        
        getData(userURL)
        // set label
        dispatchQueue.async {
            Thread.sleep(forTimeInterval: 1)
            OperationQueue.main.addOperation() {
                self.activeLabel.text = self.totalActive
                self.inactiveLabel.text = self.totalInactive
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send list to email
    @IBAction func sendMailList(_ sender: Any) {
        convertMutable = NSMutableString();
        convertMutable.appendFormat("%@\r", "Email")
        for item in inactiveEmail
        {
            convertMutable.appendFormat("%@\r", item)
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
        
        let messageBody = "Terlampir daftar email user bjb HC News yang belum aktif per tanggal \(dateTimeComponents.day!)-\(dateTimeComponents.month!)-\(dateTimeComponents.year!) \(dateTimeComponents.hour!):\(dateTimeComponents.minute!)"
        
        mailComposerVC.setSubject("Daftar user bjb HC News yang tidak aktif")
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        mailComposerVC.addAttachmentData(data, mimeType: "text/csv", fileName: "inactive_users.csv")
        return mailComposerVC
    }

    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        inactiveUsername = []
        inactiveName = []
        inactiveEmail = []
        getData(userURL)
        if (inactiveUsername.count == 0) {
            inactiveList.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 3)
                
                OperationQueue.main.addOperation() {
                    self.activeLabel.text = self.totalActive
                    self.inactiveLabel.text = self.totalInactive
                    self.inactiveList.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                   self.spinner.stopAnimating()
                   self.refreshControl.endRefreshing()
                    self.inactiveList.reloadData()
                }
            }
        }
        
    }
    
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (inactiveUsername.count == 0) {
            inactiveList.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 3)
                OperationQueue.main.addOperation() {
                    self.inactiveList.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.inactiveList.reloadData()
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
                    self.totalActive = json["active"].stringValue
                    self.totalInactive = json["notactive"].stringValue
                    var i = 0
                    let list = json["notactivelist"].arrayValue
                    
                    while(i<list.count){
                        self.inactiveUsername.insert(list[i]["username"].stringValue, at: i)
                        self.inactiveName.insert(list[i]["nama"].stringValue, at: i)
                        self.inactiveEmail.insert(list[i]["email"].stringValue, at: i)
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
        let cell:InactiveCell = tableView.dequeueReusableCell(withIdentifier: "inactiveCell", for: indexPath) as! InactiveCell
        
        //configure cell
        cell.usernameLabel.text = inactiveUsername[indexPath.row]
        cell.nameLabel.text = inactiveName[indexPath.row]
        cell.emailLabel.text = inactiveEmail[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //retrieve from database
        return inactiveUsername.count
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
