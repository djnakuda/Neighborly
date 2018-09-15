//
//  ReturnRequestMessage.swift
//  Neighborly
//
//  Created by Avni Barman on 4/18/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class ReturnRequestMessage:Codable{
    
    var messageID:String
    var itemID: NSInteger
    
    init(itemID:NSInteger){
        self.messageID = "returnRequest"
        self.itemID = itemID
    }
}
