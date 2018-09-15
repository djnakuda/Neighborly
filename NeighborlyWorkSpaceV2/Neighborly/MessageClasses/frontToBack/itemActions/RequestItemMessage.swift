//
//  RequestItemMessage.swift
//  Neighborly
//
//  Created by Avni Barman on 4/17/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class RequestItemMessage: Codable{
    
    var itemID: NSInteger
    var requestorID: NSInteger
    var messageID: String
    
    init(itemID:NSInteger, requestorID:NSInteger){
        self.itemID = itemID
        self.requestorID = requestorID
        self.messageID = "requestItem"
    }
    
}
