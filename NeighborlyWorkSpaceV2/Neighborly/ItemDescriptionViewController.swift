//
//  ItemDescriptionViewController.swift
//  Neighborly
//
//  Created by Avni Barman on 4/17/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import Starscream

class ItemDescriptionViewController: UIViewController, WebSocketDelegate {
    //    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    //
    //    }
    //
    
    var tempItemID = 1
    public var user:User?
    var currentItem:Item?
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var requestButton: UIButton!
    public func loadUser() -> User?{
        return NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User
    }
    
    
    
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var deleteItemLabel: UIButton!
    @IBOutlet weak var itemAvailabiltyLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        
        self.user = loadUser()!
        
        itemNameLabel.text = currentItem?.itemName
        itemDescriptionLabel.text = currentItem?.itemDescription
        if(currentItem?.imageURL != ""){
            let url = URL(string: (currentItem?.imageURL)!)
            let data = try? Data(contentsOf: url!)
            itemImageView.image =  UIImage(data: data!)
        }
        
        if(user?.userID == currentItem?.ownerID){
            deleteItemLabel.isHidden = false
        }
        
        if(currentItem?.available == 1){
            itemAvailabiltyLabel.text = "Available"
            itemAvailabiltyLabel.textColor = UIColor.green
        }else{
            itemAvailabiltyLabel.text = "Unavailable"
            itemAvailabiltyLabel.textColor = UIColor.red
        }
        
        if(currentItem?.ownerID == user?.userID){
            let label = itemDistanceLabel
            label?.text = "My Item"
            label?.backgroundColor = UIColor.blue
            label?.textColor = UIColor.white
            label?.layer.cornerRadius = 6
            label?.layer.masksToBounds = true
            
        }
        
        
        //let itemMessage = GetItemInfo(message: "", itemID: tempItemID)
        /*
         let encoder = JSONEncoder()
         
         do{
         let data = try encoder.encode(itemMessage)
         socket.write(string: String(data: data, encoding: .utf8)!)
         
         
         }catch{
         
         }
         */
    if(user?.email != "guest"){
        if (user?.userID == currentItem?.ownerID)
        {
            requestButton.setTitle("Accept", for: .normal)
            messageButton.setTitle("Decline", for: .normal)
            if (currentItem?.requestorID != -1 || (currentItem?.borrowerID != -1 && currentItem?.returnRequest == 1 ))
            {
                
            }
            else
            {
                requestButton.isEnabled = false
                messageButton.isEnabled = false
                requestButton.backgroundColor = UIColor.lightGray
                messageButton.backgroundColor = UIColor.lightGray
            }
        }
        else if (user?.userID == currentItem?.requestorID)
        {
            requestButton.setTitle("Requested", for: .normal)
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
            messageButton.isHidden = true
        }
        else if (user?.userID == currentItem?.borrowerID)
        {
            if (currentItem?.returnRequest == 1)
            {
                requestButton.setTitle("Return Requested", for: .normal)
                requestButton.backgroundColor = UIColor.lightGray
                requestButton.isEnabled = false
                messageButton.isHidden = true
            }
            else
            {
                requestButton.setTitle("Request Return", for: .normal)
                messageButton.isHidden = true
            }
        }
        else
        {
            if (currentItem?.requestorID != -1 || currentItem?.borrowerID != -1)
            {
                requestButton.setTitle("Unavailable", for: .normal)
                requestButton.backgroundColor = UIColor.lightGray
                requestButton.isEnabled = false
                messageButton.isHidden = true
            }
            else
            {
                requestButton.setTitle("Request", for: .normal)
                messageButton.isHidden = true
            }
        }
        
        
        
        
    }else{
        messageButton.isHidden = true
        requestButton.isHidden = true
        
        }
        
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        
        print("here")
        
        if(user?.userID == currentItem?.ownerID && currentItem?.request == 1){
            let declineRequestMessage = DeclineRequestMessage(itemID: (currentItem?.itemID)!, borrowerID: (currentItem?.requestorID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(declineRequestMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
        if(user?.userID==currentItem?.ownerID && currentItem?.returnRequest == 1){
            let returnRequestDeclineMessage = ReturnRequestDeclineMessage(itemID: (currentItem?.itemID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(returnRequestDeclineMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
    }
    
    
    @IBAction func requestItem(_ sender: Any)
    {
        if (currentItem?.ownerID == user?.userID && currentItem?.requestorID != -1 && currentItem?.borrowerID == -1){
            let acceptRequestMessage = AcceptRequestMessage(itemID: (currentItem?.itemID)!, borrowerID: (currentItem?.requestorID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(acceptRequestMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
        if(currentItem?.borrowerID == user?.userID && currentItem?.returnRequest == 0){
            let returnRequestMessage = ReturnRequestMessage(itemID: (currentItem?.itemID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(returnRequestMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
        if(currentItem?.ownerID==user?.userID && currentItem?.borrowerID != -1 && currentItem?.returnRequest == 1){
            let returnRequestAcceptMessage = ReturnRequestAcceptMessage(itemID: (currentItem?.itemID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(returnRequestAcceptMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
        if(currentItem?.ownerID != user?.userID && currentItem?.request == 0 && currentItem?.borrowerID == -1){
            let requestItemMessage = RequestItemMessage(itemID: (currentItem?.itemID)!, requestorID: (user?.userID)!)
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(requestItemMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
        if(currentItem?.borrowerID == user?.userID && currentItem?.returnRequest==0){
            let returnRequestMessage = ReturnRequestMessage(itemID: (currentItem?.itemID)!)
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(returnRequestMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func websocketDidConnect(socket: WebSocketClient) {
        print("request item socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("request socket disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        //print("request received text: \(text)")
        
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let message = try! decoder.decode(Message.self, from: jsonText)
        print("message received:  \(message.message)" )
        
        if(message.message == "valid acceptRequest"){
            //requestButton.setTitle("Accepted", for: .normal)
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
            
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
        }
        else if(message.message == "valid requestItem")
        {
            requestButton.setTitle("Requested", for: .normal)
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
        }
        else if(message.message == "valid returnRequest"){
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
        }
        else if(message.message == "valid returnRequestAccept"){
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
            
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
        }
        else if(message.message == "valid returnRequestDecline"){
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
            
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
            
        }
        else if(message.message == "valid declineRequest"){
            requestButton.isEnabled = false
            requestButton.backgroundColor = UIColor.lightGray
            
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
        }
        
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("request item received data \(data)" )
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
