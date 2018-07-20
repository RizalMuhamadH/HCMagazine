//
//  CommentVC.swift
//  HCMagazine
//
//  Page to display all comments for an article (Comment Scene)
//
//  Created by ayobandung on 9/25/17.
//  Last modified on 10/10/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import Emoji
class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentTableView: UITableView!
    
    // MARK: - Variables
    var commentList:[Comment] = []
    var username = ""
    var nameUser = ""
    var newsId = 0
    var commentId = 0
    var contentSend = ""
    let getCommentsURL = "http://mobs.ayobandung.com/index.php/comment_controller/getComments"
    let addCommentURL = "http://mobs.ayobandung.com/index.php/comment_controller/addComment"
    let deleteCommentURL = "http://mobs.ayobandung.com/index.php/comment_controller/deleteComment"
    let getDetailUserURL = "http://mobs.ayobandung.com/index.php/user_controller/getDetailUser"
    // Access UserDefaults
    let defaults = UserDefaults.standard
    // Background thread
    var spinner: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "Dispatch Queue", attributes: [], target: nil)
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var keyboardHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username = defaults.string(forKey: "usr")!
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinner.color =  UIColor.init(red: 17, green: 91, blue: 128)
        commentTableView.backgroundView = spinner
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        commentTableView.addSubview(refreshControl) // not required when using UITableViewController
        
        // rounded text view
        commentBox.layer.borderColor = (UIColor.init(red: 234, green: 192, blue: 68)).cgColor
        commentBox.layer.borderWidth = 1.0
        commentBox.layer.cornerRadius = 8

        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentVC.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        // Set table footer eliminates empty cells
        commentTableView.tableFooterView = UIView()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        //commentBox.delegate = self

        getData(getDetailUserURL, mode: 0)
        getData(getCommentsURL, mode: 1)
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
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    //Detects if text view is empty
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        
        return true
    }
    
    //Pull to refresh tableview
    func refresh(sender:AnyObject) {
        commentList = []
        getData(getCommentsURL, mode: 1)
       
        if (commentList.count == 0) {
            commentTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.commentTableView.separatorColor = UIColor.init(red: 234, green: 192, blue: 68)
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.commentTableView.reloadData()
                }
            }
        }
    }

    func refreshList(){
        commentList = []
        getData(getCommentsURL, mode: 1)
        
        if (commentList.count == 0) {
            commentTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.commentTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func refreshComments(_ sender: Any) {
        refreshList()
    }
    
    @IBAction func sendComment(_ sender: Any) {
        if validate(textView: commentBox){
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let result = formatter.string(from: date)
            let commentText = commentBox.text
            let convertEmoji = (commentText?.emojiEscapedString)!
            var commentSent = Comment(id: 0, username: username, name: nameUser, date: result, tbody: convertEmoji)
            contentSend = convertEmoji
            commentBox.text = ""
            commentSent.tbody = commentText!
            commentList.append(commentSent)
            commentTableView.reloadData()
            getData(addCommentURL, mode: 2)
        }
    }
    
    // MARK: - Display data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        // set auto height row cell to fit content
        commentTableView.estimatedRowHeight = 110
        commentTableView.rowHeight = UITableViewAutomaticDimension
        
        if (commentList.count == 0) {
            commentTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            spinner.startAnimating()
            
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                OperationQueue.main.addOperation() {
                    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    self.spinner.stopAnimating()
                    self.commentTableView.reloadData()
                }
            }
        }
    }

    
    /* MARK: - Connection to API
     mode 0 : get name of the user
     mode 1 : get all comments
     mode 2 : insert comment
     mode 3 : delete comment
     */
    
    func getData(_ link:String,mode:Int) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        var params = ""
        switch mode {
            case 0:
                params = "username=\(username)"
            case 1:
                params = "news_id=\(newsId)"
            case 2:
                params = "news_id=\(newsId)&username=\(username)&comment=\(contentSend)"
            case 3:
                params = "comment_id=\(commentId)"
            default:
                print("no match")
        }
        
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
                let state = json["status"].stringValue
                print("The state is: \(state)")
                if(state=="success"){
                    let dataArr = json["data"].arrayValue
                    switch mode{
                        case 0:
                            self.nameUser = dataArr[0]["nama"].stringValue
                        case 1:
                            var i = 0
                            while i<dataArr.count{
                                let getDate = dataArr[i]["date_comment"].stringValue
                                let dateArr = getDate.components(separatedBy: "-")
                                let setDate = "\(dateArr[2])-\(dateArr[1])-\(dateArr[0])"
                                
                                let oneComment = Comment(id: dataArr[i]["comment_id"].intValue, username: dataArr[i]["username"].stringValue, name: dataArr[i]["nama"].stringValue, date: setDate, tbody: (dataArr[i]["comment_content"].stringValue).emojiUnescapedString)
                                self.commentList.append(oneComment)
                                i += 1
                            }
                        case 2:
                            self.commentList[self.commentList.count-1].id = dataArr[0]["comment_id"].intValue
                        case 3:
                            print("delete \(self.commentId) successful")
                        default:
                            print("no match")
                    }
                }else{
                    self.alertMsg("Jadilah orang pertama yang memberikan komentar")
                }
            } catch  {
                print("error trying to convert data to JSON")
                self.alertPop("Batal", "Gagal mengonversi data")
                return
            }
        }
        task.resume()
        
    }
    
    /* MARK: - Text View (manual move view up when keyboard appears
    func textViewDidBeginEditing(_ textView: UITextView) {
        if #available(iOS 11.0, *) {
            moveTextView(textView, moveDistance: (Int(keyboardHeight) * -1), up: true)
        }
    
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if #available(iOS 11.0, *) {
            moveTextView(textView, moveDistance: (Int(keyboardHeight) * -1), up: false)
        }
    }
    
    func moveTextView(_ textView: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    */
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        /* Configure the cell... */
        let getComment = commentList[indexPath.row]
        cell.commentText.text = getComment.tbody
        cell.nameLabel.text = getComment.name
        cell.dateLabel.text = getComment.date
        
        return cell
    }
    
    // Add animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /* only fade in */
         cell.alpha = 0
         
         UIView.animate(withDuration: 1.0){
         cell.alpha = 1.0
         }
    }

    // add swipe left to delete comment
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(commentList[indexPath.row].username == username){
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let removeComment = commentList[indexPath.row]
            commentId = removeComment.id
            commentList.remove(at: indexPath.row)
            getData(deleteCommentURL, mode: 3)
            commentTableView.reloadData()
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
    
    func alertMsg(_ msg: String) {
        let Alert = UIAlertController(title: "INFO", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        Alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            print("Dismiss for gimmick")
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.commentTableView.bounds.size.width, height: self.commentTableView.bounds.size.height))
            noDataLabel.text          = "Tidak Ada Komentar"
            noDataLabel.font = UIFont(name:"Roboto-Bold", size: 16)
            noDataLabel.textColor = UIColor.init(red: 17, green: 91, blue: 128)
            noDataLabel.textAlignment = .center
            self.commentTableView.backgroundView  = noDataLabel
            self.commentTableView.separatorStyle  = .none
        }))
        self.present(Alert, animated: true, completion: nil)
    }

}
