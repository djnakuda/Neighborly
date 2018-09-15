//
//  PostViewController.swift
//  Neighborly
//
//  Created by Other users on 4/9/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import Starscream
import Cloudinary
import GooglePlacePicker
import GoogleMaps

class PostViewController: UIViewController, UITextFieldDelegate,UITextViewDelegate,WebSocketDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    private var model = ItemsModel.shared
    @IBOutlet weak var myImageView: UIImageView!
    public var user:User?
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    var encodedImg:String = ""
    var imageData:Data?
    
    var placesClient:GMSPlacesClient!
    
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var locationPickerButton: UIButton!
    
    var locationLatitude: Double!
    var locationLongitude: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        placesClient = GMSPlacesClient.shared()
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        locationLatitude = 0
        locationLongitude = 0
        self.user = loadUser()!
        postButton.setTitleColor(UIColor.white, for: .disabled)
        itemNameField.delegate = self
        descriptionTextView.delegate = self
        postButton.isEnabled = false
        
        currentLocationButton.layer.borderWidth = 0.5
        locationPickerButton.layer.borderWidth = 0.5
        currentLocationButton.layer.borderColor = UIColor.clear.cgColor
        locationPickerButton.layer.borderColor = UIColor.clear.cgColor
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard) )
        self.view.addGestureRecognizer(singleTap)
        // Do any additional setup after loading the view.
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("post socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("post socket disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("post received text: \(text)")
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let itemList = try! decoder.decode(ItemList.self, from: jsonText)
        
        print("message received:  \(itemList.message)" )
        if(itemList.message == "valid"){
           
            model.searchResultItems.append(itemList.itemList.first!)
            dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSearchResults"), object: nil)
            
    
        }else if(itemList.message == "invalid"){
            postButton.isEnabled = true
        }
        
    }
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("post received data \(data)" )
    }
    
    
    @IBAction func importImage(_ sender: Any) {
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
        if(checkComplete() ){
            postButton.isEnabled = true
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        myImageView.image = image
        imageData = UIImageJPEGRepresentation(image, 0.000005)!
        
        picker.dismiss(animated: true, completion: nil)
        
        
        if(checkComplete() ){
            postButton.isEnabled = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "Description     "){
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(checkComplete() ){
            postButton.isEnabled = true
        }else if(descriptionTextView.text == ""){
            descriptionTextView.textColor = UIColor.gray
            descriptionTextView.text = "Description     "
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(checkComplete() ){
            postButton.isEnabled = true
        }
    }
   
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            self.view.endEditing(true)
            return false
        }
        return true
    }

    
    
    
    @IBAction func getCurrentPlace(_ sender: Any) {
        currentLocationButton.layer.borderColor = UIColor.blue.cgColor
        locationPickerButton.layer.borderColor = UIColor.clear.cgColor
        
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
                }
            }
            if(self.checkComplete() ){
                self.postButton.isEnabled = true
            }
        })
        
    }
    
    @IBAction func pickPlace(_ sender: UIButton) {
        currentLocationButton.layer.borderColor = UIColor.clear.cgColor
        locationPickerButton.layer.borderColor = UIColor.blue.cgColor
        let center = CLLocationCoordinate2D(latitude: 34.0213, longitude: -118.2881)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.locationLatitude = place.coordinate.latitude
                self.locationLongitude = place.coordinate.longitude
               
            }
            if(self.checkComplete() ){
                self.postButton.isEnabled = true
            }
        })
    }
    func checkComplete() -> Bool{
        if(itemNameField.text != "" && descriptionTextView.text != "" && descriptionTextView.text != "Description     " && imageData != nil && locationLongitude != 0 && locationLatitude != 0){
            return true
        }
        return false
    }
    
    @IBAction func PostSubmitted(_ sender: Any) {
        self.postButton.isEnabled = false
        
        cloudinary.createUploader().upload(data: imageData!, uploadPreset: "szxnywdo"){
            result, error in
            let imageURL = result?.url
            print("account profile image upload error:  \(String(describing: error))")
            print("account profile image result: \(String(describing: result?.publicId))")
            
            
            let postItemMessage = PostItemMessage( ownerID: self.user!.userID , imageURL: imageURL!, itemName: self.itemNameField.text!, itemDescription: self.descriptionTextView.text!, longitude: self.locationLongitude, latitude: self.locationLatitude)
            
            let encoder = JSONEncoder()
            
            do{
                let data = try encoder.encode(postItemMessage)
                socket.write(string: String(data: data, encoding: .utf8)!)
            }catch{ }
            
            
        }
        
        
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
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
