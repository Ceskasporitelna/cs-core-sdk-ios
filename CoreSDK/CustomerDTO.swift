//
//  CustomerDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class CustomerDTO: ApiDTO
{
    var customerId:       String?
    var firstname:        String?
    var lastname:         String?
    var degree:           String?
    var additionalDegree: String?
    var status:           StatusDTO?
    
    //--------------------------------------------------------------------------
    init(customerId: String, firstname: String, lastname: String, degree: String, additionalDegree: String, status: StatusDTO)
    {
        self.customerId       = customerId;
        self.firstname        = firstname;
        self.lastname         = lastname;
        self.additionalDegree = additionalDegree;
        self.status           = status;
        
        super.init()
    }
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init(map)
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        self.customerId       <- map["customerId"]
        self.firstname        <- map["firstname"]
        self.lastname         <- map["lastname"]
        self.degree           <- map["degree"]
        self.additionalDegree <- map["additionalDegree"]
        self.status           <- map["status"]
    }
}
