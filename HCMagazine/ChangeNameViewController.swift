//
//  ChangeNameViewController.swift
//  HCMagazine
//
//  Page that display old user’s name and enables user to change name (Change Name Scene)
//
//  Created by ayobandung on 4/19/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    @IBOutlet weak var prevNameField: UITextField!
    @IBOutlet weak var newNameField: UITextField!
    
    // MARK: - Variables
    var username=""
    var userget:[User]=[]
    var regstate=""
    var updstate=""
    // Access UserDefaults
    let defaults = UserDefaults.standard
    //Background Thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }
        // Get username
        username = defaults.string(forKey: "usr")!
        
        getUser(username)
        // set field
        dispatchQueue.async {
            Thread.sleep(forTimeInterval: 1)
            OperationQueue.main.addOperation() {
                self.prevNameField.text = self.userget[0].userNameReal
            }
        }
        
        // Auto move cursor when return key hit in UITextField
        newNameField.delegate = self
        newNameField.tag = 0 //Increment accordingly
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChangeNameViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
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
    
    // MARK: - Connection to API to get user detail
    
    func getUser(_ userName:String) {
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/getDetailUser")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(username)"
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
                self.alertPop("Batal", "Gagal menkonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    // MARK: - Connection to API to update name of the user
    
    func updateUser(_ newName:String) {
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/updateNameUser")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(username)&nama=\(newName)"
        userget[0].userNameReal = newName
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
                self.updstate = state
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }



    // MARK: - Navigation
    
    // Set up alert before proceed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveNameSegue"{
            if  (newNameField.hasText==false){
                alertPop("Batal","Kolom nama baru tidak terisi")
                return false
            }else if (Reachability.isConnectedToNetwork() == false){
                    alertPop( "Batal","Tidak terdeksi koneksi Internet")
                    return false
            }else{
                //save changes
                updateUser(newNameField.text!)
                while(updstate==""){
                    //print("update \(updstate)")
                }
                Thread.sleep(forTimeInterval: 1) //waiting for json completed
                if (updstate=="success"){
                    //print(updstate)
                    Thread.sleep(forTimeInterval: 1) //waiting for json completed
                    return true
                }else{
                    alertPop( "Batal","Gagal menyimpan nama")
                    return false
                }

            }
        }
        return true
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
