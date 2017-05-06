//
//  Sortable.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public protocol Sortable{
    associatedtype TSortableFields : HasFieldName
    var sortBy : Sort<TSortableFields>? {get set}
}

public protocol HasFieldName{
    var fieldName: String {get}
}

//--------------------------------------
public enum SortDirection
{
    case ascending
    case descending
    
    public var value:String {
        switch self {
        case .ascending:
            return "asc"
        case .descending:
            return "desc"
            
        }
    }
}

//--------------------------------------
public class Sort<TSortableFields:HasFieldName>
{
    public var sortByFields : [(String,SortDirection)]
    
    public init(by: [(String,SortDirection)]){
        self.sortByFields = by
    }
    
    public init(by: [(TSortableFields,SortDirection)]){
        self.sortByFields = by.map({($0.0.fieldName,$0.1)})
    }
    
    public func addSortParams( _ originalParams:[String:AnyObject]) -> [String:AnyObject]
    {
        var params = originalParams
        params["sort"] = self.sortByFields.map({$0.0}).joined(separator: ",") as AnyObject?
        params["order"] = self.sortByFields.map({$0.1.value}).joined(separator: ",") as AnyObject?
        return params
    }
}
