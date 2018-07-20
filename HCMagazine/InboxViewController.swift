//
//  InboxViewController.swift
//  HCMagazine
//
//  Pengumuman page that  lists all announcement (Inbox Scene)
//
//  Created by ayobandung on 4/19/17.
//  Last Modified on 8/28/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var inboxTableView: UITableView!
    
    // MARK: - Variables
    var inboxList:[Inbox] = []
    var readList:[Bool] = []
    let defaults = UserDefaults.standard
    // Background thread
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let inboxURL = "http://mobs.ayobandung.com/index.php/message_controller/getAllMessage"
    var refreshControl:UIRefreshControl = UIRefreshControl()

    // Cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "MsgCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUnread()

        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        inboxTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        inboxTableView.backgroundView = activityIndicatorView

        // Set table footer eliminates empty cells
        self.inboxTableView.tableFooterView = UIView()
        
        // Register the table view cell class and its reuse id
        self.inboxTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the table view and search bar.
        inboxTableView.delegate = self
        inboxTableView.dataSource = self
        
        getData(inboxURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check existed user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // Check unread message from user defaults
    func checkUnread(){
        if isKeyPresentInUserDefaults(key: "read"){
            readList = defaults.array(forKey: "read") as? [Bool] ?? [Bool]()
        }
    }
    
    @IBAction func markAllRead(_ sender: Any) {
        var k = 0
        while(k<readList.count){
            readList[k] = true
            k += 1
        }
        defaults.set(readList, forKey: "read")
        defaults.synchronize()
        inboxTableView.reloadData()
    }

    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        inboxList = []
        readList = []
        getData(inboxURL)
        if (inboxList.count == 0) {
            inboxTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.inboxTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.inboxTableView.reloadData()
                }
            }
        }
        
    }

    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (inboxList.count == 0) {
            inboxTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.inboxTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.activityIndicatorView.stopAnimating()
                    self.inboxTableView.reloadData()
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
                print("error calling POST")
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
                    let inboxData = json["data"].arrayValue
                    var i = 0
                    while (i<inboxData.count){
                        let newInbox = Inbox(inboxId: inboxData[i]["msg_id"].stringValue, inboxTitle: inboxData[i]["msg_title"].stringValue, inboxBody: inboxData[i]["msg_content"].stringValue, inboxDate: self.dateIndo(inboxData[i]["date_published"].stringValue))
                        self.inboxList.append(newInbox)
                        i += 1
                    }
                    if self.readList.count != self.inboxList.count{
                        let different = self.inboxList.count - self.readList.count
                        var z = 0
                        while(z<different){
                            self.readList.insert(false, at: 0)
                            z += 1
                        }
                        self.defaults.set(self.readList, forKey: "read")
                        self.defaults.synchronize()
                    }
                    
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }


    // Convert yyyy-mm-dd to Indonesian Date dd MMM yyyy
    func dateIndo(_ date:String) -> String {
        var splitDate = date.components(separatedBy: "-")
        switch splitDate[1]{
        case "01":
            splitDate[1] = "Januari"
        case "02":
            splitDate[1] = "Februari"
        case "03":
            splitDate[1] = "Maret"
        case "04":
            splitDate[1] = "April"
        case "05":
            splitDate[1] = "Mei"
        case "06":
            splitDate[1] = "Juni"
        case "07":
            splitDate[1] = "Juli"
        case "08":
            splitDate[1] = "Agustus"
        case "09":
            splitDate[1] = "September"
        case "10":
            splitDate[1] = "Oktober"
        case "11":
            splitDate[1] = "November"
        case "12":
            splitDate[1] = "Desember"
        default:
            print()
        }
        return "\(splitDate[2]) \(splitDate[1]) \(splitDate[0])"
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! InboxTableViewCell
        
        //configure cell
        cell.inboxSubjectLabel.text = inboxList[indexPath.row].inboxTitle
        cell.inboxDateLabel.text = inboxList[indexPath.row].inboxDate
        if !readList[indexPath.row]{
            cell.backgroundColor = UIColor(rgb: 0x00A4D7)
            cell.inboxSubjectLabel.textColor = UIColor.white
            cell.inboxDateLabel.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.clear
            cell.inboxSubjectLabel.textColor = UIColor.black
            cell.inboxDateLabel.textColor = UIColor(rgb: 0x115B80)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //retrieve from database
        return inboxList.count
    }
    
    // Cell is selected, set to detail view of message
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inboxTableView.deselectRow(at: indexPath, animated: true)
        if let cell = inboxTableView.cellForRow(at: indexPath){
            readList[indexPath.row] = true
            defaults.set(readList, forKey: "read")
            defaults.synchronize()
            performSegue(withIdentifier: "inboxDetailSegue", sender: cell)
        }else {
            // Error indexPath is not on screen: this should never happen.
        }

    }
    

    // MARK: - Navigation
    @IBAction func unwindToInbox (Segue: UIStoryboardSegue) {
        inboxTableView.reloadData()
    }

    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "openInboxSegue"{
            if (Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }
        }
        return true
    }

    // Set up data to be passed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inboxDetailSegue" {
            if let indexPath = self.inboxTableView.indexPath(for: sender as! UITableViewCell) {
                let nextVC: InboxDetailViewController = segue.destination as! InboxDetailViewController
                nextVC.subjectPassed = inboxList[indexPath.row].inboxTitle
                nextVC.datePassed = inboxList[indexPath.row].inboxDate
                nextVC.contentPassed = inboxList[indexPath.row].inboxBody
            }

        }
    }
    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: titles, style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }

    
}
