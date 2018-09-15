//
//  AccountInfoMessage.swift
//  Neighborly
//
//  Created by Other users on 4/15/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class AccountInfoMessage:Codable{
    var userID:NSInteger
    var messageID:String


    init( userID:NSInteger){
    
        self.userID = userID
        self.messageID = "accountInfo"
    }

}
