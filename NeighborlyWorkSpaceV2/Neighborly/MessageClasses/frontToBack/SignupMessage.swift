//
//  SignupMessage.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class SignupMessage: Codable{
    
    var name: String
    var email: String
    var password: String
    var messageID:String?
    var message:String
    
    init(messageID:String,message:String, name:String, email:String, password:String ){
        
        self.name = name
        self.email = email
        self.password = password
        self.message = message
        self.messageID = messageID
        
    }
    
}
