//
//  PhotoDetailViewController.swift
//  HCMagazine
//
//  Page to display a photo along with all information that user’s choose (Photo Detail Scene)
//  3rd party plugin: huynguyencong/ImageScrollView
//
//  Created by ayobandung on 5/12/17.
//  Last modified on 10/10/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController{

    // MARK: - Properties
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var courtesyLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var edLabel: UILabel!
    @IBOutlet weak var imageScrollView: ImageScrollView!

    
    // MARK: - Variables
    var imgURL = ""
    var caption = ""
    var photoby = ""
    var edition = ""
    // Background thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 234, green: 192, blue: 68)
        navigationController?.navigationBar.titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        
        courtesyLabel.text = photoby
        captionLabel.text = caption
        edLabel.text = "Edisi \(edition)"
        load_image(imgURL,imageview: imageScrollView)
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // Asynchronously download image and set to collection view
    func load_image(_ link:String, imageview:ImageScrollView)
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
                    imageview.display(image: image!)
                    self.spinner.stopAnimating()
                }
                DispatchQueue.main.async(execute: set_image)
            }
        })
        task.resume()
    }
}
