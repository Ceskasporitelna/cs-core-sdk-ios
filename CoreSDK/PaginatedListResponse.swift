//
//  PaginatedListResponse.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


public final class PaginatedListResponse<T:WebApiEntity> : ListResponseBase
{
    public typealias TList  = PaginatedListResponse<T>

    public internal(set) var items : [T]! {
        get{
            return self._items as! [T]
        }
        set(value){
            if value != nil{
                self._items = value
            }
        }
    }
    
    public init(items : [T]){
        super.init(items: items)
    }
    
    //MARK: - PAGINATION Properties
    fileprivate var pageNumber:UInt!
    fileprivate var pageSize:UInt!
    fileprivate var pageCount:UInt!
    fileprivate var nextPageNumber:UInt?
    
    public var pagination:ResponsePagination!{
        return ResponsePagination(pageNumber: pageNumber, pageSize: pageSize, pageCount: pageCount, nextPageNumber: nextPageNumber)
    }
    
    internal var paramsObj : Paginated?
    
    
    public func nextPage(_ callback: @escaping (_ result:CoreResult<TList>) -> Void)
    {
        if let nextPageNumber = pagination.nextPageNumber {
            let newPagination = Pagination(pageNumber: nextPageNumber, pageSize: self.pagination.pageSize)
            
            let params = self.parameters != nil ? newPagination.addPaginationParams(self.parameters!) : newPagination.addPaginationParams([:])
            ResourceUtils.CallPaginatedList(self.resource, pathSuffix: self.pathSuffix, itemJSONKey: self.itemKey, parameters: params, transform: self.transform as? WebApiTransform<TList>, callback: callback)
            
        } else {
            callback(CoreResult<TList>.failure( CoreSDKError(kind:.noPagesError)))
        }
    }
    
    required public init?(_ map: Map)
    {
        super.init(map)
    }
    
    override public func mapping(_ map: Map)
    {
        super.mapping(map)
        pageNumber <- map["pageNumber"]
        pageSize <- map["pageSize"]
        pageCount <- map["pageCount"]
        nextPageNumber <- map["nextPage"]
        items <- map[ResourceUtils.ItemKey]
    }
    
}
