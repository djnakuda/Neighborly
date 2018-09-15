//
//  LeftSideMenuViewController.swift
//  Neighborly
//
//  Created by Other users on 4/2/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit

class LeftSideMenuViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    public var user:User?
    var menuItems:[String] =  ["Search Items", "Account", "Messages" , "About" ]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuProfileImage: UIImageView!
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        menuProfileImage.layer.cornerRadius = menuProfileImage.frame.size.width/2
        menuProfileImage.layer.masksToBounds = false
        menuProfileImage.clipsToBounds = true
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: NSNotification.Name(rawValue: "loadMenu"), object: nil)
        updateMenu()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logoutClicked(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
        user? = User(userID: 0, name: "", email: "", image: UIImage(named:"DefaultUserIcon") )
        user?.saveUser()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMenu"), object: nil)
    
        
        appDelegate.window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: "entryViewController") as! ViewController
        
      
    }
    
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        
        cell.menuItemLabel.text = menuItems[indexPath.row]
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        var pageSelected = menuItems[indexPath.row]
        switch(pageSelected){
            case "Search Items":
                let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                let mainNavController = UINavigationController(rootViewController: mainViewController)
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.centerContainer!.centerViewController = mainNavController
                appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
                break;
            case "Account":
                let accountViewController = self.storyboard?.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
                let accountNavController = UINavigationController(rootViewController: accountViewController)
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.centerContainer!.centerViewController = accountNavController
                appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)
            case "About":
                let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
                let aboutNavController = UINavigationController(rootViewController: aboutViewController)
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.centerContainer!.centerViewController = aboutNavController
                appDelegate.centerContainer!.toggle(MMDrawerSide.left, animated: true, completion: nil)

                break;
        default:
            print("other menu cell selected")
            
        }
    }
    
    @objc public func updateMenu(){
        self.user = loadUser()
        user? = loadUser()!
        
        if(user?.email == "guest"){
            menuItems =  ["Search Items" , "About" ]
        }else{
            menuItems =  ["Search Items", "Account" , "About" ]
        }
        
         menuTableView.reloadData()
        
        nameLabel.text = user?.name
        print("\n menu updated and image is \(String(describing: user?.image))")
        
        if(user?.image != nil){
            menuProfileImage.image = user?.image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
