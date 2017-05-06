//
//  CustomWebApiError.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 05/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
@testable import CSCoreSDK

//Custom errors should inherit from CoreSDKError for easier handling by the end-developer.
class CustomWebApiError : CoreSDKError{
    static let errorCodeKey = "errorCode";
    static let errorMessageKey = "errorMessage";
    
    var errorCode : String?{
        return userInfo[CustomWebApiError.errorCodeKey] as? String
    }
    var errorMessage : String?{
        return userInfo[CustomWebApiError.errorMessageKey] as? String
    }
    init(statusCode : Int, dict : [String : AnyObject]){
        super.init(domain: "CustomErrorDomain", code: statusCode, userInfo: dict)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
