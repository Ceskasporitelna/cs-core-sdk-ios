//
//  UnlockResponseDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 20.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


class UnlockResponseDTO: ApiDTO
{
    var accessToken: String?
    var accessTokenExpiration : NSNumber?
    var encryptionKey: String?
    var refreshToken: String?
    var remainingAttempts: Int?
    
    required init?(_ map: Map)
    {
        super.init(map)
    }
    
    override func mapping(_ map: Map)
    {
        self.encryptionKey         <- map["encryptionKey"]
        self.accessToken           <- map["accessToken"]
        self.accessTokenExpiration <- map["accessTokenExpiration"]
        self.refreshToken          <- map["refreshToken"]
        self.remainingAttempts     <- map["remainingAttempts"]
    }
    
    func haveValidAccessToken() -> Bool
    {
        if self.accessToken != nil && !self.accessToken!.isEmpty{
            return true
        }
        return false
    }
}
