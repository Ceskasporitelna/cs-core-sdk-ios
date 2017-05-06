//
//  DataResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class DataResponseDTO: ApiDTO
{
    var data: String?
    
    //--------------------------------------------------------------------------
    init(data: String)
    {
        self.data    = data
        super.init()
    }
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        data  <- map["data"]
    }
}
