//
//  RegisterViewController.swift
//  HCMagazine
//
//  Register new account for user (Register Scene and Activation Notify Scene)
//
//  Created by ayobandung on 4/17/17.
//  Last Modified on 9/29/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var nameRegField: UITextField!
    @IBOutlet weak var usernameRegField: UITextField!
    @IBOutlet weak var emailRegField: UITextField!
    @IBOutlet weak var passRegField: UITextField!
    @IBOutlet weak var passVerRegField: UITextField!
    @IBOutlet weak var waitLabel: UILabel!

    
    // MARK : - Variables
    var uncheckSyarat = false
    var uncheckKet = false
    var regstate = ""
    var msgFailed = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldOrder()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTextFieldOrder(){
        // Auto move cursor when return key hit in UITextField
        nameRegField.delegate = self
        nameRegField.tag = 0 //Increment accordingly
        
        usernameRegField.delegate = self
        usernameRegField.tag = 1 //Increment accordingly
        
        emailRegField.delegate = self
        emailRegField.tag = 2 //Increment accordingly
        
        passRegField.delegate = self
        passRegField.tag = 3 //Increment accordingly
        
        passVerRegField.delegate = self
        passVerRegField.tag = 4 //Increment accordingly
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
    
    // Register user
    func register() {
        let regname = nameRegField.text
        let reguser = usernameRegField.text
        let regemail = emailRegField.text
        let regpass = passRegField.text
        
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/registrationUser")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(reguser!)&password=\(regpass!)&nama=\(regname!)&email=\(regemail!)"
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
                if(self.regstate=="failed"){
                    self.msgFailed = json["msg"].stringValue
                }
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
        if identifier == "regSegue"{
            if  (nameRegField.hasText==false){
                alertPop("Batal","Kolom nama tidak terisi")
                return false
            }else if (usernameRegField.hasText==false){
                alertPop("Batal","Kolom username tidak terisi")
                return false
            }else if ((usernameRegField.text?.length)! != 4){
                alertPop("Batal","Username harus terdiri dari empat karakter yang sama dengan user id bank bjb anda")
                return false
            }else if (emailRegField.hasText==false){
                alertPop("Batal","Kolom email tidak terisi")
                return false
            }else if (emailRegField.text?.hasSuffix("@bankbjb.co.id") == false){
                alertPop("Batal","Harap memakai corporate email bank bjb")
                return false
            }else if (passRegField.hasText==false){
                alertPop("Batal","Kolom kata sandi tidak terisi")
                return false
            }else if (passVerRegField.hasText==false){
                alertPop("Batal","Kolom verifikasi kata sandi tidak terisi")
                return false
            }else if ((passRegField.text?.length)!<8){
                alertPop("Batal","Kolom kata sandi kurang dari delapan karakter")
                return false
            }else if (checkLower(text: passRegField.text!)==false){
                alertPop("Batal","Kolom kata sandi tidak disertai minimal 1(satu) huruf kecil")
                return false
            }/* DEPRECATED : client's request
                 else if (checkUpper(text: passRegField.text!)==false){
                alertPop("Batal","Kolom kata sandi tidak disertai minimal 1(satu) huruf besar")
                return false
            }else if (checkDigit(text: passRegField.text!)==false){
                alertPop("Batal","Kolom kata sandi tidak disertai minimal 1(satu) angka")
                return false
            } */
            else if (passRegField.text != passVerRegField.text){
                alertPop("Batal","Kolom kata sandi dan verifikasi tidak cocok")
                return false
            /* }else if uncheckSyarat{
                alertPop("Batal","Tandai persetujuan syarat")
                return false
            }else if uncheckKet{
                alertPop("Batal","Tandai persetujuan ketentuan")
                return false */
            }else if(Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }else{
                register()
                while(regstate==""){
                    //print("register \(regstate)")
                }
                Thread.sleep(forTimeInterval: 2) //waiting for json completed
                if (regstate=="success"){
                    //print(regstate)
                    Thread.sleep(forTimeInterval: 1) //waiting for json completed
                    return true
                }else{
                    alertPop( "Batal",msgFailed)
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

extension String {
    var length: Int {
        return self.characters.count
    }
}


