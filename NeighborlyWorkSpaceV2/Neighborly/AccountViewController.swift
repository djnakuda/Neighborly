//
//  AccountViewController.swift
//  Neighborly
//
//  Created by Avni Barman on 4/8/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import Starscream
import Cloudinary


class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebSocketDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
        
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var encodedImg:String = ""
    var imageData = Data()
    public var user:User?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var model = ItemsModel.shared
    private var selectedItem:Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = 134
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccount), name: NSNotification.Name(rawValue: "loadAccount"), object: nil)
        updateAccount()
        
        
        let accountInfoMessage = AccountInfoMessage(userID: (user?.userID)!)
        let encoder = JSONEncoder()
        
        
        do{
            let data = try encoder.encode(accountInfoMessage)
            socket.write(string: String(data: data, encoding: .utf8)!)
            
        }catch{}
        print("account view did load")
        
    }
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("accountinfo socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("accountinfo socket disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("account info received text: \(text)")
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let userInfo = try! decoder.decode(UserInfoMessage.self, from: jsonText)
        print("userID received:  \(String(describing: userInfo.userID))" )
        print("message received:  \(userInfo.message)" )
        print("\nmy Items received: \(String(describing: userInfo.myItems?.first?.itemName))" )
        
        if(userInfo.message == "valid"){
            model.setMyItems(items: userInfo.myItems!)
            model.setBorrowedItems(items: userInfo.borrowedItems!)
            if(userInfo.imageURL != ""){
                let url = URL(string: (userInfo.imageURL)!)
                let data = try? Data(contentsOf: url!)
                user?.image =  UIImage(data: data!)
            }
            user?.saveUser()
            updateAccount()
            
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("account info received data: \(data)")
        
    }
    
    @IBAction func updatePhotoButtonClicked(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else
            {
                print("camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func updateAccount(){
        self.user = loadUser()
        self.nameField.text = user?.name
        if(self.user?.image != nil){
            self.profileImageView.image = self.user?.image
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMenu"), object: nil)
        tableView.reloadData()
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imagePicked = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profileImageView.image = imagePicked
        
        
            user?.setImage(image: imagePicked)
            user?.saveUser()
            
            updateAccount()
            
            imageData = UIImageJPEGRepresentation(imagePicked, 0.000005)!
            
        picker.dismiss(animated: true, completion: nil)

        
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "szxnywdo"){
            result, error in
            print("account profile image upload error:  \(String(describing: error))")
            let imageURL = result?.url
            
        
            
            let userUpdatePhoto = UpdateUserPhotoMessage(userID: self.user!.userID, imageURL: imageURL!)
            let encoder = JSONEncoder()
            
            do{
                let data = try encoder.encode(userUpdatePhoto)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{ }
        }
     
        
    }
   
    
    
    
   
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate  as! AppDelegate
        appDelegate.centerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    
    
    
    @IBAction func segmentControlClicked(_ sender: Any) {
        tableView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch(segmentControl.selectedSegmentIndex){
        case 0:
            return model.borrowedItems.count
            
        case 1:
            return model.myItems.count
            
        default:
            break
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell( withIdentifier: "itemCard", for: indexPath) as! ItemCardTableViewCell
        var item:Item?
        
        switch(segmentControl.selectedSegmentIndex){
        case 0:
            item = model.borrowedItems[indexPath.row]
            break
        case 1:
            item = model.myItems[indexPath.row]
            break
        default:
            break
        }
        
        cell.itemName.text = item?.itemName
        cell.itemDetails.text = item?.itemDescription
        if(item?.imageURL != ""){
            let url = URL(string: (item?.imageURL)!)
            let data = try? Data(contentsOf: url!)
            cell.itemPhoto.image =  UIImage(data: data!)
        }
        
        cell.itemStatusLabel.textColor = UIColor.white
        cell.itemStatusLabel.layer.cornerRadius = 6
        cell.itemStatusLabel.layer.masksToBounds = true
        
        if(item?.available == 1){
            cell.itemStatusLabel.text = "Available"
            cell.itemStatusLabel.backgroundColor = UIColor.green
        }else{
            cell.itemStatusLabel.text = "Unavailable"
            cell.itemStatusLabel.backgroundColor = UIColor.orange
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(segmentControl.selectedSegmentIndex){
        case 0:
            self.selectedItem = model.borrowedItems[indexPath.row]
            break
        case 1:
            self.selectedItem = model.myItems[indexPath.row]
            break
        default:
            break
        }
        
        
        self.performSegue(withIdentifier: "itemDescriptionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "itemDescriptionSegue" ){
            let itemDescriptionVC = segue.destination as! ItemDescriptionViewController
            itemDescriptionVC.currentItem = selectedItem
        }
    }
}
