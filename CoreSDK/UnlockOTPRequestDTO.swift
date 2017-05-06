//
//  UnlockOTPRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class UnlockOTPRequestDTO: ApiDTO
{
    var clientId:          String?
    var oneTimePassword:   String?
    var deviceFingerprint: String?
    var nonce:             String?
    
    //--------------------------------------------------------------------------
    init(clientId: String, oneTimePassword: String, deviceFingerprint: String, scope: String, nonce: String)
    {
        self.clientId          = clientId;
        self.oneTimePassword   = oneTimePassword;
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
        self.oneTimePassword   <- map["oneTimePassword"];
        self.deviceFingerprint <- map["deviceFingerprint"];
        self.nonce             <- map["nonce"];
    }
}
