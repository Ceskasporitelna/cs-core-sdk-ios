//
//  KeychainDkDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
public class KeychainDkDTO: ApiDTO
{
    var clientId:           String?
    var deviceFingerprint:  String?
    var lockType:           LockType?
    var oauth2Code:         String?
    var oneTimePasswordKey: String?
    var noAuthTypePassword: String?
    var touchIdToken:       String?
    
    //--------------------------------------------------------------------------
    override init()
    {
        super.init();
    }
    
    init(source : KeychainDkDTO?){
        super.init()
        if let source = source{
            self.clientId           = source.clientId
            self.deviceFingerprint  = source.deviceFingerprint
            self.lockType           = source.lockType
            self.oauth2Code         = source.oauth2Code
            self.oneTimePasswordKey = source.oneTimePasswordKey
            self.noAuthTypePassword = source.noAuthTypePassword
            self.touchIdToken       = source.touchIdToken
        }
    }
    
    //--------------------------------------------------------------------------
    required public init?(_ map: Map)
    {
        super.init(map)
    }
    
    //--------------------------------------------------------------------------
    override public func mapping(_ map: Map)
    {
        self.clientId           <- map["clientId"];
        self.deviceFingerprint  <- map["deviceFingerprint"];
        self.lockType           <- map["lockType"];
        self.oauth2Code         <- map["oauth2Code"];
        self.oneTimePasswordKey <- map["oneTimePassword"];
        self.noAuthTypePassword <- map["noAuthTypePassword"];
        self.touchIdToken       <- map["touchIdToken"];
    }
}
