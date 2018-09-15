//
//  UpdateUserPhotoMessage.swift
//  Neighborly
//
//  Created by Other users on 4/16/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class UpdateUserPhotoMessage:Codable{
    
    var messageID:String
    var userID:NSInteger
    var imageURL:String
    
    init(userID:NSInteger,imageURL:String){
        self.messageID = "updateUserPhoto"
        self.imageURL = imageURL
        self.userID = userID
    }
}
