//
//  InstanceResource.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

open class InstanceResource : Resource{
    
    public let id : AnyObject
    
    public init(id : Any!,path : String, client : WebApiClient)
    {
        if (id == nil) {
            assert( false, "id must not be nil!")
        }
        
        self.id = id as AnyObject
        super.init(path: path + "/\(self.id)", client: client)
    }
}
