//
//  ApiCallResult.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 05/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

public enum ApiCallResult<T>{
    
    case success(T,ApiCallResponse)
    case failure(NSError,ApiCallResponse)
    
    public func toCoreResult()->CoreResult<T>{
        switch self {
        case .success(let (object,_)):
            return CoreResult.success(object)
        case .failure(let (error,_)):
            return CoreResult.failure(error)
        }
    }
    
}



