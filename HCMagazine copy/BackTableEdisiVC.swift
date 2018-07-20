//
//  BackTableEdisiVC.swift
//  HCMagazine
//
//  Setup only drawer menu in library page
//  3rd party plugin: Github by jonkykong/SideMenu
//
//  Created by ayobandung on 7/26/17.
//  Last modified on 11/17/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import Foundation
import SideMenu

var iconMenu = [UIImage(named:"back_icon"),UIImage(named:"feed_icon"),UIImage(named:"redaksi_icon"),UIImage(named:"mgmt_icon"),UIImage(named:"hcnews_icon"),UIImage(named:"kepatuhan_icon"),UIImage(named:"diklat_icon"),UIImage(named:"manrisk_icon"),UIImage(named:"bjbuni_icon"),UIImage(named:"bjbclub_icon"),UIImage(named:"insan_icon"),UIImage(named:"kilas_icon"),UIImage(named:"kiat_icon"),UIImage(named:"tuneup_icon"),UIImage(named:"hcclinic_icon"),UIImage(named:"health_icon"),UIImage(named:"know_icon"),UIImage(named:"trivia_icon")]

class BackTableEdisiVC: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet var sideDrawer: UITableView!
    
    //MARK: - Variables
    let menuDrawer = rubricList
    var rubric = 0
    var titleVC = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set table footer eliminates empty cells
        self.sideDrawer.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuDrawer.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DrawerMenuCell
        cell.menuTitle.text = menuDrawer[indexPath.row]
        cell.menuIcon.image = iconMenu[indexPath.row]
        
        //Change background color
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 0, green: 165, blue: 215)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:DrawerMenuCell = tableView.cellForRow(at: indexPath) as! DrawerMenuCell
        titleVC = cell.menuTitle.text!
        if cell.menuTitle.text == "Direktori Edisi"{
            self.performSegue(withIdentifier: "backLibrarySegue", sender: self)
        }else if cell.menuTitle.text == "News Feed"{
            self.performSegue(withIdentifier: "BackFeedLibrarySegue", sender: self)
        }else{
            // get rubric index, remember  index 0 and 1 are not rubrics
            let indexRubric = menuDrawer.index(of: cell.menuTitle.text!)!
            rubric = rubricIdList[indexRubric]
            self.performSegue(withIdentifier: "OpenRubricSegue", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    // Set up data to be passed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenRubricSegue" {
            let navVC = segue.destination as? UINavigationController
            let nextVC = navVC?.viewControllers.first as! RubricLibraryTVC
            nextVC.rubricId = rubric
            nextVC.title = titleVC
        }

    }

    @IBAction func unwindToDrawer (Segue: UIStoryboardSegue) {
        
    }

    
}
