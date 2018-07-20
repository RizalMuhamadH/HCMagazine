//
//  LoginViewController.swift
//  HCMagazine
//
//  User login page with options to register, reset password and resend activation link (Login Scene)
//
//  Created by ayobandung on 4/21/17.
//  Last Modified on 8/28/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var staySignIn: UIButton!
    
    // MARK : - Variables
    let appStoreAppID = 1237592384
    var uncheckSignIn = true
    var segue = 0
    var username = ""
    var msg = ""
    // Access UserDefaults
    let defaults = UserDefaults.standard
    var loginEnabled: [String] = []
    let checkURL = "http://mobs.ayobandung.com/index.php/version_controller/appVersion"
    var appversion = ""
    //Background Thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldOrder()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        // Get user preferences if existed
        if isKeyPresentInUserDefaults(key: "stayLogin") {
            loginEnabled = defaults.array(forKey: "stayLogin") as! [String]
            usernameField.text = loginEnabled[0]
            passField.text = loginEnabled[1]
            uncheckSignIn = false
            staySignIn.setImage(UIImage(named:"checkbox"), for: .normal)
        }
        //get user's app version
        appversion = version()
        
        //Check version
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                self.checkVersion(self.checkURL)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Get user's app version
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        // let build = dictionary["CFBundleVersion"] as! String
        print(version)
        return "\(version)"
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Text Field
    
    //Calls this function when return key is hit in text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func setTextFieldOrder(){
        // Auto move cursor when return key hit in UITextField
        usernameField.delegate = self
        usernameField.tag = 0 //Increment accordingly
        
        passField.delegate = self
        passField.tag = 1 //Increment accordingly
    }
    
    // MARK: - User Defaults
    
    // Check existed user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // MARK: - Connection to API
    
    //check app version
    func checkVersion(_ link:String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        let params = "platform=ios"
        
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
                    let storeversion = json["version"].stringValue
                    let store = Float(storeversion)!
                    let app = Float(self.appversion)!
                    print("store \(store) - app \(app)")
                    if(app < store){
                        self.alertItunes("Info", "Versi aplikasi bjb HC News anda saat ini \(self.appversion). Mohon update ke versi terbaru bjb HC News \(storeversion)")
                    }
                }else{
                    self.alertPop("Info", "Gagal mengecek versi aplikasi")
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    
    @IBAction func logIn(_ sender: Any) {
        let user = usernameField.text
        username = user!
        let pss = passField.text
        if (self.uncheckSignIn==false) {
            //store data
            // Save preferences with user default
            let arrLogin = [user,pss]
            self.loginEnabled = arrLogin as! [String]
            self.defaults.set(self.loginEnabled, forKey: "stayLogin")
            self.defaults.synchronize()
        }
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/userLogin")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(user!)&password=\(pss!)"
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //request.setValue("charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = params.data(using: String.Encoding.utf8)
        
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
                let code = json["kode"].intValue
                print("The code is: \(code)")
                self.segue = code
                self.msg = json["msg"].stringValue
                self.defaults.set(json["changepass"].stringValue, forKey: "changepass")
                self.defaults.set(user, forKey: "usr")
                self.defaults.synchronize()
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    @IBAction func tickStaySignIn(_ sender: UIButton) {
        if uncheckSignIn{ //stay sign in
            staySignIn.setImage(UIImage(named:"checkbox"), for: .normal)
            uncheckSignIn = false
        }else{
            staySignIn.setImage(UIImage(named:"uncheckbox"), for: .normal)
            uncheckSignIn = true
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToLogin (Segue: UIStoryboardSegue) {
        
    }
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginSegue"{
            if (usernameField.hasText==false){
                alertPop("Batal","Kolom username tidak terisi")
                return false
            }else if (passField.hasText==false){
                alertPop("Batal","Kolom kata sandi tidak terisi")
                return false
            }else if(Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }else{
                while(segue==0){
                    //print(segue)
                }
                if (segue==200){
                    return true
                }else{
                    alertPop( "Batal",msg)
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Alert
    
    func alertItunes(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id\(self.appStoreAppID)")!)
        }))
        self.present(Alert, animated: true, completion: nil)
    }
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: titles, style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }
    
}
