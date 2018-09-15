//
//  Message.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class Message:NSObject,Codable{
    var message:String
    init(message:String){
        self.message = message
    }
    
}
