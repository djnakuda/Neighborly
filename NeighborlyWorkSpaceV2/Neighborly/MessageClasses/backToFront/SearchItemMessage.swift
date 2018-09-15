//
//  SearchItemMessage.swift
//  Neighborly
//
//  Created by Other users on 4/15/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class SearchItemMessage:Codable{
    
    var messageID:String
    var searchTerm:String
    var longitude:Double
    var latitude:Double
    var distance:NSInteger
    
    init( searchTerm:String, longitude:Double, latitude:Double, distance: NSInteger){
        
        self.messageID = "searchItem"
       self.searchTerm = searchTerm
        self.longitude = longitude
        self.latitude = latitude
        self.distance = distance
    }
    
    
}
