//
//  PhotoGalleryCollectionViewController.swift
//  HCMagazine
//
//  Page to display all photos from all editions or called Galeri Foto (Photo Gallery Scene
//
//  Created by ayobandung on 5/11/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class PhotoGalleryCollectionViewController: UICollectionViewController {

    // MARK: - Properties
    @IBOutlet var galleryView: UICollectionView!
    var galleryViewLayout: CustomImageFlowLayout!
    
    // MARK: - Variables
    let cellIdentifier = "PhotoCell"
    var images_cache = [String:UIImage]()
    var images = [String]()
    var photoList:[Photo] = []
    var passLink = ""
    var caption = ""
    var photoby = ""
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    // Background thread
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    let galleryURL = "http://mobs.ayobandung.com/index.php/photo_controller/getGallery"
    // var refreshControl:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        galleryView.backgroundView = activityIndicatorView
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 234, green: 192, blue: 68) yellow
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 17, green: 91, blue: 128) //dark blue
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        let drawer_button = UIBarButtonItem(image: UIImage(named: "drawer-button"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        drawer_button.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = drawer_button
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        galleryViewLayout = CustomImageFlowLayout()
        galleryView.collectionViewLayout = galleryViewLayout
        
        /* refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        galleryView.addSubview(refreshControl) // not required when using UITableViewController */
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        galleryView.dataSource = self
        galleryView.delegate = self
        
        getData(galleryURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Pull to refresh tableview
    func refresh(sender:AnyObject) {
        images_cache = [String:UIImage]()
        images = [String]()
        photoList = []
        
        getData(galleryURL)
        if (photoList.count == 0) {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.activityIndicatorView.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.galleryView.reloadData()
                }
            }
        }
        
    } */

    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (photoList.count == 0) {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 2)
                
                OperationQueue.main.addOperation() {
                    self.activityIndicatorView.stopAnimating()
                    self.galleryView.reloadData()
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
                    let photoData = json["data"].arrayValue
                    var i = 0
                    while (i<photoData.count){
                        let imgContent = "http://mobs.ayobandung.com/images-data/gallery/\(photoData[i]["edition_id"].stringValue)/\(photoData[i]["image_content"].stringValue)"
                        let newPhoto = Photo(photoId: photoData[i]["photo_id"].intValue, photoFile: imgContent , photoThumb: photoData[i]["image_thumb"].stringValue, photoCaption: photoData[i]["caption"].stringValue, photoCourtesy: photoData[i]["photo_by"].stringValue, editionId: photoData[i]["edition_id"].stringValue)
                        let imglink = "http://mobs.ayobandung.com/images-data/gallery_thumb/\(newPhoto.editionId)/\(newPhoto.photoThumb)"
                        self.images.append(imglink)
                        self.photoList.append(newPhoto)
                        i += 1
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


    
    // MARK: - Navigation
    @IBAction func unwindToGallery (Segue: UIStoryboardSegue) {
        
    }
    
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "openPhotoSegue"{
            if (Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }
            defaults.set(passLink, forKey: "url")
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openPhotoSegue" {
            if let indexPath = self.collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                let nextVC: PhotoDetailViewController = segue.destination as! PhotoDetailViewController
                nextVC.imgURL = photoList[indexPath.row].photoFile
                nextVC.caption = photoList[indexPath.row].photoCaption
                nextVC.photoby = photoList[indexPath.row].photoCourtesy
                nextVC.edition = photoList[indexPath.row].editionId
            }
        }
    }

 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // Configure the cell
        if (images_cache[images[indexPath.row]] != nil){
            cell.photo_thumb.image = images_cache[images[indexPath.row]]
        }else{
            load_image(images[indexPath.row], imageview:cell.photo_thumb)
        }
    
        return cell
    }

    // Add action when user tap an edition
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            passLink = photoList[indexPath.row].photoFile
            performSegue(withIdentifier: "openPhotoSegue", sender: cell)
        } else {
            // Error indexPath is not on screen: this should never happen.
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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

}
