//
//  persistance.swift
//  Neighborly
//
//  Created by Other users on 4/15/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation




func loadUser() -> User?{
    return NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User
}






