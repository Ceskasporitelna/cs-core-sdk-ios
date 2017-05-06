//
//  RegistrationRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class RegistrationRequestDTO: ApiDTO
{
    var code:              String?
    var password:          String?
    var deviceFingerprint: String?
    var scope:             String?
    var nonce:             String?
    
    //--------------------------------------------------------------------------
    init(code: String, password: String, deviceFingerprint: String, scope: String, nonce: String)
    {
        self.code              = code
        self.password          = password
        self.deviceFingerprint = deviceFingerprint
        self.scope             = scope
        self.nonce             = nonce
        
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
        code              <- map["code"]
        password          <- map["password"]
        deviceFingerprint <- map["deviceFingerprint"]
        scope             <- map["scope"]
        nonce             <- map["nonce"]
    }
}
