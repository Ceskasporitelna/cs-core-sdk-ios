//
//  UrlUtils.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 07/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


public class UrlUtils{
    
    public static func toQueryString(_ parameters : [String:AnyObject]?) -> String
    {
        if parameters == nil || parameters?.count == 0 {
            return ""
        }
        var pairs : [String] = []
        for (k,v) in parameters!{
            pairs.append("\(k)=\(v)")
        }
        return "?\(pairs.joined(separator: "&"))"
    }
    
    public static func urlWithParameters(_ path : String, parameters : [String:AnyObject]?) -> String
    {
        let queryString = toQueryString(parameters)
        return "\(path)\(queryString)"
    }
    
    /**
     Constructs a relative URL to the given basePath
     
     - returns: A constructed absolute url as a string or nil if the construction fails
    */
    public static func urlFromBasePath(_ basePath:String, relativePath:String) -> String?{
        var normalizedBasePath = basePath
        if !basePath.hasSuffix("/"){
            normalizedBasePath = "\(basePath)/"
        }
        let baseUrl = URL(string: normalizedBasePath)!
        let signUrl = URL(string: relativePath, relativeTo: baseUrl)
        return signUrl?.absoluteString
    }
    
}
