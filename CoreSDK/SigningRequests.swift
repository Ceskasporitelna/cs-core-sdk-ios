//
//  InitialSigningRequest.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

class InitializeSigningRequest : WebApiEntity
{
    var authorizationType: String!
    
    override init(){
        super.init()
    }
    
    required init?(_ map: Map)
    {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
        self.authorizationType <- map["authorizationType"]
    }
    
}

class FinalizeTACSigningRequest : InitializeSigningRequest
{
    var oneTimePassword: String!
    
    
    override init(){
        super.init()
    }
    
    required init?(_ map: Map)
    {
        super.init(map)
    }
    
    override func mapping(_ map: Map) {
        super.mapping(map)
        self.oneTimePassword <- map["oneTimePassword"]
    }
}
