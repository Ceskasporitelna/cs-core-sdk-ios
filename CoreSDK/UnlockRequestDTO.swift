//
//  UnlockRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class UnlockRequestDTO: ApiDTO
{
    var clientId:          String?
    var password:          String?
    var deviceFingerprint: String?
    var nonce:             String?
    
    //--------------------------------------------------------------------------
    init(clientId: String, password: String, deviceFingerprint: String, scope: String, nonce: String)
    {
        self.clientId          = clientId;
        self.password          = password;
        self.deviceFingerprint = deviceFingerprint;
        self.nonce             = nonce;
        
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
        self.clientId          <- map["id"];
        self.password          <- map["password"];
        self.deviceFingerprint <- map["deviceFingerprint"];
        self.nonce             <- map["nonce"];
    }
}
