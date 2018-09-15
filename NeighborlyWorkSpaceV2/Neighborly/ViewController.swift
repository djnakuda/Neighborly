//
//  ViewController.swift
//  Neighborly
//
//  Created by Other users on 4/1/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import Starscream
import CoreLocation
import Cloudinary
import GooglePlacePicker



class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    
    private var model = ItemsModel.shared
    public var user:User?
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var addPostButton: UIBarButtonItem!
    private var selectedItem:Item?
    var placesClient:GMSPlacesClient!
    
    var locationLatitude:Double = 0
    var locationLongitude:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = loadUser()
        if(user?.email == "guest" && addPostButton != nil){
            addPostButton.isEnabled = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateResults), name: NSNotification.Name(rawValue: "loadSearchResults"), object: nil)
        
        placesClient = GMSPlacesClient.shared()
        
        socket.delegate = self
        self.searchResultTableView?.rowHeight = 134
        
        
        searchCurrentPlace()
        
        
    }
    
    
    func searchCurrentPlace() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.locationLatitude = place.coordinate.latitude
                    self.locationLongitude = place.coordinate.longitude
                     let searchItemMessage = SearchItemMessage(searchTerm: "", longitude: self.locationLongitude, latitude: self.locationLatitude , distance: 10 )
                    
                    let encoder = JSONEncoder()
                    
                    do{
                        let data = try encoder.encode(searchItemMessage)
                        socket.write(string: String(data: data, encoding: .utf8)!)
                    }catch{}
                
                
                
                
                }
            }
           
            
            
            
        })
        
        
    }
    
    
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("viewController socket is connected")
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("viewController socket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        print("viewController some text: \(text)")
        
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let message = try! decoder.decode(Message.self, from: jsonText)
        if(message.message == "invalid"){
            return
        }
        let itemList = try! decoder.decode(ItemList.self, from: jsonText)
        print("view controller received:  \(itemList.message)" )
        
        if(itemList.message == "valid"){
            
            model.setSearchResultItems(items: itemList.itemList)
            for item in itemList.itemList{
                print("\n\n\nitem url:   \(item.imageURL) ")
                
            }
            if(searchResultTableView != nil){
                searchResultTableView.reloadData()
            }
            
            updateResults()
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("viewController got some data: \(data.count)")
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("table view rows")
        return model.searchResultItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let item = model.searchResultItems[indexPath.row]
            let cell =  tableView.dequeueReusableCell( withIdentifier: "itemCard", for: indexPath) as! ItemCardTableViewCell
       
            cell.itemName.text = item.itemName
            cell.itemDetails.text = item.itemDescription
        
        
        
            
            let itemCoordinate = CLLocation(latitude: item.latitude, longitude: item.longitude)
        let userCoordinate = CLLocation(latitude: self.locationLatitude, longitude: self.locationLongitude)
        
            print("user coordinat:  \(userCoordinate)")
            print("item coordinate: \(itemCoordinate) ")
        let distanceInMeters = userCoordinate.distance(from: itemCoordinate)
        
            print("user: \(user?.name) distance from item: \(item.itemName)  is \(distanceInMeters) ")
        
        
        let distanceInMiles:NSInteger = NSInteger(distanceInMeters/1609)
        
            
            cell.itemStatusLabel.text = String(distanceInMiles) + " miles"
        
            
            if(item.imageURL != ""){
                let url = URL(string: item.imageURL)
                let data = try? Data(contentsOf: url!)
                cell.itemPhoto.image =  UIImage(data: data!)
            }
        
        
            if(item.ownerID == user?.userID){
                let label = cell.itemStatusLabel
                label?.text = "My Item"
                label?.backgroundColor = UIColor.blue
                label?.textColor = UIColor.white
                label?.layer.cornerRadius = 6
                label?.layer.masksToBounds = true
                
            }
        
        
        
            return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.selectedItem = model.searchResultItems[indexPath.row]
        
            self.performSegue(withIdentifier: "itemDescriptionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "itemDescriptionSegue" ){
            let itemDescriptionVC = segue.destination as! ItemDescriptionViewController
            itemDescriptionVC.currentItem = selectedItem
        }
    }
    
    @objc func updateResults(){
        print("\n\nupdate results")
        
        if(searchResultTableView != nil){
            searchResultTableView.reloadData()
        }
    }
    
    
    deinit {
        print("viewcontroller deinit called")
        socket.delegate = nil
    }
   
    
   
    @IBAction func MenuTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate  as! AppDelegate
        appDelegate.centerContainer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    

}

