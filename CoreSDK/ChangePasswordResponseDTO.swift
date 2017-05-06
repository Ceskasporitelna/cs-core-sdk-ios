//
//  ChangePasswordResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class ChangePasswordResponseDTO: ApiDTO
{
    var remainingAttempts:     Int?
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        self.remainingAttempts     <- map["remainingAttempts"]
    }
}
