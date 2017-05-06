//
//  RegistrationResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class RegistrationResponseDTO: ApiDTO
{
    var encryptionKey:          String?
    var clientId:               String?
    var accessToken:            String?   
    var accessTokenExpiration:  NSNumber?
    var refreshToken:           String?
    var oneTimePasswordKey:     String?
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init(map)
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        self.encryptionKey         <- map["encryptionKey"]
        self.clientId              <- map["id"]
        self.accessToken           <- map["accessToken"]
        self.accessTokenExpiration <- map["accessTokenExpiration"]
        self.refreshToken          <- map["refreshToken"]
        self.oneTimePasswordKey    <- map["oneTimePasswordKey"]

    }
}
