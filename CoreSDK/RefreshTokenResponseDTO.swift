//
//  RefreshTokenResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


//==============================================================================
class RefreshTokenResponseDTO: ApiDTO
{
    //Number of seconds until the token expires
    var expiresIn:                   Int?
    var tokenType:                String?
    var accessToken:              String?
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        self.expiresIn              <- map["expires_in"];
        self.tokenType              <- map["token_type"];
        self.accessToken            <- map["access_token"];
    }
}

