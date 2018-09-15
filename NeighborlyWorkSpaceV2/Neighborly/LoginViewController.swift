//
//  LoginViewController.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import Starscream
import SendBirdSDK

class LoginViewController: UIViewController,UITextFieldDelegate,WebSocketDelegate {
    
    @IBOutlet weak var guestLoginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Login Socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Login Socket disconnected")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Login received text: \(text) \n")
        
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let userInfo = try! decoder.decode(UserInfoMessage.self, from: jsonText)
        print("userID received:  \(String(describing: userInfo.userID))" )
        print("userEmail received: \(String(describing: userInfo.email))" )
        print("userName received: \(String(describing: userInfo.name))" )
        print("message received:  \(userInfo.message)" )
        print("\nmy Items received: \(String(describing: userInfo.myItems?.first?.itemName))" )
        
        if(userInfo.message == "valid" && userInfo.userID != nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = appDelegate.centerContainer
            let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            let mainNavController = UINavigationController(rootViewController: mainViewController)
            appDelegate.centerContainer!.centerViewController = mainNavController
            var profileImage = UIImage(named: "DefaultUserIcon")
            if(userInfo.imageURL != "" && userInfo.imageURL != nil){
                let url = URL(string: (userInfo.imageURL)!)
                let data = try? Data(contentsOf: url!)
                profileImage =  UIImage(data: data!)
            }
            let user = User(userID: userInfo.userID!, name: userInfo.name!, email: userInfo.email!, image: profileImage)
            
            user.saveUser()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMenu"), object: nil)
        
            
            
        }else{
            loginButton.isEnabled = true
            errorLabel.text = "Invalid User. Try Again."
            emailField.text = ""
            passwordTextfield.text = ""
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("login received data: \(data)")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
    }
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
         super.viewDidLoad()
       
        socket.delegate = self
        guestLoginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.isEnabled = false
        self.emailField.delegate = self
        self.passwordTextfield.delegate = self
        // Do any additional setup after loading the view.
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(singleTap)
        
        
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    @IBAction func loginClicked(_ sender: Any) {
        loginButton.isEnabled = false
        let loginMessage = LoginMessage( message: "", email: emailField.text!, password: passwordTextfield.text!)
        let encoder = JSONEncoder()
        
        do{
            let data = try encoder.encode(loginMessage)
            socket.write(string: String(data: data, encoding: .utf8)!)
          
        }catch{}
        
        
    }
    @IBAction func guestLoginClicked(_ sender: Any) {
        let loginMessage = LoginMessage( message: "", email: "guest", password: "guest")
        let encoder = JSONEncoder()
        
        do{
            let data = try encoder.encode(loginMessage)
            socket.write(string: String(data: data, encoding: .utf8)!)
        }catch{}
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    func textFieldDidEndEditing(_ textField: UITextField) {
        if(emailField.text != "" && passwordTextfield.text != ""){
            loginButton.isEnabled = true
        }else{
            loginButton.isEnabled = false
        }
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
