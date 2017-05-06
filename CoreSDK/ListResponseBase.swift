//
//  ListResponseBase.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

/**
 This class serves as a proxy for WebApi classes in CoreSDK that do not know anything about the actual type of stored objects
*/
public class ListResponseBase : WebApiEntity{
    
    internal var _items : [WebApiEntity]! = []
    //The transform that is associated with the list.
    internal var transform : TransformBase?
    internal var itemKey : String
    
    public init(items : [WebApiEntity]){
        self._items = items
        self.itemKey = ""
        super.init()
    }
    
    public required init?(_ map: Map)
    {
        itemKey = ""
        super.init(map)
    }
    
    public override func mapping(_ map: Map)
    {
        super.mapping(map)
    }
    
    internal func setResourceAndPathSuffixToItems()
    {
        _items.forEach { (item) -> () in
            item.resource = self.resource
            item.pathSuffix = self.pathSuffix
        }
    }
    
    
}
