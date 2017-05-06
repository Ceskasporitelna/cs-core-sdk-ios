//
//  Resource.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 11.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


open class Resource{
    
    public let client : WebApiClient
    
    public let path :  String
    
    
    public init(path : String, client : WebApiClient){
        self.path = path
        self.client = client
    }
    
    
    public func pathAppendedWith(_ appendix:String?) -> String
    {
        if let appendixString = appendix{
            return self.path + "/" + appendixString
        } else {
            return self.path
        }
    }
    
}









































