//
//  ResetViewController.swift
//  HCMagazine
//
//  Reset password user if user forgot password (Reset Password Scene and Reset Notify Scene)
//
//  Created by ayobandung on 4/17/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class ResetViewController: UIViewController,UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var emailResetField: UITextField!
    @IBOutlet weak var randomLabel: UILabel!
    @IBOutlet weak var randomField: UITextField!
    
     // MARK: - Variables
    var regstate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Auto move cursor when return key hit in UITextField
        emailResetField.delegate = self
        emailResetField.tag = 0 //Increment accordingly
        
        // Auto move cursor when return key hit in UITextField
        randomField.delegate = self
        randomField.tag = 1 //Increment accordingly

        randomLabel.text = random()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetViewController.dismissKeyboard))
        
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
    
    //Calls to generate random number to avoid bot
    func random()->String{
        let num = arc4random_uniform(9999)
        if (num < 1000){
            return "0"+String(num)
        }else{
            return String(num)
        }
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
    
    // Reset password user
    func reset() {
        let emailUser = emailResetField.text
        let url = URL(string:"http://mobs.ayobandung.com/index.php/user_controller/resetPassword")!
        //let jsend  = ["username":user!,"password":pss!]
        let params = "email=\(emailUser!)"
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
        if identifier == "resetSegue"{
            if (emailResetField.hasText==false){
                alertPop("Batal","Kolom email tidak terisi")
                return false
            }else if (emailResetField.text?.hasSuffix("@bankbjb.co.id") == false){
                alertPop("Batal","Harap memakai corporate email bank bjb")
                return false 
            }else if (randomField.hasText==false){
                alertPop("Batal","Kolom angka captcha tidak terisi")
                return false
            }else if (randomField.text != randomLabel.text){
                alertPop("Batal","Kolom angka captcha tidak sesuai")
                return false
            }else if(Reachability.isConnectedToNetwork() == false){
                alertPop( "Batal","Tidak terdeksi koneksi Internet")
                return false
            }else{
                reset()
                while(regstate==""){
                    //print("reset \(regstate)")
                }
                Thread.sleep(forTimeInterval: 2) //waiting for json completed
                if (regstate=="success"){
                    //print(regstate)
                    Thread.sleep(forTimeInterval: 1) //waiting for json completed
                    return true
                }else{
                    alertPop( "Batal","Gagal menyetel ulang kata sandi")
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
