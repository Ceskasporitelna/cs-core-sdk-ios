//
//  ListOfPrimitivesResponse.swift
//  CSCoreSDK
//
//  Created by Marty on 05/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


/**
 The type List of primitives response.
 */
public class ListOfPrimitivesResponse<T>: WebApiEntity{
    
    /**
     Returns list of T of concrete type of primitive type
     Each ListOfPrimitives response should also implement a concrete getItems() method.
     f.e.
     NotesListResponse object should implement
     public List<String> getNotes(){};
     
     @return the items
     */
    
    internal var transform: TransformBase?
    internal var _items: [T]! = []
    internal var itemKey: String
    
    public internal (set) var items : [T]! {
        get{
            return self._items as [T]
        }
        set(value){
            if value != nil{
                self._items = value
            }
        }
    }
    
    public required init?(_ map: Map)
    {
        itemKey = ""
        super.init(map)
    }
    
    public override func mapping(_ map: Map)
    {
        items <- map[ResourceUtils.ItemKey]
    }
    
}
