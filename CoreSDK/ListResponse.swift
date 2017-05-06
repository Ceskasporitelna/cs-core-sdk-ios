//
//  ListResponse.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public final class ListResponse<T:WebApiEntity> : ListResponseBase{
    
    public internal(set) var items : [T]! {
        get{
            return self._items as! [T]
        }
        set(value){
            if value != nil {
                self._items = value
            }
        }
    }
    
    public init(items : [T]){
        super.init(items: items)
    }
    
    public required init?(_ map: Map)
    {
        super.init(map)
    }
    
    public override func mapping(_ map: Map)
    {
        items <- map[ResourceUtils.ItemKey]
    }
    
}
