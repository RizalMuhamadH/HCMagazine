//
//  LibraryCollectionViewController.swift
//  HCMagazine
//
//  Page to display all editions or called Direktori Edisi page (Library Scene) and prepared menu list
//
//  Created by ayobandung on 4/19/17.
//  Last modified on 10/20/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

//Prepare rubric list and id
var rubricList = ["Direktori Edisi","News Feed"]
var rubricIdList = [0,0]

class LibraryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    var LibraryViewLayout: LibraryGridFlowLayout!
    
    // MARK: - Variables
    let cellIdentifier = "LibraryCell"
    var editionNum = 0;
    var images_cache = [String:UIImage]()
    var images = [String]()
    var editionList:[Edition] = []
    var username = ""
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    // Background thread
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let editionURL = "http://mobs.ayobandung.com/index.php/edition_controller/getAllEditionRubric"
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LibraryViewLayout = LibraryGridFlowLayout()
        collectionView.collectionViewLayout = LibraryViewLayout
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        collectionView.backgroundView = activityIndicatorView
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        let drawer_button = UIBarButtonItem(image: UIImage(named: "drawer-button"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        drawer_button.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = drawer_button
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl) // not required when using UITableViewController

        // Register the collection view cell class and its reuse id
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        getData(editionURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        images_cache = [String:UIImage]()
        images = [String]()
        editionList = []
        
        getData(editionURL)
        if (editionList.count == 0) {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
        
    }

    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (editionList.count == 0) {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.activityIndicatorView.stopAnimating()
                    self.collectionView.reloadData()
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
                    let editionData = json["data"].arrayValue
                    var i = 0
                    while (i<editionData.count){
                        let newEdition = Edition(editionId: editionData[i]["edition_id"].stringValue, imgFileName: editionData[i]["edition_image"].stringValue, editionDate: self.dateIndo(editionData[i]["edition_date"].stringValue))
                        let imglink = "http://mobs.ayobandung.com/images-data/cover/\(newEdition.imgFileName)"
                        self.images.append(imglink)
                        self.editionList.append(newEdition)
                        i += 1
                    }
                    // get rubric list for next menu
                    let rubricData = json["rubric"]["data"].arrayValue
                    if rubricList.count != (rubricData.count+2){
                        i = 0
                        while (i<rubricData.count){
                            rubricList.append(rubricData[i]["rubric_title"].stringValue)
                            rubricIdList.append(rubricData[i]["rubric_id"].intValue)
                            i += 1
                        }
                        // prepare if there is new rubric but have no time to update in order to avoid crash by append last icon to new rubric
                        if iconMenu.count != rubricList.count{
                            var diff = rubricList.count-iconMenu.count
                            while diff > 0{
                                iconMenu.append(iconMenu[iconMenu.count-1])
                                diff -= 1
                            }
                        }
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
                splitDate[1] = "Jan"
            case "02":
                splitDate[1] = "Feb"
            case "03":
                splitDate[1] = "Mar"
            case "04":
                splitDate[1] = "Apr"
            case "05":
                splitDate[1] = "Mei"
            case "06":
                splitDate[1] = "Jun"
            case "07":
                splitDate[1] = "Jul"
            case "08":
                splitDate[1] = "Ags"
            case "09":
                splitDate[1] = "Sep"
            case "10":
                splitDate[1] = "Okt"
            case "11":
                splitDate[1] = "Nov"
            case "12":
                splitDate[1] = "Des"
            default:
                print()
        }
        return "\(splitDate[2]) \(splitDate[1]) \(splitDate[0])"
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
                    self.images_cache[link] = image
                    imageview.image = image
                }
                DispatchQueue.main.async(execute: set_image)
            }
        })
        task.resume()
    }
    
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! LibraryCollectionViewCell

        // Configure the cell
        if (images_cache[images[indexPath.row]] != nil){
            cell.editionCover.image = images_cache[images[indexPath.row]]
        }else{
            load_image(images[indexPath.row], imageview:cell.editionCover)
        }
        cell.editionNum.text = "Edisi " + editionList[indexPath.row].editionId
        cell.editionDate.text = editionList[indexPath.row].editionDate
        return cell
    }
    
   func numberOfSections(in collectionView: UICollectionView) -> Int {
        // return the number of sections
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of items (retrieve from database)
        return editionList.count
    }
    
    
    // Add action when user tap an edition
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            editionNum = indexPath.row+1
            performSegue(withIdentifier: "openEditionSegue", sender: cell)
        } else {
            // Error indexPath is not on screen: this should never happen.
        }
    }
    
    
    // MARK : - Navigation
    
    @IBAction func unwindToLibrary (Segue: UIStoryboardSegue) {
        
    }
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "openEditionSegue"{
            if (Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }
        }

        return true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openEditionSegue" {
            if let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                    defaults.set(indexPath.row+1, forKey: "edNum")
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

