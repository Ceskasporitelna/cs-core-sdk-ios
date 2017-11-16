//
//  CoreSDKError.swift
//  CoreSDKApp
//
//  Created by Vladimír Nevyhoštěný on 24.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


public enum CoreSDKErrorKind: Int
{
    /*
     * Common CoreSDKError. Check the underlying error, if exists.
     */
    case other                                = 1
    
    /*
     * Empty data while decrypting
     */
    case emptyData                            = 2
    
    /*
     * Empty password while decrypting
     */
    case emptyPassword                        = 3
    
    /*
     * Data decryption failed
     */
    case decryptFailed                        = 4
    
    /*
     * Data encryption failed
     */
    case enryptFailed                         = 5
    
    /*
     * No pages returned when paginated result expected.
     */
    case noPagesError                         = 6
    
    
    /*
     * Operation has been canceled by the user.
     */
    case operationCancelled                   = 7
    
    /*
     * File download failure.
     */
    case fileDownloadFailed                   = 8
    
    /*
     * File upload failure.
     */
    case attachmentUploadFailed               = 9
    
    /*
     * Network is not available
     */
    case networkNotAvailable                  = -101
    
    /*
     * Network available, but another network error ocured. See underlying error.
     */
    case networkError                         = -102
    
    /*
     * No http response. Maybe a network or DNS error.
     */
    case noResponse                           = -103
    
    /*
     * Internal error. Indicates empty JSON response data, which may be not an error.
     */
    case emptyJSONBody                        = -6006
}


//==============================================================================
public class CoreSDKError: CSErrorBase
{
    override class public var ERROR_DOMAIN : String {
        return "cz.csas.coresdk"
    }
    
    override class public var locatizationDictionary : [Int:String] {
        return _errorDictionary
    }
    
    fileprivate static let _errorDictionary: [Int:String] = [
        CoreSDKErrorKind.other.rawValue:                      CoreSDK.localized( "err-other" ),
        CoreSDKErrorKind.emptyData.rawValue:                  CoreSDK.localized( "err-empty-data"),
        CoreSDKErrorKind.emptyPassword.rawValue:              CoreSDK.localized( "err-empty-password" ),
        CoreSDKErrorKind.decryptFailed.rawValue:              CoreSDK.localized( "err-decryption-failed" ),
        CoreSDKErrorKind.enryptFailed.rawValue:               CoreSDK.localized( "err-encryption-failed" ),
        CoreSDKErrorKind.noPagesError.rawValue:               CoreSDK.localized( "err-no-panination-set" ),
        CoreSDKErrorKind.noResponse.rawValue:                 CoreSDK.localized( "err-server-unavailable" ),
        CoreSDKErrorKind.operationCancelled.rawValue:         CoreSDK.localized( "err-operation-cancelled" ),
        CoreSDKErrorKind.fileDownloadFailed.rawValue:         CoreSDK.localized( "err-file-download-failed" ),
        CoreSDKErrorKind.attachmentUploadFailed.rawValue:     CoreSDK.localized( "err-attachment-upload-failed" ),
        CoreSDKErrorKind.networkNotAvailable.rawValue:        CoreSDK.localized( "err-network-not-available" ),
        CoreSDKErrorKind.networkError.rawValue:               CoreSDK.localized( "err-network-error" ),
        CoreSDKErrorKind.emptyJSONBody.rawValue:              CoreSDK.localized( "err-empty-json" )
    ]
    
    public var kind : CoreSDKErrorKind {
        if let kind = CoreSDKErrorKind(rawValue: self.code) {
            return kind
        }
        return CoreSDKErrorKind.other
    }

    /*
     * Can contain dictionary with server error info
     */
    public var serverErrorInfo: [String:AnyObject]?
    

    public class func isError( _ error: NSError, ofKind kind: CoreSDKErrorKind ) -> Bool
    {
        return ( error is CoreSDKError && ( error as! CoreSDKError ).kind == kind )
    }
    
    //--------------------------------------------------------------------------
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder )
    }
    
    init( errorCode code: Int )
    {
        super.init( domain: type(of: self).ERROR_DOMAIN, code: code, userInfo:Dictionary() )
    }
    
    init( kind: CoreSDKErrorKind )
    {
        super.init( domain: type(of: self).ERROR_DOMAIN, code: kind.rawValue, userInfo:Dictionary() )
    }
    
    //--------------------------------------------------------------------------
    public override init(domain errorDomain: String, code errorCode: Int, userInfo dict: [String: Any]?)
    {
        super.init( domain:errorDomain, code:errorCode, userInfo:dict as [String : Any]? )
    }
    
    class public func errorWithCode( _ errorCode: Int, underlyingError: NSError? ) -> CoreSDKError?
    {
        if let error: NSError = underlyingError {
            return CoreSDKError(domain: CoreSDKError.ERROR_DOMAIN, code:errorCode, userInfo:error.userInfo)
        }
        else {
            return CoreSDKError( errorCode: errorCode )
        }
    }
    
    class public func errorOfKind( _ kind: CoreSDKErrorKind ) -> CoreSDKError
    {
        return CoreSDKError(kind: kind)
    }
    
    class public func errorOfKind( _ kind: CoreSDKErrorKind, underlyingError: NSError? ) -> CoreSDKError
    {
        if let error: NSError = underlyingError {
            return CoreSDKError(domain: CoreSDKError.ERROR_DOMAIN, code:kind.rawValue, userInfo:[NSUnderlyingErrorKey:error])
        }
        else {
            return CoreSDKError(kind: kind)
        }
        
    }

    class public func errorWithCode( _ errorCode: Int ) -> CoreSDKError?
    {
        return ( ( errorCode == 0 ) ? nil : CoreSDKError( errorCode:errorCode ) )
    }
    
    
}
