//
//  StatusDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class StatusDTO: ApiDTO
{
    var pageReference: String?
    var queryLastPage: String?
    var result:        String?
    var totalPageNo:   Int?
    
    //--------------------------------------------------------------------------
    init(pageReference: String, queryLastPage: String, result: String, totalPageNo: Int)
    {
        self.pageReference = pageReference
        self.queryLastPage = queryLastPage
        self.result        = result
        self.totalPageNo   = totalPageNo
        
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
        self.pageReference <- map["pageReference"]
        self.queryLastPage <- map["queryLastPage"]
        self.result        <- map["result"]
        self.totalPageNo   <- map["totalPageNo"]
    }
}
