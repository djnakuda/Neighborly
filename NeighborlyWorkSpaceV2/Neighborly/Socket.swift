//
//  Socket.swift
//  Neighborly
//
//  Created by Other users on 4/13/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation
import Starscream
import Cloudinary

public var socket = WebSocket(url: URL(string: "ws://localhost:8080/NeighbourlyServer/ws")!,protocols: ["chat"] )

 let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudinaryUrl: "cloudinary://381629818317212:OZBxIMc19HONYe6VpCDL0SX5PCY@neighbourly")!)


