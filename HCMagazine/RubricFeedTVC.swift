//
//  RubricFeedTVC.swift
//  HCMagazine
//
//  UITableView that display article of one rubric (Rubric Scene)
//
//  Created by ayobandung on 6/10/17.
//  Last modified on 10/30/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class RubricFeedTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    @IBOutlet weak var feedTableView: UITableView!
    
    //MARK: - Variables
    var edNum = 0
    var rubricId = 0
    var images_cache = [String:UIImage]()
    var images = [String]()
    var newsList:[News] = []
    
    // Background thread
    var spinner: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let rubricURL = "http://mobs.ayobandung.com/index.php/news_controller/getRubricNews"
    var refreshControl:UIRefreshControl = UIRefreshControl()
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinner.color =  UIColor.init(red: 17, green: 91, blue: 128)
        feedTableView.backgroundView = spinner
        
        // Set table footer eliminates empty cells
        self.feedTableView.tableFooterView = UIView()
        
        let drawer_button = UIBarButtonItem(image: UIImage(named: "drawer-button"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        drawer_button.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = drawer_button
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        let icon_button = UIBarButtonItem(image: UIImage(named: "logo_icon"), style: .plain, target: nil, action: nil)
        icon_button.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = icon_button
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        edNum = defaults.integer(forKey: "currentEd")
        
        getData(rubricURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        images_cache = [String:UIImage]()
        images = [String]()
        newsList = []
        getData(rubricURL)
        if (newsList.count == 0) {
            feedTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.feedTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.refreshControl.endRefreshing()
                    self.spinner.stopAnimating()
                    self.feedTableView.reloadData()
                }
            }
        }

    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (newsList.count == 0) {
            feedTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.feedTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.feedTableView.reloadData()
                }
            }
        }
    }
    
    
    // MARK - Connection to API
    
    func getData(_ link:String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        let params = "edition_id=\(edNum)&rubric_id=\(rubricId)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = params.data(using: String.Encoding.utf8)
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
                let newsData = json["data"].arrayValue
                var i = 0
                if(state=="success"){
                    while (i<newsData.count){
                        let imglink = "http://mobs.ayobandung.com/images-data/naskah/\(newsData[i]["edition_id"].stringValue)/\(newsData[i]["news_thumb"].stringValue)"
                        let newNews = News(newsId: newsData[i]["news_id"].intValue, newsTitle: newsData[i]["news_title"].stringValue, newsSummary:newsData[i]["news_summary"].stringValue, newsContent:newsData[i]["news_content"].stringValue, newsGimmick:newsData[i]["gimmick"].stringValue, rubricId:newsData[i]["rubric_id"].intValue, rubricTitle: newsData[i]["rubric_title"].stringValue, rubricSummary: newsData[i]["rubric_summary"].stringValue, editionId:newsData[i]["edition_id"].intValue, newsThumb: imglink, newsLiked: newsData[i]["counter"].intValue, newsHits: newsData[i] ["hits"].intValue, newsComment: newsData[i] ["comment"].intValue)
                        self.images.append(imglink)
                        self.newsList.append(newNews)
                        i += 1
                        
                    }
                    
                }else{
                    self.alertPop("Info", "Pull to Refresh")
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    // Asynchronously download image and set to table view
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
                    self.images_cache[link] = image
                    imageview.image = image
                }
                DispatchQueue.main.async(execute: set_image)
            }
        })
        task.resume()
    }
    
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RubricCell
        
        // Configure the cell...
        let getNews = newsList[indexPath.row]
        cell.articleTitle.text = getNews.newsTitle
        cell.summary.text = getNews.newsSummary
        cell.rubricTitle.text = getNews.rubricTitle
        cell.counter.text = "\(getNews.newsLiked)"
        cell.readCounter.text = "\(getNews.newsHits)"
        cell.commentCounter.text = "\(getNews.newsComment)"
        
        if (images_cache[images[indexPath.row]] != nil){
            cell.articleThumb.image = images_cache[images[indexPath.row]]
        }else{
            load_image(images[indexPath.row], imageview:cell.articleThumb)
        }
        
        //Change background color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 234, green: 192, blue: 68)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    // Cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedTableView.deselectRow(at: indexPath, animated: true)
        if let cell = feedTableView.cellForRow(at: indexPath){
            
            performSegue(withIdentifier: "OpenArticleSegue", sender: cell)
        }else {
            // Error indexPath is not on screen: this should never happen.
        }
    }
    
    // Add animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* only fade in
         cell.alpha = 0
         
         UIView.animate(withDuration: 1.0){
         cell.alpha = 1.0
         } */
        
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity,-250,20,0)
        cell.layer.transform = transform
        
        UIView.animate(withDuration: 1.0){
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    // MARK : - Navigation
    
    @IBAction func unwindToRubricFeed (Segue: UIStoryboardSegue) {
        
    }
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "OpenArticleSegue"{
            if (Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }
        }
        
        return true
    }
    
    // Set up data to be passed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenArticleSegue" {
            if let indexPath = self.feedTableView.indexPath(for: sender as! RubricCell) {
                let navVC = segue.destination as? UINavigationController
                let articleVC = navVC?.viewControllers.first as! ArticleViewController
                articleVC.content = newsList[indexPath.row].newsContent
                articleVC.gimmick = newsList[indexPath.row].newsGimmick
                articleVC.rubTitle = newsList[indexPath.row].rubricTitle
                articleVC.id = newsList[indexPath.row].newsId
                articleVC.rubId = newsList[indexPath.row].rubricId
                articleVC.totalLikes = newsList[indexPath.row].newsLiked
                articleVC.totalHits = newsList[indexPath.row].newsHits
                articleVC.totalComments = newsList[indexPath.row].newsComment
                articleVC.rootFeed = true
            }
            
        }
    }
    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.feedTableView.bounds.size.width, height: self.feedTableView.bounds.size.height))
            noDataLabel.text          = "Artikel Tidak Ditemukan"
            noDataLabel.font = UIFont(name:"Roboto-Bold", size: 16)
            noDataLabel.textColor = UIColor.init(red: 17, green: 91, blue: 128)
            noDataLabel.textAlignment = .center
            self.feedTableView.backgroundView  = noDataLabel
            self.feedTableView.separatorStyle  = .none
        }))
        self.present(Alert, animated: true, completion: nil)
    }

}
