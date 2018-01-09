//
//  LockerMigrationDataDTO.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 28/09/2017.
//  Copyright © 2017 Applifting. All rights reserved.
//

import Foundation

/**
 * Locker data necessary for unlock locker after migration from some older version.
 */
//==============================================================================
@objc public class LockerMigrationDataDTO: ApiDTO
{
    @objc public var clientId:                         String!
    @objc public var deviceFingerprint:                String!
    @objc public var encryptionKey:                    String!
    @objc public var oneTimePasswordKey:               String!
    @objc public var refreshToken:                     String!
    
    //--------------------------------------------------------------------------
    override public init()
    {
        super.init()
        
        self.clientId                   = String()
        self.deviceFingerprint          = String()
        self.encryptionKey              = String()
        self.oneTimePasswordKey         = String()
        self.refreshToken               = String()
    }

    //--------------------------------------------------------------------------
    required public init?(_ map: Map)
    {
        super.init()
    }
    
    //--------------------------------------------------------------------------
    override public func mapping(_ map: Map)
    {
        self.clientId               <- map["clientId"]
        self.deviceFingerprint      <- map["deviceFingerprint"]
        self.encryptionKey          <- map["encryptionKey"]
        self.oneTimePasswordKey     <- map["oneTimePasswordKey"]
        self.refreshToken           <- map["refreshToken"]
        
        super.mapping(map)
    }
}
