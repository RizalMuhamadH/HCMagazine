//
//  UsersAccountVC.swift
//  HCMagazine
//
//  Menu to activate, deactivate, reset password and check state of user’s account (User’s Account Scene)
//
//  Created by ayobandung on 8/3/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class UsersAccountVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var emailStatus: UITextField!
    @IBOutlet weak var emailActivate: UITextField!
    @IBOutlet weak var emailChangePass: UITextField!
    @IBOutlet weak var passChangePass: UITextField!
    @IBOutlet weak var responseText: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var emailDeactivate: UITextField!

    // MARK: - Variables
    let checkURL = "http://mobs.ayobandung.com/index.php/admin_controller/checkAccount"
    let activeURL = "http://mobs.ayobandung.com/index.php/admin_controller/activateAccount"
    let changePassURL = "http://mobs.ayobandung.com/index.php/admin_controller/changeUserPassword"
    let deleteURL = "http://mobs.ayobandung.com/index.php/admin_controller/deleteAccount"
    // Background thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    var data = ""
    var msg = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UsersAccountVC.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        spinner.stopAnimating()
        spinner.isHidden = true
        
        UITabBar.appearance().tintColor = UIColor.white
        
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
    @IBAction func clearAll(_ sender: Any) {
        emailStatus.text=""
        emailActivate.text=""
        emailChangePass.text=""
        passChangePass.text=""
        responseText.text=""
        emailDeactivate.text=""
    }
    
    @IBAction func checkAccount(_ sender: Any) {
        responseText.text = ""
        if emailStatus.hasText==false{
            alertPop("Batal","Kolom email tidak terisi")
        }else if(Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }else{
            let params = "email=\(emailStatus.text!)"
            spinner.startAnimating()
            getData(checkURL, params,mode:1)
        }
    }

    @IBAction func activateAccount(_ sender: Any) {
        responseText.text = ""
        if emailActivate.hasText==false{
            alertPop("Batal","Kolom email tidak terisi")
        }else if(Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }else{
            let params = "email=\(emailActivate.text!)"
            spinner.startAnimating()
            getData(activeURL, params,mode:2)
        }

    }
    @IBAction func changePassword(_ sender: Any) {
        responseText.text = ""
        if emailChangePass.hasText==false{
            alertPop("Batal","Kolom email tidak terisi")
        }else if passChangePass.hasText==false{
            alertPop("Batal","Kolom kata sandi baru tidak terisi")
        }else if(Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }else{
            let params = "email=\(emailChangePass.text!)&password=\(passChangePass.text!)"
            spinner.startAnimating()
            getData(changePassURL, params,mode:3)
        }

    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        responseText.text = ""
        if emailDeactivate.hasText==false{
            alertPop("Batal","Kolom email tidak terisi")
        }else if(Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }else{
            let params = "email=\(emailDeactivate.text!)"
            spinner.startAnimating()
            getData(deleteURL, params,mode:4)
        }
    }
    
    
    // MARK - Connection to API
    
    func getData(_ link:String,_ params:String,mode:Int) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //request.setValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = params.data(using: String.Encoding.utf8)
        
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
                    switch mode{
                        case 1:
                            let username = "Username : \(json["data"][0]["username"].stringValue)"
                            let name = "Nama : \(json["data"][0]["nama"].stringValue)"
                            let email = "Email : \(json["data"][0]["email"].stringValue)"
                            var active = ""
                            if json["data"][0]["active"].intValue == 1{
                                active = "Active : Yes"
                            }else{
                                active = "Active : No"
                            }
                            self.data = "\(username)\n\(name)\n\(email)\n\(active)"
                            break
                        case 2:
                            let msge = json["data"].stringValue
                            if msge == "true"{
                                self.data = "Aktivasi akun berhasil"
                            }
                            break
                        case 3:
                            let msge = json["data"].stringValue
                            if msge == "true"{
                                self.data = "Perubahan kata sandi berhasil"
                            }
                            break
                        case 4:
                            let msge = json["data"].stringValue
                            if msge == "true"{
                                self.data = "Akun berhasil dihapus"
                            }
                        break
                        default:
                            print("No match")
                            break
                    }
                    DispatchQueue.main.async() {
                        self.responseText.text = self.data
                        self.responseText.setNeedsDisplay()
                        self.view.setNeedsDisplay()
                        self.spinner.stopAnimating()
                    }
                }else{
                    self.data = json["data"].stringValue
                    DispatchQueue.main.async() {
                        self.responseText.text = self.data
                        self.responseText.setNeedsDisplay()
                        self.view.setNeedsDisplay()
                        self.spinner.stopAnimating()
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

    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }

}
