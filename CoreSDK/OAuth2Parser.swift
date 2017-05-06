//
//  OAuth2Parser.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 29.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
public class OAuth2Parser: NSObject
{
    
    public var urlPath : String {
        return self._urlPath;
    }
    
    public var parametres: [String:String] {
        return self._parametres
    }
    
    public var code: String? {
        return self.parametres ["code"]
    }
    
    fileprivate var _urlPath : String!
    fileprivate var _parametres: [String:String] = [:];
    
    //--------------------------------------------------------------------------
    required public init( url: URL )
    {
        self._urlPath = url.absoluteString;
        super.init();
    }
    
    //--------------------------------------------------------------------------
    public func parseResponse() -> CoreResult<Bool>
    {
        let urlComponents = URLComponents(string: self.urlPath)
        
        self._parametres.removeAll()
        
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                self._parametres [queryItem.name] = queryItem.value
            }
            
            if let _ = self.code {
                return CoreResult.success( true )
            }
        }
        
        return CoreResult.failure(LockerError(kind: .wrongOAuth2Url))
    }
    
    
    
}
