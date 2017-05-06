//
//  SigningState.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 Represents current signing state of the order
 */
public enum SigningState: String{
    /**
     Signing is done and the order is confirmed
     */
    case Done = "DONE"
    /**
     Signing was canceled
     */
    case Cancelled = "CANCELLED"
    /**
     Order is open and signing needs to be done
     */
    case Open = "OPEN"
    /**
     Given order cannot be signed at the moment
     */
    case None = "NONE"
    
}