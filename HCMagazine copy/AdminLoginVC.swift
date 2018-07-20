//
//  AdminLoginVC.swift
//  HCMagazine
//
//  Setup administrator login page (Admin Login Scene)
//
//  Created by ayobandung on 8/3/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class AdminLoginVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    // MARK: - Variables
    let url = URL(string:"http://mobs.ayobandung.com/index.php/admin_controller/adminLogin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldOrder()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AdminLoginVC.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginAdmin(_ sender: UIButton) {
        let user = username.text
        let pss = password.text
        
        if (username.hasText==false){
            alertPop("Batal","Kolom username tidak terisi")
        }else if (password.hasText==false){
            alertPop("Batal","Kolom kata sandi tidak terisi")
        }else if(Reachability.isConnectedToNetwork() == false){
            alertPop( "Batal","Tidak terdeksi koneksi Internet")
        }else{

        //let jsend  = ["username":user!,"password":pss!]
        let params = "username=\(user!)&password=\(pss!)"
        let session = URLSession.shared
        
        var request = URLRequest(url: url!)
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
                let msg = json["msg"].stringValue
                if code == 200 {
                    self.performSegue(withIdentifier: "adminLoginSegue", sender: nil)
                }else{
                    self.alertPop("Batal", msg)
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()

        }
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
        username.delegate = self
        username.tag = 0 //Increment accordingly
        
        password.delegate = self
        password.tag = 1 //Increment accordingly
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToAdminLogin (Segue: UIStoryboardSegue) {
        
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
