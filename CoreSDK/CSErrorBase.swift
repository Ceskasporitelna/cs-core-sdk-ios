//
//  CSErrorBase.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 28/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
public class CSErrorBase: NSError
{
    class public var ERROR_DOMAIN : String {
        return "cz.csas.errorbase"
    }
    
    class public var locatizationDictionary : [Int:String] {
        return _errorDictionary
    }
    
    fileprivate static let _errorDictionary: [Int:String] = [:]
    
    //--------------------------------------------------------------------------
    public var isNetworkError: Bool
    {
        return ( self.code < -100 ) && ( self.code > -200 )
    }

    public var isHttpStatusCode: Bool
    {
        return ( self.code >= 200 ) && ( self.code < 300 )
    }

    public var isHttpError: Bool {
        return ( self.code >= 300 ) && ( self.code < 1000 )
    }
    
    public var isServerError: Bool {
        return ( self.code >= 500 ) && ( self.code < 600 )
    }


    //--------------------------------------------------------------------------
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder )
    }
    
    public override init(domain errorDomain: String, code errorCode: Int, userInfo dict: [AnyHashable: Any]?)
    {
        super.init( domain:errorDomain, code:errorCode, userInfo:dict )
    }

    
    //--------------------------------------------------------------------------
    override public var localizedDescription: String {
        get {
            if let result: String = type(of: self).locatizationDictionary [Int(self.code)] {
                var resultMessage = result
                for info in self.userInfo {
                    if let underlyingError: NSError = info.1 as? NSError  {
                        resultMessage = "\(resultMessage)\n\(underlyingError.localizedDescription)"
                    }
                }
                return resultMessage
            } else if ( self.isHttpStatusCode ) {
                return "HTTP status code \(self.code)"
            } else if ( self.isHttpError ) {
                return "HTTP error code \(self.code)"
            } else {
                return "Unknown error of code:\(self.code)"
            }
        }
    }
    
    //--------------------------------------------------------------------------
    public static func serverErrorDescriptor(responseData: AnyObject) -> String?
    {
        if let responseArray = responseData as? [String:AnyObject] {
            if let errorsArray = responseArray ["errors"] as? [[String:String]] {
                for errorDict in errorsArray {
                    if let serverErrorCode = errorDict ["error"] {
                        return serverErrorCode
                    }
                }
            }
        }
        return nil
    }
}
