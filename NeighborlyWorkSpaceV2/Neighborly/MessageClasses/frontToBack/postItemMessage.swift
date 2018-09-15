//
//  postItemMessage.swift
//  Neighborly
//
//  Created by Other users on 4/15/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class PostItemMessage:Codable{
    
    var messageID:String
    var ownerID:NSInteger
    var itemName:String
    var imageURL:String
    var itemDescription:String
    var longitude:Double
    var latitude:Double
    
    init(ownerID:NSInteger, imageURL:String, itemName:String, itemDescription:String, longitude:Double, latitude:Double ){
        
        self.messageID = "postItem"
        self.imageURL = imageURL
        self.ownerID = ownerID
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.longitude = longitude
        self.latitude = latitude
        
    }
    
    
}
