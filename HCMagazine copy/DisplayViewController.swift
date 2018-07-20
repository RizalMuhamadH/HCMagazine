//
//  DisplayViewController.swift
//  HCMagazine
//
//  News feed page with drawer menu(from Reveal View Controller Scene) , headline, articles categorized per rubric and sticky button with floaty framework (Display Center Scene)
//  3rd party plugin: Github by kciter/Floaty, Github by John-Lluch/SWRevealViewController
//
//  Created by ayobandung on 6/7/17.
//  Last modified on 11/17/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

var trackIdList:[Int] = []
var trackList:[Bool] = []

class DisplayViewController: UIViewController, FloatyDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var drawer_button: UIBarButtonItem!
    @IBOutlet weak var feedTableView: UITableView!
    
    //MARK: - Variables
    var loadmore = false
    var floaty = Floaty()
    var currentEd = 0
    var image_cache:UIImage? = UIImage(contentsOfFile:"")
    var images_cache = [String:UIImage]()
    var images = [String]()
    //news titles list
    var titles = [String]()
    //news list
    var sections:[[News]] = []
    //headlines
    var headNews:[News] = []
    var headImg = ""
    //rubric title
    var sectionsTitle:[String] = []
    //rubric short summary
    var sectionsSummary:[String] = []
    //section as previous edition
    var sectionPrevious = 0
    
    // Background thread
    var spinner: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let newsURL = "http://mobs.ayobandung.com/index.php/news_controller/getAllNewsHeadline"
    let prevURL = "http://mobs.ayobandung.com/index.php/news_controller/getAllNews"
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawer_button.target = self.revealViewController()
        drawer_button.action = #selector(SWRevealViewController.revealToggle(_:))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinner.color =  UIColor.init(red: 17, green: 91, blue: 128)
        spinner.hidesWhenStopped = true
        feedTableView.backgroundView = spinner
        
        // Set table footer eliminates empty cells
        self.feedTableView.tableFooterView = UIView()
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        //Floating Button
        floaty.buttonImage = UIImage(named: "main_icon")
        floaty.buttonColor = UIColor.init(red: 17, green: 91, blue: 128)
        layoutFAB()
        
        currentEd = defaults.integer(forKey: "currentEd")
        
        feedTableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        // get news list all rubric
        getData(newsURL,currentEd)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check existed user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        loadmore = false
        image_cache = UIImage(contentsOfFile:"")
        images_cache = [String:UIImage]()
        images = [String]()
        titles = [String]()
        sections = []
        headNews = []
        sectionsTitle = []
        sectionsSummary = []
        sectionPrevious = 0
        
        //headline
        sections.append(self.headNews)
        sectionsTitle.append("Headline")
        sectionsSummary.append("")

        getData(newsURL,currentEd)
        if (sections.count == 1) { // check if only headline spot
            feedTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()

            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 3)
                OperationQueue.main.addOperation() {
                    self.feedTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.feedTableView.reloadData()
                }
            }
        }
        
    }
    
    func layoutFAB() {
        floaty.hasShadow = false
        floaty.addItem("Previous Edition", icon: UIImage(named: "jump_icon")){ item in
            if self.currentEd != 1{
                self.feedTableView.scrollToBottom(animated: true)
                self.spinner.startAnimating()
                if !self.loadmore{
                    self.loadMore()
                    self.loadmore = true
                }else{
                    //scroll to header previous edition
                    let indexPath = IndexPath.init(row: 0, section: self.sectionPrevious)
                    self.feedTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    self.spinner.stopAnimating()
                }
            }else{
                let alert = UIAlertController(title: "Info", message: "Hanya tersedia edisi 1", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.floaty.close()
        }
        floaty.addItem("Back to top", icon: UIImage(named: "top_icon")) { item in
            //scroll to top
            let indexPath = IndexPath.init(row: 0, section: 0)
            self.feedTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            self.floaty.close()
        }
        floaty.paddingX = UIScreen.main.bounds.maxX/11 - floaty.frame.width/2
        floaty.fabDelegate = self
        floaty.sticky = true
        
        self.view.addSubview(floaty)
        
    }
    
    func floatyOpened(_ floaty: Floaty) {
        print("Floaty Opened")
    }
    
    func floatyClosed(_ floaty: Floaty) {
        print("Floaty Closed")
    }
    
    func loadMore(){
        DispatchQueue.global(qos: .background).async{
            let prevEd = self.currentEd-1
            self.getData(self.prevURL, prevEd )
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                self.spinner.stopAnimating()
                self.feedTableView.reloadData()
                self.refreshControl.endRefreshing()
                //scroll to header previous edition
                let indexPath = IndexPath.init(row: 0, section: self.sectionPrevious)
                self.feedTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (sections.count == 0) {
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
    
    func getData(_ link:String,_ edNum:Int) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        let params = "edition_id=\(edNum)"
        
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
                    if (!self.loadmore) && (self.sections.count == 0){
                        //add headline array
                        self.sections.append(self.headNews)
                        self.sectionsTitle.append("Headline")
                        self.sectionsSummary.append("")
                    }
                    while (i<newsData.count){
                        let imglink = "http://mobs.ayobandung.com/images-data/naskah/\(newsData[i]["edition_id"].stringValue)/\(newsData[i]["news_thumb"].stringValue)"
                        var newNews = News(newsId: newsData[i]["news_id"].intValue, newsTitle: newsData[i]["news_title"].stringValue, newsSummary:newsData[i]["news_summary"].stringValue, newsContent:newsData[i]["news_content"].stringValue, newsGimmick:newsData[i]["gimmick"].stringValue, rubricId:newsData[i]["rubric_id"].intValue, rubricTitle: newsData[i]["rubric_title"].stringValue, rubricSummary: newsData[i]["rubric_summary"].stringValue, editionId:newsData[i]["edition_id"].intValue, newsThumb: imglink, newsLiked: newsData[i]["counter"].intValue, newsHits: newsData[i]["hits"].intValue, newsComment: newsData[i]["comment"].intValue)
                        if newsData[i]["headline"].stringValue == "1"{
                            self.headImg = "http://mobs.ayobandung.com/images-data/naskah/\(newNews.editionId)/\(newsData[i]["news_photo"].stringValue)"
                            self.headNews.append(newNews)
                            self.sections[0] = self.headNews
                        }
                        self.images.append(imglink)
                        if !self.loadmore{
                            self.sectionPrevious = self.sections.count+1
                        }
                        // different edition
                        let prevEdition = self.currentEd-1
                        if newNews.editionId != self.currentEd{
                            // same news title, avoid using same pictures
                            if newNews.rubricId == 1{
                                newNews.newsTitle = "Edisi-\(prevEdition) \(newNews.rubricTitle)"
                            }
                            // different rubric, make new section, add it to array sections
                            if self.sectionsTitle[self.sectionsTitle.count-1] != "Edisi-\(prevEdition) \(newNews.rubricTitle)"{
                                self.sectionsTitle.append("Edisi-\(prevEdition) \(newNews.rubricTitle)")
                                self.sectionsSummary.append(newNews.rubricSummary)
                                let newSection = [newNews]
                                self.sections.append(newSection)
                            }else{
                                // same rubric, simply add to last section of array sections
                                self.sections[self.sections.count-1].append(newNews)
                            }
                        }else{ // same edition
                            // different rubric, make new section, add it to array sections
                            if self.sectionsTitle[self.sectionsTitle.count-1] != newNews.rubricTitle{
                                self.sectionsTitle.append(newNews.rubricTitle)
                                self.sectionsSummary.append(newNews.rubricSummary)
                                let newSection = [newNews]
                                self.sections.append(newSection)
                            }else{
                                // same rubric, simply add to last section of array sections
                                self.sections[self.sections.count-1].append(newNews)
                            }
                        }
                        self.titles.append(newNews.newsTitle)
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
    
    // Asynchronously download image and set to collection view
    func load_headline(_ link:String, imageview:UIImageView)
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
                }
                DispatchQueue.main.async(execute: set_image)
            }
        })
        task.resume()
    }

    
    
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section==0 && indexPath.row == 0){return 225.0}else{return 132.0}
    }
    
    // Deprectaed : without rubric's summary
    /*func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let title = UILabel()
        title.font = UIFont(name:"Roboto-Bold", size: 16)
        title.textColor = UIColor.init(red: 17, green: 91, blue: 128)
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.textLabel?.text = sectionTitle[section]
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }*/
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        //Empty summary
        if(sectionsSummary[section]==""){
            return 22
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let view = UIView()
        view.backgroundColor = UIColor.clear
        if(sectionsSummary[section]==""){
            //Empty summary
            let titleLabel = UILabel()
            titleLabel.text = sectionsTitle[section]
            titleLabel.font = UIFont(name:"Roboto-Bold", size: 16)
            titleLabel.textColor = UIColor.init(red: 17, green: 91, blue: 128)
            titleLabel.frame = CGRect(x: 5, y: 0, width: UIScreen.main.bounds.width-5, height: 20)
            view.addSubview(titleLabel)
        }else{
            //Set up rubric's title
            let titleLabel = UILabel()
            titleLabel.text = sectionsTitle[section]
            titleLabel.font = UIFont(name:"Roboto-Bold", size: 16)
            titleLabel.textColor = UIColor.init(red: 17, green: 91, blue: 128)
            titleLabel.frame = CGRect(x: 5, y: 0, width: UIScreen.main.bounds.width-5, height: 20)
            view.addSubview(titleLabel)
            
            //Set up rubric's summary
            let subtitleLabel = UILabel()
            subtitleLabel.text = sectionsSummary[section]
            subtitleLabel.font = UIFont(name:"Roboto-Regular", size: 12)
            subtitleLabel.textColor = UIColor.init(red: 17, green: 91, blue: 128)
            subtitleLabel.frame = CGRect(x: 5, y: 21, width: UIScreen.main.bounds.width-5, height: 15)
            view.addSubview(subtitleLabel)
        }

        return view
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section==0 && indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeadlineCell", for: indexPath) as! HeadlineCell
            
            // Configure the cell...
            let getNews = headNews[0]
            cell.headlineTitle.text = getNews.newsTitle
            cell.counter.text = "\(getNews.newsLiked)"
            cell.readCounter.text = "\(getNews.newsHits)"
            cell.commentCounter.text = "\(getNews.newsComment)"
            if(self.image_cache != nil){
                cell.headlineCover.image = self.image_cache
            }else{
                self.load_headline(headImg, imageview:  cell.headlineCover)
            }
            
            //Change background color
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.init(red: 234, green: 192, blue: 68)
            cell.selectedBackgroundView = bgColorView
            
            return cell

        }else{
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RubricCell

            // Configure the cell...
            let getNews = sections[indexPath.section][indexPath.row]
            cell.articleTitle.text = getNews.newsTitle
            cell.summary.text = getNews.newsSummary
            cell.rubricTitle.text = getNews.rubricTitle
            cell.counter.text = "\(getNews.newsLiked)"
            cell.readCounter.text = "\(getNews.newsHits)"
            cell.commentCounter.text = "\(getNews.newsComment)"
            
            let indexSearch = titles.index(of: getNews.newsTitle)
        
            if (images_cache[images[indexSearch!]] != nil){
                cell.articleThumb.image = images_cache[images[indexSearch!]]
            }else{
                load_image(images[indexSearch!], imageview:cell.articleThumb)
            }
            
            //Change background color
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.init(red: 234, green: 192, blue: 68)
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
        
    }
    
    // Cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedTableView.deselectRow(at: indexPath, animated: true)
        if let cell = feedTableView.cellForRow(at: indexPath){
            
              if (indexPath.section==0 && indexPath.row == 0){
                performSegue(withIdentifier: "OpenHeadlineSegue", sender: cell)
              }else{
                performSegue(withIdentifier: "OpenArticleSegue", sender: cell)
            }
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
            // load more if it hasn't been done
            if !self.loadmore{
                self.refreshControl.beginRefreshing()
                self.loadMore()
                self.loadmore = true
            }
        }
    }
    
    // MARK : - Navigation
    
    @IBAction func unwindToFeed (Segue: UIStoryboardSegue) {
        
    }
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "OpenArticleSegue") || (identifier == "OpenHeadlineSegue"){
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
                articleVC.content = sections[indexPath.section][indexPath.row].newsContent
                articleVC.gimmick = sections[indexPath.section][indexPath.row].newsGimmick
                articleVC.rubTitle = sections[indexPath.section][indexPath.row].rubricTitle
                articleVC.id = sections[indexPath.section][indexPath.row].newsId
                articleVC.rubId = sections[indexPath.section][indexPath.row].rubricId
                articleVC.totalLikes = sections[indexPath.section][indexPath.row].newsLiked
                articleVC.totalHits = sections[indexPath.section][indexPath.row].newsHits
                articleVC.totalComments = sections[indexPath.section][indexPath.row].newsComment
                articleVC.newsFeed = true
            }
            
        }else if segue.identifier == "OpenHeadlineSegue" {
            if let indexPath = self.feedTableView.indexPath(for: sender as! HeadlineCell) {
                let navVC = segue.destination as? UINavigationController
                let articleVC = navVC?.viewControllers.first as! ArticleViewController
                articleVC.content = sections[indexPath.section][indexPath.row].newsContent
                articleVC.gimmick = sections[indexPath.section][indexPath.row].newsGimmick
                articleVC.rubTitle = sections[indexPath.section][indexPath.row].rubricTitle
                articleVC.id = sections[indexPath.section][indexPath.row].newsId
                articleVC.rubId = sections[indexPath.section][indexPath.row].rubricId
                articleVC.totalLikes = sections[indexPath.section][indexPath.row].newsLiked
                articleVC.totalHits = sections[indexPath.section][indexPath.row].newsHits
                articleVC.totalComments = sections[indexPath.section][indexPath.row].newsComment
                articleVC.newsFeed = true
            }
            
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
