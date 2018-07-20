//
//  ChangePassViewController.swift
//  HCMagazine
//
//  Page that enables user to change password (Change Password Scene)
//
//  Created by ayobandung on 4/19/17.
//  Last Modified on 8/28/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class ChangePassViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var verifyNewPassField: UITextField!
    
    // MARK: - Variables
    var username=""
    var updstate=""
    // Access UserDefaults
    let defaults = UserDefaults.standard
    //Background Thread
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Check Internet Connection
        if (Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }

        // Get username
        username = defaults.string(forKey: "usr")!
        
        // Auto move cursor when return key hit in UITextField
        oldPassField.delegate = self
        oldPassField.tag = 0 //Increment accordingly

        newPassField.delegate = self
        newPassField.tag = 1 //Increment accordingly

        verifyNewPassField.delegate = self
        verifyNewPassField.tag = 2 //Increment accordingly

        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChangePassViewController.dismissKeyboard))
        
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

    // DEPRECATED : client's request
    //Calls to check password with uppercase letter
    func checkUpper( text : String) -> Bool{
        
        let text = text
        let regEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = texttest.evaluate(with: text)
        
        return result
    }
    //Calls to check password with lowercase letter
    func checkLower(text : String) -> Bool{
        
        let text = text
        let regEx  = ".*[a-z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = texttest.evaluate(with: text)
        
        return result
    }
    
    // DEPRECATED : client's request
    //Calls to check password with digit/number
    func checkDigit( text : String) -> Bool{
        
        let text = text
        let regEx  = ".*[0-9]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", regEx)
        let result = texttest.evaluate(with: text)
        
        return result
    }
    
    // MARK: - Connection to API to update user password
    
    func updatePass(_ newPass:String, _ oldPass:String) {
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/changePasswordUser")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(username)&password=\(newPass)&oldpassword=\(oldPass)"
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
        if identifier == "savePassSegue"{
            if  (oldPassField.hasText==false){
                alertPop("Batal","Kolom kata sandi lama tidak terisi")
                return false
            }else if (newPassField.hasText==false){
                alertPop("Batal","Kolom kata sandi baru tidak terisi")
                return false
            }else if (verifyNewPassField.hasText==false){
                alertPop("Batal","Kolom konfirmasi kata sandi baru tidak terisi")
                return false
            }else if ((newPassField.text?.length)!<8 && (verifyNewPassField.text?.length)!<8){
                alertPop("Batal","Kolom kata sandi baru dan konfirmasinya kurang dari delapan karakter")
                return false
            }else if (checkLower(text: newPassField.text!)==false){
                alertPop("Batal","Kolom kata sandi baru tidak disertai minimal 1(satu) huruf kecil")
                return false
            }/*// DEPRECATED : client's request
                else if (checkUpper(text: newPassField.text!)==false){
                alertPop("Batal","Kolom kata sandi baru tidak disertai minimal 1(satu) huruf besar")
                return false
            }else if (checkDigit(text: newPassField.text!)==false){
                alertPop("Batal","Kolom kata sandi baru tidak disertai minimal 1(satu) angka")
                return false
            }*/else if (newPassField.text != verifyNewPassField.text){
                alertPop("Batal","Kolom kata sandi baru dan konfirmasinya tidak cocok")
                return false
            }else if (Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }else{
                //save changes
                updatePass(newPassField.text!,oldPassField.text!)
                while(updstate==""){
                    //print("update \(updstate)")
                }
                Thread.sleep(forTimeInterval: 1) //waiting for json completed
                if (updstate=="success"){
                    //print(updstate)
                    Thread.sleep(forTimeInterval: 1) //waiting for json completed
                    defaults.removeObject(forKey: "stayLogin")
                    defaults.synchronize()
                    return true
                }else{
                    alertPop( "Batal","Gagal menyimpan kata sandi")
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
