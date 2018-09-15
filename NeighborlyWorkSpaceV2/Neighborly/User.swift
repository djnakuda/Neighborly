//
//  User.swift
//  Neighborly
//
//  Created by Other users on 4/14/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit
import os.log
import SendBirdSDK


struct PropertyKey {
    static let userID = "userID"
    static let name = "name"
    static let email = "email"
    static let image = "image"
}



class User: NSObject, NSCoding{
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("user")
    
    public func saveUser() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: User.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("User successfully saved.", log: OSLog.default, type: .debug)
            print("user succesfully saved")
        } else {
            os_log("Failed to save user...", log: OSLog.default, type: .error)
            print("Failed to save user")
        }
    }
    
   
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userID,forKey:PropertyKey.userID)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(email, forKey: PropertyKey.email)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let userID = aDecoder.decodeInteger(forKey: PropertyKey.userID)
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
        let email = aDecoder.decodeObject(forKey: PropertyKey.email) as? String
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        self.init(userID: userID, name: name!, email:email!, image: image)
    }
    
    var userID:NSInteger
    var name:String
    var image:UIImage?
    var email:String

    
    init(userID:NSInteger,name:String,email:String, image:UIImage?){
        self.userID = userID
        self.name = name
        self.email = email
        self.image = image
        super.init()
    }
    
    
    
    func setImage(image:UIImage?){
        self.image = image
    }
}
