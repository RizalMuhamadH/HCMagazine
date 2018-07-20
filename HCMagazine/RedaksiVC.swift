//
//  RedaksiVC.swift
//  HCMagazine
//
//  Display Susunan Redaksi HC News
//
//  Created by ayobandung on 04/12/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class RedaksiVC: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Variables
    var content = ""
    
    // Background thread
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let linkURL = "http://mobs.ayobandung.com/index.php/news_controller/getredaksihcnews"
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        let drawer_button = UIBarButtonItem(image: UIImage(named: "drawer-button"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        drawer_button.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = drawer_button
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        webView.scrollView.addSubview(refreshControl) // not required when using UITableViewController
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        getData()
        
    }

    //Pull to refresh
    func refresh(sender:AnyObject) {
        refreshControl.beginRefreshing()
        content = ""
        webView.loadHTMLString(content, baseURL:nil)
        webView.reload()
        getData()
        if (content == "") {
            spinner.startAnimating()
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.webView.loadHTMLString(self.initHTML(self.content), baseURL:nil)
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        
    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (content == "") {
            spinner.startAnimating()
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.webView.loadHTMLString(self.initHTML(self.content), baseURL:nil)
                    self.spinner.stopAnimating()
                }
            }
        }
    }
    
    //CSS Setup
    func initHTML(_ body:String)->String{
        var html = "<!DOCTYPE html><html>"
        html += "<head>"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "<link href=\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\" rel=\"stylesheet\">"
        html += "<style>"
        html += "body{font-family:'Roboto',sans-serif;font-size:100%;} p{text-align:justify;color:black;}p.quotes{font-weight:bold;color:#115B80;}p.title{font-weight:bold;color:#115B80;font-size:130%;margin-bottom:12px;text-align:left;}.caption{font-size:70%;color:#939598;text-align:justify;}div,img,embed{width:100%;}.bjb{font-weight:bold;color:#115B80;}"
        html += "</style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html;
    }
    
    // MARK - Connection to API
    
    //Get current like status
    func getData() {
        let url:URL = URL(string: linkURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
                if(state == "success"){
                    self.content = json["data"].stringValue
                }else{
                    print("Can't get content")
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
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
