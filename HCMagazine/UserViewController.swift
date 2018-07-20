//
//  UserViewController.swift
//  HCMagazine
//
//  Page to display user’s data and option to logout, change name and password (User Scene)
//
//  Created by ayobandung on 4/19/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    // MARK: - Variables
    var username="" //receive passed data
    var regstate=""
    var userget:[User]=[]
    
    //Background Thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    // Access UserDefaults
    let defaults = UserDefaults.standard
    var loginEnabled: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = defaults.string(forKey: "usr")!
        
        getUser(self.username)
        // set field
        usernameField.text = username
        dispatchQueue.async {
            Thread.sleep(forTimeInterval: 1)
            OperationQueue.main.addOperation() {
                let fname = self.userget[0].userNameReal.components(separatedBy: " ")
                self.NameLabel.text = fname[0]
                self.nameField.text = self.userget[0].userNameReal
                self.emailField.text = self.userget[0].userEmail
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Connection to API to get user detail
    
    func getUser(_ userName:String) {
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/getDetailUser")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(userName)"
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
                let state = json["status"].stringValue
                print("The state is: \(state)")
                self.regstate = state
                if(self.regstate=="success"){
                    let userdata = json["data"].arrayValue
                    let newUser = User(userId: userdata[0]["id"].stringValue, userName: userdata[0]["username"].stringValue, userEmail: userdata[0]["email"].stringValue, userNameReal: userdata[0]["nama"].stringValue)
                    self.userget.append(newUser)
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }

    @IBAction func goChangeName(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeNameVC")
        UIApplication.topViewController()?.present(nextVC, animated: true, completion: nil)
    }
    @IBAction func goChangePass(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePassVC")
        UIApplication.topViewController()?.present(nextVC, animated: true, completion: nil)
    }
    
    // MARK: - Alert
    
    func alertPop(_ titles: String, _ msg: String) {
        let Alert = UIAlertController(title: titles, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: titles, style: .cancel, handler: { action in
            print("Dismiss for '\(titles)'")
        }))
        self.present(Alert, animated: true, completion: nil)
    }
    
    // MARK : - Navigation
    
    @IBAction func unwindToUser (Segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue" {
            if let nextVC: LoginViewController = segue.destination as? LoginViewController {
                //Delete store username and password
                nextVC.loginEnabled = []
                nextVC.usernameField.text=""
                nextVC.passField.text=""
                nextVC.staySignIn.setImage(UIImage(named:"uncheckbox"), for: .normal)
                nextVC.uncheckSignIn = true
                defaults.removeObject(forKey: "stayLogin")
                dismiss(animated: true)
                
            }
        }
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
