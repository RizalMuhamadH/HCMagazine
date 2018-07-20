//
//  InboxDetailViewController.swift
//  HCMagazine
//
//  Page that displays a detail’s announcement that user’s choose (Inbox Detail Scene)
//
//  Created by ayobandung on 4/19/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit

class InboxDetailViewController: UIViewController, UIWebViewDelegate  {

     // MARK: - Properties
    @IBOutlet weak var subjectInboxDetailLabel: UILabel!
    @IBOutlet weak var dateInboxDetailLabel: UILabel!
    @IBOutlet weak var bodyInbox: UIWebView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    
    // MARK: - Variables
    var subjectPassed=""
    var datePassed=""
    var contentPassed=""
    var getHTML = ""
    var refreshControl:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(rgb: 0xEAC044)
        refreshControl.tintColor = UIColor(rgb: 0x115B80)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: [NSForegroundColorAttributeName:UIColor(rgb: 0xF115B80)])
        refreshControl.addTarget(self, action:  #selector(self.refresh), for: UIControlEvents.valueChanged)
        bodyInbox.scrollView.addSubview(refreshControl) // not required when using UITableViewController
        
        activityIndicatorView.hidesWhenStopped = true
        bodyInbox.delegate = self

        subjectInboxDetailLabel.text = subjectPassed
        dateInboxDetailLabel.text = datePassed
        getHTML = initHTML(contentPassed)
        bodyInbox.loadHTMLString(getHTML, baseURL:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Pull to refresh webview
    func refresh(sender:AnyObject) {
        bodyInbox.loadHTMLString(getHTML, baseURL:nil)
        refreshControl.endRefreshing()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        activityIndicatorView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    func initHTML(_ body:String)->String{
        var html = "<!DOCTYPE html><html>"
        html += "<head>"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "<link href=\"https://fonts.googleapis.com/css?family=Roboto:400,400i,700,700i\" rel=\"stylesheet\">"
        html += "<style>"
        html += "body{font-family:'Roboto',sans-serif;font-size:100%;} p{text-align:justify;color:black;}p.quotes{font-weight:bold;color:#115B80;}p.title{font-weight:bold;color:#115B80;font-size:130%;margin-bottom:12px;text-align:left;} p.caption{font-size:70%;color:#939598;text-align:justify;margin-bottom:5px;}div,img{width:100%;}.bjb{font-weight:bold;color:#115B80;}"
        html += "</style>"

        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html;
    }

    // MARK: - Navigation
}
