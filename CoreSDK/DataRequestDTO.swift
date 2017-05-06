//
//  DataRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class DataRequestDTO: ApiDTO
{
    var session: String?
    var data:    String?
    
    //--------------------------------------------------------------------------
    init(session: String, data: String)
    {
        self.session = session;
        self.data    = data;
        
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override init()
    {
        super.init();
    }
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        session       <- map["session"]
        data          <- map["data"]
    }
}
