//
//  Signable.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 This protocol marks an order object that can be signed
 */
public protocol Signable : class
{
    /**
     Signing state of the object. Can be used to get current information about signing state and initiate the signing process
     */
    var signing : SigningObject? {get set}
    /**
     Signing URL without the `/sign/{id}` part.
     */
    var signUrl : String {get}
    
}





