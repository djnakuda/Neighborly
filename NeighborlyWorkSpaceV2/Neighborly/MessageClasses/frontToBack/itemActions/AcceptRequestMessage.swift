//
//  AcceptRequestMessage.swift
//  Neighborly
//
//  Created by Avni Barman on 4/18/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation
class AcceptRequestMessage: Codable{
    
    var itemID: NSInteger
    var borrowerID: NSInteger
    var messageID: String
    
    init(itemID:NSInteger, borrowerID:NSInteger){
        self.itemID = itemID
        self.borrowerID = borrowerID
        self.messageID = "acceptRequest"
    }
    
}
