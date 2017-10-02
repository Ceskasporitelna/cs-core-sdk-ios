//
//  MigrationKeychainData.swift
//  CSCoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 29/09/2017.
//  Copyright © 2017 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
class MigrationKeychainData
{
    var encryptionKey:                                         String!
    var lockType:                                              LockType!
    var clientId:                                              String!
    var deviceFingerprint:                                     String!
    var oneTimePasswordKey:                                    String!
    var refreshToken:                                          String!
    
    //--------------------------------------------------------------------------
    init()
    {
        self.encryptionKey        = String()
        self.lockType             = .noLock
        self.clientId             = String()
        self.deviceFingerprint    = String()
        self.oneTimePasswordKey   = String()
        self.refreshToken         = String()
    }
    
}
