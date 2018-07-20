//
//  BackTableVC.swift
//  HCMagazine
//
//  Setup only drawer menu content (rubric)
//
//  Created by ayobandung on 6/7/17.
//  Last modified on 12/04/17.
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import Foundation

class BackTableVC: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet var drawerHomeTable: UITableView!
    
    //MARK: - Variables
    var menuDrawer = ["Home","News Feed","Susunan Redaksi",/*"Dari Redaksi","Pesan Manajemen","HC News","PAHAMI dan PATUHI","bjb NEW GENERATION","SEMAR","bjb university","bjb CLUB","Serba-serbi","Sosok","Banker's Life","Motivasi Tune Up","Tanya HC CLinic","bjb Health +","Know Your Leader","Trivia",*/"Galeri Foto","Direktori Edisi"]
    var iconMenu = [UIImage(named:"home_icon_drawer"),UIImage(named:"feed_icon"),UIImage(named:"susunan_icon"),/*UIImage(named:"redaksi_icon"),UIImage(named:"mgmt_icon"),UIImage(named:"hcnews_icon"),UIImage(named:"kepatuhan_icon"),UIImage(named:"diklat_icon"),UIImage(named:"manrisk_icon"),UIImage(named:"bjbuni_icon"),UIImage(named:"bjbclub_icon"),UIImage(named:"insan_icon"),UIImage(named:"kilas_icon"),UIImage(named:"kiat_icon"),UIImage(named:"tuneup_icon"),UIImage(named:"hcclinic_icon"),UIImage(named:"health_icon"),UIImage(named:"know_icon"),UIImage(named:"trivia_icon"),*/UIImage(named:"gal_icon"),UIImage(named:"dir_icon")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set table footer eliminates empty cells
        self.drawerHomeTable.tableFooterView = UIView()

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
        let revealVC:SWRevealViewController = self.revealViewController()
        let cell:DrawerMenuCell = tableView.cellForRow(at: indexPath) as! DrawerMenuCell
        
        if cell.menuTitle.text == "Home"{
            self.performSegue(withIdentifier: "backCoverSegue", sender: self)
        }else if cell.menuTitle.text == "News Feed"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "DisplayVC") as! DisplayViewController
            nextVC.title = "Feed"
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Susunan Redaksi"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RedaksiVC") as! RedaksiVC
            nextVC.title = "Susunan Redaksi HC News"
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }/* DEPRECATED
        else if cell.menuTitle.text == "Dari Redaksi"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Dari Redaksi"
            nextVC.rubricId = 1
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "HC News"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "HC News"
            nextVC.rubricId = 2
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "PAHAMI dan  PATUHI"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "PAHAMI dan  PATUHI"
            nextVC.rubricId = 3
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "bjb NEW GENERATION"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "bjb NEW GENERATION"
            nextVC.rubricId = 4
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "SEMAR"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "SEMAR"
            nextVC.rubricId = 5
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "bjb university"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "bjb university"
            nextVC.rubricId = 6
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "bjb CLUB"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "bjb CLUB"
            nextVC.rubricId = 7
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Serba-serbi"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Serba-serbi"
            nextVC.rubricId = 12
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Sosok"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Sosok"
            nextVC.rubricId = 8
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Pesan Manajemen"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Pesan Manajemen"
            nextVC.rubricId = 9
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Banker's Life"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Banker's Life"
            nextVC.rubricId = 10
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Motivasi Tune Up"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Motivasi Tune Up"
            nextVC.rubricId = 11
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Tanya HC CLinic"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Tanya HC CLinic"
            nextVC.rubricId = 13
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "bjb Health +"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "bjb Health +"
            nextVC.rubricId = 16
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Know Your Leader"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Know Your Leader"
            nextVC.rubricId = 14
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Trivia"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "RubricFeedVC") as! RubricFeedTVC
            nextVC.title = "Trivia"
            nextVC.rubricId = 15
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }*/
        else if cell.menuTitle.text == "Galeri Foto"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "PhotoGallVC") as! PhotoGalleryCollectionViewController
            nextVC.title = "Galeri Foto"
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }else if cell.menuTitle.text == "Direktori Edisi"{
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = mainStoryboard.instantiateViewController(withIdentifier: "LibraryVC") as! LibraryCollectionViewController
            nextVC.title = "Direktori Edisi"
            let newFrontVC = UINavigationController.init(rootViewController: nextVC)
            revealVC.pushFrontViewController(newFrontVC, animated: true)
        }
        
    }
    
}
