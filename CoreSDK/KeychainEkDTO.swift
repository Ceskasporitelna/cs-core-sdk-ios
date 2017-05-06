//
//  KeychainEkDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
public class KeychainEkDTO: ApiDTO
{
    
    var accessToken:           String?
    var accessTokenExpiration: NSNumber?
    var refreshToken:          String?
    var tokenType:             String?
    var touchIdToken:          String?

    
    
    //--------------------------------------------------------------------------
    override init()
    {
        super.init();
    }
    
    init(source : KeychainEkDTO?) {
        super.init()
        if let source = source{
            accessToken = source.accessToken
            accessTokenExpiration = source.accessTokenExpiration
            refreshToken = source.refreshToken
            tokenType = source.tokenType
            touchIdToken = source.touchIdToken
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
        self.accessToken           <- map["accessToken"];
        self.refreshToken          <- map["refreshToken"];
        self.tokenType             <- map["tokenType"];
        self.accessTokenExpiration <- map["accessTokenExpiration"];
        self.touchIdToken          <- map["touchIdToken"];
    }
}
