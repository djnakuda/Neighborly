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

class SignupViewController: UIViewController,UITextFieldDelegate,WebSocketDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password1Field: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Signup Socket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Signup Socket disconnected. error: \(error)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Signup received text: \(text) \n")
        
        let jsonText = text.data(using: .utf8)!
        let decoder = JSONDecoder()
        let userInfo = try! decoder.decode(UserInfoMessage.self, from: jsonText)
        print("userID received:  \(userInfo.userID)" )
        print("message received:  \(userInfo.message)" )
        
        if(userInfo.message == "valid"){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = appDelegate.centerContainer
            let user = User(userID: userInfo.userID!, name: userInfo.name!, email: userInfo.email!,image:nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAccount"), object: nil)
            user.saveUser()
        }else if (userInfo.message == "invalid"){
            submitButton.isEnabled = true
            errorLabel.text = "Email is Taken"
            emailField.text = ""
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("login received data: \(data)")
    }
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.delegate = self
        
        submitButton.isEnabled = false
        self.nameField.delegate = self
        self.password1Field.delegate = self
        self.password2Field.delegate = self
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
    
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        let encoder = JSONEncoder()
        submitButton.isEnabled = false
        let signupMessage = SignupMessage(messageID: "signUp", message: "", name: nameField.text!, email: emailField.text!, password: password1Field.text!)
        do{
            let data = try encoder.encode(signupMessage)
            socket.write(string: String(data: data, encoding: .utf8)!)
            
        }catch{
            
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(nameField.text != "" && emailField.text != "" && password1Field.text! != "" && password2Field.text! != ""){
            if(password1Field.text == password2Field.text){
                submitButton.isEnabled = true
            }else{
                errorLabel.text = "Passwords Did Not Match"
                password1Field.text = ""
                password2Field.text = ""
            }
            
        }else{
            submitButton.isEnabled = false
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
