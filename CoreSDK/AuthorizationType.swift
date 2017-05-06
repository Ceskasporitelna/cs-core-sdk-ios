//
//  AuthorizationType.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 Authorization type of the given
 */
public enum AuthorizationType : String{
    /**
     Authorization using one time password
     */
    case TAC = "TAC"
    /**
     Authorization using mobile CASE application
     */
    case MobileCase = "CASE_MOBILE"
    /**
     Authorization using no additional verification method
     */
    case NoAuthorization = "NONE"
    
}

