//
//  ReturnRequestDeclineMessage.swift
//  Neighborly
//
//  Created by Avni Barman on 4/18/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation
class ReturnRequestDeclineMessage: Codable{
    
    var itemID: NSInteger
    var messageID: String
    
    init(itemID:NSInteger){
        self.itemID = itemID
        self.messageID = "returnRequestDecline"
    }
    
}
