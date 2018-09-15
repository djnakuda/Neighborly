//
//  LoginMessage.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class LoginMessage: Codable{
   
    var email: String
    var password: String
    var messageID:String
    var message:String
    
    init( message:String, email:String, password:String){
        
        self.email = email
        self.password = password
        self.message = message
        self.messageID = "login"
    }
    
}
