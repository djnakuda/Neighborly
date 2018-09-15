//
//  UserInfoMessage.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

struct UserInfoMessage:Codable{
    
    var userID:NSInteger?
    
    var name:String?
    
    var email:String?
    var imageURL:String?
    var myItems:[Item]?
    var borrowedItems:[Item]?
    var message:String
    
}
