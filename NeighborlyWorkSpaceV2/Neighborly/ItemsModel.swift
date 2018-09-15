//
//  Items.swift
//  Neighborly
//
//  Created by Other users on 4/11/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import Foundation

class ItemsModel{
    
    static let shared = ItemsModel()
    public var borrowedItems: [Item]
    public var myItems: [Item]
    public var searchResultItems: [Item]
    public var currentItem: Item

    
    
    public func setBorrowedItems(items: [Item]){
        self.borrowedItems = items
    }
    public func setMyItems(items: [Item]){
        self.myItems = items
    }
    public func setSearchResultItems(items:[Item]){
        self.searchResultItems = items
    }
    
    public init(){
        borrowedItems = [Item]()
        myItems = [Item]()
        searchResultItems = [Item]()
        
        let camera = Item(name: "Camera", itemID: 1,imageURL: "", available: 1, description: "Sample Camera", longitude: 6.7, latitude: 7.8, ownerID: 1, borrowerID: 2 ,  request: 0, requestorID: 0, returnRequest: 0)
        
       
        currentItem = camera
        searchResultItems.append(camera)
        borrowedItems.append(camera )
        myItems.append(camera )
       
        
    }
}
