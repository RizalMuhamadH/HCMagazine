//
//  RubricTVC.swift
//  HCMagazine
//
//  UITableView that display articles of all rubrics from one edition (Rubric Library Scene) that opens from Direktori Edisi (Library Scene)
//
//  Created by ayobandung on 6/8/17.
//  Last modified on 10/30/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//
import SideMenu
import UIKit

class RubricTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    @IBOutlet weak var feedTableView: UITableView!
    
    //MARK: - Variables
    var edNum = 0
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
    
    // Background thread
    var spinner: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let newsURL = "http://mobs.ayobandung.com/index.php/news_controller/getAllNews"
    var refreshControl:UIRefreshControl = UIRefreshControl()

    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "NavDrawerEdisiVC") as! UISideMenuNavigationController
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController

        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinner.color =  UIColor.init(red: 17, green: 91, blue: 128)
        feedTableView.backgroundView = spinner
        
        // Set table footer eliminates empty cells
        self.feedTableView.tableFooterView = UIView()
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        feedTableView.addSubview(refreshControl) // not required when using UITableViewController

        edNum = defaults.integer(forKey: "edNum")
        self.title = "Edisi \(edNum)"
        
        getData(newsURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        images_cache = [String:UIImage]()
        images = [String]()
        titles = [String]()
        sections = []
        headNews = []
        sectionsTitle = []
        sectionsSummary = []
        
        getData(newsURL)
        if (sections.count == 0) {
            feedTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.feedTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.feedTableView.reloadData()
                }
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
    
    func getData(_ link:String) {
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
                    while (i<newsData.count){
                        let imglink = "http://mobs.ayobandung.com/images-data/naskah/\(newsData[i]["edition_id"].stringValue)/\(newsData[i]["news_thumb"].stringValue)"
                        let newNews = News(newsId: newsData[i]["news_id"].intValue, newsTitle: newsData[i]["news_title"].stringValue, newsSummary:newsData[i]["news_summary"].stringValue, newsContent:newsData[i]["news_content"].stringValue, newsGimmick:newsData[i]["gimmick"].stringValue, rubricId:newsData[i]["rubric_id"].intValue, rubricTitle: newsData[i]["rubric_title"].stringValue, rubricSummary: newsData[i]["rubric_summary"].stringValue, editionId:newsData[i] ["edition_id"].intValue, newsThumb: imglink, newsLiked: newsData[i]["counter"].intValue, newsHits: newsData[i] ["hits"].intValue, newsComment: newsData[i] ["comment"].intValue)
                        self.images.append(imglink)
                        self.titles.append(newNews.newsTitle)
                        // check empty array
                        if self.sectionsTitle.count == 0{
                            // make new section, add it to array sections
                            self.sectionsTitle.append(newNews.rubricTitle)
                            self.sectionsSummary.append(newNews.rubricSummary)
                            let newSection = [newNews]
                            self.sections.append(newSection)
                        }else if self.sectionsTitle[self.sectionsTitle.count-1] != newNews.rubricTitle{
                            // different rubric, make new section, add it to array sections
                            self.sectionsTitle.append(newNews.rubricTitle)
                            self.sectionsSummary.append(newNews.rubricSummary)
                            let newSection = [newNews]
                            self.sections.append(newSection)
                        }else{
                            // same rubric, simply add to last section of array sections
                            self.sections[self.sections.count-1].append(newNews)
                        }
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
    
    // Deprectaed : without rubric's summary
    /*
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
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
    } */
    
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
 
    @IBAction func unwindToRubricLibrary (Segue: UIStoryboardSegue) {
 
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
                articleVC.content = sections[indexPath.section][indexPath.row].newsContent
                articleVC.gimmick = sections[indexPath.section][indexPath.row].newsGimmick
                articleVC.rubTitle = sections[indexPath.section][indexPath.row].rubricTitle
                articleVC.rubId = sections[indexPath.section][indexPath.row].rubricId
                articleVC.totalLikes = sections[indexPath.section][indexPath.row].newsLiked
                articleVC.totalHits = sections[indexPath.section][indexPath.row].newsHits
                articleVC.totalComments = sections[indexPath.section][indexPath.row].newsComment
                articleVC.id = sections[indexPath.section][indexPath.row].newsId
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
