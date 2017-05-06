//
//  ApiDTO.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 27.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

// MARK: ApiDTO

//==============================================================================
public class ApiDTO: NSObject, Mappable
{
    var resourcePath: String?
    var resourceId:   String? {
        return nil
    }

    //--------------------------------------------------------------------------
    public override init()
    {
        super.init();
    }
    
    // Required by Mappable
    //--------------------------------------------------------------------------
    required public init?(_ map: Map)
    {
        super.init();
    }
    
    // Required by Mappable
    //--------------------------------------------------------------------------
    public func mapping(_ map: Map) { }
    

    //--------------------------------------------------------------------------
    public static func fromJSON<T:Mappable>(_ json:[String:AnyObject]) -> T?
    {
        return Mapper<T>().map(json);
    }
    
    //--------------------------------------------------------------------------
    public static func toJSON<T:Mappable>( _ dto: T? ) -> [String:AnyObject]
    {
        return Mapper<T>().toJSON(dto!);
    }
    
    public static func copyByJSON<T:Mappable>(_ dto:T) -> T{
        return fromJSON(toJSON(dto))!
    }
    
    //--------------------------------------------------------------------------
    public func toJSON() -> [String:AnyObject]
    {
        return ApiDTO.toJSON( self );
    }
    
    //--------------------------------------------------------------------------
    public func toJSONString() -> String
    {
        return Mapper().toJSONString(self, prettyPrint: false)!
    }
    
    //--------------------------------------------------------------------------
    public func toJSONData() -> Data
    {
        let strResult = self.toJSONString()
        return strResult.data(using: String.Encoding.utf8)!
    }
}
