//
//  FrontCoverViewController.swift
//  HCMagazine
//
//  Page to display newest image cover edition as button and options to go to user profile page and inbox/message/announcement Pengumuman Page (bjb HC News Scene)
//
//  Created by ayobandung on 6/7/17.
//  Last Modified on 8/28/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class FrontCoverViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var cover: UIImageView!
    
    //MARK: - Variables
    var edNum = 0
    var image_cache:UIImage? = UIImage(contentsOfFile:"")
    var stop = false
    // Background thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let editionURL = "http://mobs.ayobandung.com/index.php/edition_controller/getEdition"
    var refreshControl:UIRefreshControl = UIRefreshControl()
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let changepwd = defaults.string(forKey: "changepass")!
        if(changepwd == "yes"){
            alertPop("Info", "Mohon melakukan perubahan kata sandi anda segera")
        }
        let counter = checkUnread()
        
        if counter>0 || checkNotif() {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "mail_notif"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.addTarget(self, action: #selector(openInbox), for: .touchUpInside)
            let item = UIBarButtonItem(customView: button)
            self.navigationItem.setRightBarButtonItems([item], animated: true)
        }
        
        getData(editionURL)
        
        DataProgressed.instance.getData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openInbox(){
        self.performSegue(withIdentifier: "openInboxSegue", sender: nil)
        defaults.removeObject(forKey: "unread")
    }
    
    // Check existed user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func checkNotif() -> Bool{
        var notif = false
        if isKeyPresentInUserDefaults(key: "unread"){
            notif = defaults.bool(forKey: "unread")
        }
        return notif
    }
    
    // Check unread message from user defaults
    func checkUnread() -> Int{
        var unread = 0
        if isKeyPresentInUserDefaults(key: "read"){
            let msgList = defaults.array(forKey: "read") as? [Bool] ?? [Bool]()
            var i = 0
            while (i<msgList.count) {
                if (msgList[i] == false){
                    unread += 1
                }
                i += 1
            }
        }
        return unread
    }
    
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!stop) {
            spinner.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.spinner.stopAnimating()
                    
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
                self.alertPop("Error", "Gagal mengambil data")
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
                    let edition = json["data"].arrayValue
                    self.edNum = edition[0]["edition_id"].intValue
                    self.defaults.set(self.edNum, forKey: "currentEd")
                    let imgFileName = edition[0]["edition_image"].stringValue
                    let imglink = "http://mobs.ayobandung.com/images-data/cover/\(imgFileName)"
                    if(self.image_cache != nil){
                        self.cover.image = self.image_cache
                    }else{
                        self.load_image(imglink, imageview: self.cover)
                    }
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Error", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    
    // Asynchronously download image and set to collection view
    func load_image(_ link:String, imageview:UIImageView)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 10
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                return
            }
            var image = UIImage(data: data!)
            
            if (image != nil){
                
                func set_image(){
                    self.image_cache = image!
                    imageview.image = image
                    self.stop = true
                }
                DispatchQueue.main.async(execute: set_image)
            }
        })
        task.resume()
    }
    
    
    
    // MARK : - Navigation
    
    @IBAction func unwindToFrontCover (Segue: UIStoryboardSegue) {
        let counter = checkUnread()
        
        if counter>0{
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "mail_notif"), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.addTarget(self, action: #selector(openInbox), for: .touchUpInside)
            let item = UIBarButtonItem(customView: button)
            self.navigationItem.setRightBarButtonItems([item], animated: true)
        }else{
            let button = UIBarButtonItem(image: UIImage(named: "inbox_icon"), style: .plain, target: self, action:#selector(openInbox))
            self.navigationItem.rightBarButtonItem  = button
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
    }
    
    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }
}
