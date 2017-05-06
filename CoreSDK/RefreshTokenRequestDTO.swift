//
//  RefreshTokenRequestDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class RefreshTokenRequestDTO: ApiDTO
{
    var code:         String?
    var clientId:     String?
    var clientSecret: String?
    var redirectURI:  String?
    var grantType:    String?
    var refreshToken: String?
    
    //--------------------------------------------------------------------------
    init( code: String, clientId: String, clientSecret: String, redirectURI: String, grantType: String, refreshToken: String )
    {
        self.code         = code;
        self.clientId     = clientId;
        self.clientSecret = clientSecret;
        self.redirectURI  = redirectURI;
        self.grantType    = grantType;
        self.refreshToken = refreshToken;
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
        self.code         <- map["code"];
        self.clientId     <- map["client_id"];
        self.clientSecret <- map["client_secret"];
        self.redirectURI  <- map["redirect_uri"];
        self.grantType    <- map["grant_type"];
        self.refreshToken <- map["refresh_token"];
    }
}
