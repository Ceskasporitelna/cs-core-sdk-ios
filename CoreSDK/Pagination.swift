//
//  Pagination.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public protocol Paginated:Dictionarizable{
    var pagination:Pagination? {get set}
}

public struct Pagination{
    let pageNumber:UInt
    let pageSize:UInt
    
    public init(pageNumber:UInt, pageSize:UInt){
        self.pageNumber = pageNumber
        self.pageSize = pageSize
    }
    
    internal func addPaginationParams( _ originalParams:[String:AnyObject]) -> [String:AnyObject] {
        var params     = originalParams
        params["page"] = self.pageNumber as AnyObject?
        params["size"] = self.pageSize as AnyObject?
        return params
    }
    
}

public struct ResponsePagination{
    public let pageNumber : UInt
    public let pageSize : UInt
    public let pageCount : UInt
    public let nextPageNumber : UInt?
    public let hasNextPage : Bool
    
    init(pageNumber : UInt, pageSize : UInt, pageCount :  UInt, nextPageNumber : UInt?){
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.pageNumber = pageNumber
        self.nextPageNumber = nextPageNumber
        self.hasNextPage = nextPageNumber != nil
    }
}
