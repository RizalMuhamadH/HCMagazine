//
//  ArticleViewController.swift
//  HCMagazine
//
//  Page to display an article with CSS setup and like/dislike feature (Article Scene)
//
//  Created by ayobandung on 4/25/17.
//  Last modified on 10/30/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import Foundation

class ArticleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    // MARK: - Properties
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var relatedCollection: UICollectionView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var likeArticleButton: UIButton!
    @IBOutlet weak var hitsLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    // MARK: - Variables
    let cellIdentifier = "RelatedCell"
    var newsList :[News] = []
    var likeButton = 0
    var rootFeed = false
    var newsFeed = false
    var article = false
    var id = 0
    var content = ""
    var gimmick = ""
    var rubTitle = ""
    var rubId = 0
    var totalLikes = 0
    var totalHits = 0
    var totalComments = 0
    var images_cache = [String:UIImage]()
    var images = [String]()
    var getHTML:String = ""
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var refreshControl2:UIRefreshControl = UIRefreshControl()
    let recentURL = "http://mobs.ayobandung.com/index.php/news_controller/getRelated"
    let likeURL = "http://mobs.ayobandung.com/index.php/liked_controller/getLiked"
    let insertURL = "http://mobs.ayobandung.com/index.php/liked_controller/insertLiked"
    let removeURL = "http://mobs.ayobandung.com/index.php/liked_controller/removeLiked"
    let hitsURL = "http://mobs.ayobandung.com/index.php/news_controller/insertHits"
    let addCommentURL = "http://mobs.ayobandung.com/index.php/comment_controller/addComment"
    // Access UserDefaults
    let defaults = UserDefaults.standard
    var username = ""
    var contentSend = ""
    var hasShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up page
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 234, green: 192, blue: 68) yellow
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        // Set comment, hits, likes counter
        hitsLabel.text = "\(totalHits+1)"
        commentLabel.text = "\(totalComments) orang berkomentar"
        likesLabel.text = "\(totalLikes) orang menyukai"
        
        commentField.layer.borderColor = (UIColor(rgb: 0xEAC044)).cgColor
        commentField.layer.borderWidth = 1.0
        commentField.layer.cornerRadius = 8
        
        // Register the collection view cell class and its reuse id
        relatedCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the collection view
        relatedCollection.dataSource = self
        relatedCollection.delegate = self
        
        webView.scrollView.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        webView.scrollView.addSubview(refreshControl) // not required when using UITableViewController
        
        refreshControl2 = UIRefreshControl()
        refreshControl2.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl2.tintColor = UIColor(rgb: 0x115B80)
        refreshControl2.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl2.addTarget(self, action:  #selector(self.refreshTable), for: UIControlEvents.valueChanged)
        relatedCollection.addSubview(refreshControl2) // not required when using UITableViewController
        
        self.title = rubTitle
        username = defaults.string(forKey: "usr")!
        
        // Update tracker read
        DataProgressed.instance.updateNewsTracker(cid: id)
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ArticleViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
                
        getData(recentURL, mode: 1)
        getData(likeURL,mode: 2)
        getData(hitsURL,mode: 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //Detects if text field is empty
    func validate(textField: UITextField) -> Bool {
        guard let text = textField.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
    }
    
    // save state like dislike
    @IBAction func likeUnlike(_ sender: UIButton) {
        
        if likeButton == 0 {
            likeButton = 1
            likeArticleButton.setImage(UIImage(named: "like_article"), for: .normal)
            likeArticleButton.setTitleColor(UIColor.init(red: 17, green: 91, blue: 128), for: .normal)
            totalLikes += 1
            likesLabel.text = "\(totalLikes) orang menyukai"
            dispatchQueue.async{
                self.insertDelete(self.insertURL)
            }
            
        }  else {
            likeArticleButton.setImage(UIImage(named: "unlike_article"), for: .normal)
            likeArticleButton.setTitleColor(UIColor(rgb: 0xAAAAAA), for: .normal)
            likeButton = 0
            if totalLikes > 0 {
                totalLikes -= 1
            }
            likesLabel.text = "\(totalLikes) orang menyukai"
            dispatchQueue.async{
                self.insertDelete(self.removeURL)
            }
        }
    }
    
    @IBAction func addComment(_ sender: Any) {
        if validate(textField: commentField){
            let commentText = commentField.text
            let convertEmoji = (commentText?.emojiEscapedString)!
            contentSend = convertEmoji
            commentField.text = ""
            totalComments += 1
            commentLabel.text = "\(totalComments) orang berkomentar"
            getData(addCommentURL, mode: 3)
        }
    }
    
    //Pull to refresh tableview
    func refreshTable(sender:AnyObject) {
        images_cache = [String:UIImage]()
        images = [String]()
        newsList = []
        getData(recentURL,mode: 1)
        if (newsList.count == 0) {
          spinner.startAnimating()
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.refreshControl2.endRefreshing()
                    self.spinner.stopAnimating()
                    self.relatedCollection.reloadData()
                }
            }
        }
        
    }
    
    //Pull to refresh webview
    func refresh(sender:AnyObject) {
        webView.loadHTMLString(self.initHTML(self.content), baseURL:nil)
        refreshControl.endRefreshing()
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        if rootFeed{
            self.performSegue(withIdentifier: "BackRubricFeedSegue", sender: self)
        }else if newsFeed{
            self.performSegue(withIdentifier: "BackFeedSegue", sender: self)
        }else if newsFeed{
            self.performSegue(withIdentifier: "BackArticleSegue", sender: self)
        }else{
            self.performSegue(withIdentifier: "BackRubricLibrarySegue", sender: self)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (getHTML == "" && newsList.count==0) {
            spinner.startAnimating()
            self.webView.loadHTMLString(self.initHTML(self.content), baseURL:nil)
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 5)
                OperationQueue.main.addOperation() {
                    if self.likeButton==1{
                        self.likeArticleButton.setImage(UIImage(named: "like_article"), for: .normal)
                        self.likeArticleButton.setTitleColor(UIColor.init(red: 17, green: 91, blue: 128), for: .normal)
                    }else{
                        self.likeArticleButton.setImage(UIImage(named: "unlike_article"), for: .normal)
                        self.likeArticleButton.setTitleColor(UIColor(rgb: 0xAAAAAA), for: .normal)
                    }
                    self.relatedCollection.reloadData()
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
    func getData(_ link:String,mode:Int) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        var params = "username=\(username)&news_id=\(id)"
        if mode==1{
            params = "rubric_id=\(rubId)&news_id=\(id)"
        }else if mode==3{
            params = "news_id=\(id)&username=\(username)&comment=\(contentSend)"
        }
        
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
                if mode==3{
                    
                }else if mode != 1{
                    if(state=="success"){
                        self.likeButton = json["existed"].intValue
                    }else{
                        print("Can't get like state")
                    }
                }else{
                    if(state=="success"){
                        let newsData = json["data"].arrayValue
                        var i = 0
                        while (i<newsData.count){
                            let imglink = "http://mobs.ayobandung.com/images-data/naskah/\(newsData[i]["edition_id"].stringValue)/\(newsData[i]["news_thumb"].stringValue)"
                            let newNews = News(newsId: newsData[i]["news_id"].intValue, newsTitle: newsData[i]["news_title"].stringValue, newsSummary:newsData[i]["news_summary"].stringValue, newsContent:newsData[i]["news_content"].stringValue, newsGimmick:newsData[i]["gimmick"].stringValue, rubricId:newsData[i]["rubric_id"].intValue, rubricTitle: newsData[i]["rubric_title"].stringValue, rubricSummary: newsData[i]["rubric_summary"].stringValue, editionId:newsData[i]["edition_id"].intValue, newsThumb: imglink, newsLiked: newsData[i]["counter"].intValue, newsHits: newsData[i]["hits"].intValue, newsComment: newsData[i]["comment"].intValue)
                            self.images.append(imglink)
                            self.newsList.append(newNews)
                            i += 1
                        }
                    }else{
                        print("Can't get related articles")
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

    //insertion/deletion like from database
    func insertDelete(_ link:String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        let params = "username=\(username)&news_id=\(id)"
        
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
                let state2 = json["status"].stringValue
                print("The state is: \(state2)")
                if(state2=="success"){
                    // do nothing
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
    
    // MARK: - Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return newsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! RelatedNewsColCell

        // Configure the cell...
        let getNews = newsList[indexPath.row]
        cell.relatedTitle.text = getNews.newsTitle
        cell.likesCounter.text = "\(getNews.newsLiked)"
        cell.readCounter.text = "\(getNews.newsHits)"
        cell.commentCounter.text = "\(getNews.newsComment)"
        
        if (images_cache[images[indexPath.row]] != nil){
            cell.relatedImg.image = images_cache[images[indexPath.row]]
        }else{
            load_image(images[indexPath.row], imageview:cell.relatedImg)
        }
        
        return cell
    }
    
    
    // Add action when user tap an edition
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            performSegue(withIdentifier: "OpenArticleSegue", sender: cell)
        } else {
            // Error indexPath is not on screen: this should never happen.
        }
    }
    
    // MARK: - Scroll View
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            checkHasScrolledToBottom(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkHasScrolledToBottom(scrollView)
    }
    
    func checkHasScrolledToBottom(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            // we are at the end
            // Request comment
             if gimmick != "" && !hasShown{
                alertGimmick()
             }
        }
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
    
    // MARK: - Navigation
    @IBAction func unwindToArticle (Segue: UIStoryboardSegue) {
        
    }
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "OpenArticleSegue" || identifier == "OpenCommentSegue"{
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
            if let indexPath = self.relatedCollection.indexPath(for: sender as! RelatedNewsColCell) {
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
                articleVC.article = true
            }
        }else if segue.identifier == "OpenCommentSegue" {
            let navVC = segue.destination as? UINavigationController
            let commentVC = navVC?.viewControllers.first as! CommentVC
            commentVC.newsId = id
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

    func alertGimmick() {
        let Alert = UIAlertController(title: "Bagaimana Menurut Anda?", message: gimmick, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "Berikan Tanggapan", style: .cancel, handler: { action in
            self.hasShown = true
            self.commentField.becomeFirstResponder()
        }))
        self.present(Alert, animated: true, completion: nil)
    }
}
