//
//  UnlockOTPResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
class UnlockOTPResponseDTO: ApiDTO
{
    var encryptionKey:         String?
    var accessToken:           String?
    var accessTokenExpiration: NSNumber?
    var refreshToken:          String?
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override func mapping(_ map: Map)
    {
        self.encryptionKey         <- map["encryptionKey"]
        self.accessToken           <- map["accessToken"]
        self.accessTokenExpiration <- map["accessTokenExpiration"]
        self.refreshToken          <- map["refreshToken"]
    }
    
    //--------------------------------------------------------------------------
    func isLoginSuccessful() -> Bool
    {
        return (self.encryptionKey ?? "").isEmpty
    }
}
