//
//  Parameters.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public protocol Dictionarizable{
    func toDictionary(_ existingParams:[String:AnyObject]?)->[String:AnyObject]
}

open class Parameters : Dictionarizable{
    
    public init(){
        
    }
    
    open func toDictionary(_ existingParams:[String:AnyObject]?)->[String:AnyObject]{
        var params = [String:AnyObject]()
        if let p = existingParams{
            params = p
        }
        
        if existingParams == nil{
            params = [String:AnyObject]()
        }
        if let paginated = self as? Paginated{
            if let pagination = paginated.pagination{
                params = pagination.addPaginationParams(params)
            }
        }
        
        return params
    }
   
}
