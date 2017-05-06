//
//  ChangePasswordRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

//==============================================================================
class ChangePasswordRequestDTO: ApiDTO
{
    var clientId:          String?
    var oldPassword:       String?
    var newPassword:       String?
    var deviceFingerprint: String?
    var nonce:             String?
    
    //--------------------------------------------------------------------------
    init(clientId: String, oldPassword: String, newPassword: String, deviceFingerprint: String, scope: String, nonce: String)
    {
        self.clientId          = clientId;
        self.oldPassword       = oldPassword;
        self.newPassword       = newPassword;
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
        self.oldPassword       <- map["password"];
        self.newPassword       <- map["newPassword"];
        self.deviceFingerprint <- map["deviceFingerprint"];
        self.nonce             <- map["nonce"];
    }
}
