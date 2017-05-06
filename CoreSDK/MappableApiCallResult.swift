//
//  MappableApiCallResult.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 26/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 This is a non-generic equivalent of ApiCallResult used for global transformations where the genericity is not known in the function performing the transformation at compile time
 */
public enum MappableApiCallResult
{
    case success(Mappable,ApiCallResponse)
    case failure(NSError, ApiCallResponse)
    
    static func fromApiCallResult<T:Mappable>(_ response : ApiCallResult<T>) -> MappableApiCallResult{
        switch response {
        case .success(let (mappableEntity, response)):
            return MappableApiCallResult.success(mappableEntity,response)
        case .failure(let (error, object)):
            return MappableApiCallResult.failure(error,object)
        }
    }
    
    func toApiCallResult<T:Mappable>(_ response : ApiCallResult<T>) -> ApiCallResult<T>
    {
        switch self {
        case .success(let (_,apiResponse)):
            switch response {
            case .success(let (entity, _)):
                return ApiCallResult.success(entity,apiResponse)
            case .failure(let (error,object)):
                return ApiCallResult.failure(error,object)
            }
        case .failure(let error,let object):
            return ApiCallResult.failure(error,object)
        }
    }
}
