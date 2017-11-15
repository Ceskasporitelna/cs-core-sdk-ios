//
//  LockerError.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 16/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
public enum LockerErrorKind: Int
{
    case other                              = 1
    
    /*
     * Parsing of registration URL response failed - probably wrong response URL
     */
    case parseError                         = 1001
    
    /*
     * Wrong registration URL. Maybe empty clientId?
     */
    case emptyClientId                      = 1002
    
    /*
     * Wrong OASuth2 registration response URL - registration code not found.
     */
    case wrongOAuth2Url                     = 1003
    
    /*
     * User registration failed.
     */
    case registrationFailed                 = 1004
    
    /*
     * User login (unlock) failed.
     */
    case loginFailed                        = 1005
    
    /*
     * User password change failed.
     */
    case passwordChangeFailed               = 1006
    
    /*
     * User unregistration failed.
     */
    case userUnregistrationFailed           = 1007
    
    /*
     * Touch ID authentization is not available, i.e. user has not registered fingerprints yet.
     */
    case touchIDNotAvailable                = 1008
    
    /*
     * Unlock with OTP failed.
     */
    case otpUnlockFailed                    = 1009
    
    /*
     * Authentication token is missing. User will be unregistered.
     */
    case noAuthToken                        = 1010
    
    /*
     * Access token is missing.
     */
    case noAccessToken                      = 1011
    
    /*
     * Refresh token or OAuth2 code is missing.
     */
    case noRefreshToken                     = 1012
    
    /*
     * Locker data are corrupted.
     */
    case wrongLockerData                    = 1013
    
    /*
     * User is not registered, but application assumes that yes.
     */
    case userNotRegistered                  = 1014
    
    /*
     * Refresh access token failed. Not used ATM.
     */
    case refreshTokenFailure                = 1015
    
    /*
     * Login/unlock timeout exceeded. Server is not responding.
     */
    case loginTimeOut                       = 1016
    
    /*
     * Login/Unlock has been canceled by the user.
     */
    case loginCanceled                      = 1017   // LockerUI
    
    
    /*
     * Protected data not available, becasuse iOS device is locked.
     */
    case protectedDataNotAvailable          = 1018    
    
    
    /*
     * An attempt to use not allowed LockType.
     */
    case wrongLockType                      = 1019   // LockerUI

    /*
     * An unlock attempt after migration failed.
     */
    case migrationUnlockFailed              = 1020
}

//==============================================================================
public class LockerError: CSErrorBase
{
    override class public var ERROR_DOMAIN : String {
        return "cz.csas.coresdk.locker"
    }
    
    override public class var locatizationDictionary : [Int:String] {
        return _errorDictionary
    }
    
    fileprivate static let _errorDictionary: [Int:String] = [
        LockerErrorKind.other.rawValue:                      CoreSDK.localized( "err-other" ),
        LockerErrorKind.parseError.rawValue:                 CoreSDK.localized( "err-parsing-data" ),
        LockerErrorKind.emptyClientId.rawValue:              CoreSDK.localized( "err-empty-clientid" ),
        LockerErrorKind.wrongOAuth2Url.rawValue:             CoreSDK.localized( "err-wrong-oauth2-url" ),
        LockerErrorKind.registrationFailed.rawValue:         CoreSDK.localized( "err-registration-failed" ),
        LockerErrorKind.loginFailed.rawValue:                CoreSDK.localized( "err-login-failed" ),
        LockerErrorKind.passwordChangeFailed.rawValue:       CoreSDK.localized( "err-password-change-failed" ),
        LockerErrorKind.userUnregistrationFailed.rawValue:   CoreSDK.localized( "err-user-registration-failed" ),
        LockerErrorKind.touchIDNotAvailable.rawValue:        CoreSDK.localized( "err-touchid-not-available" ),
        LockerErrorKind.otpUnlockFailed.rawValue:            CoreSDK.localized( "err-otp-unlock-failed" ),
        LockerErrorKind.noAuthToken.rawValue:                CoreSDK.localized( "err-no-auth-token" ),
        LockerErrorKind.noAccessToken.rawValue:              CoreSDK.localized( "err-no-access-token" ),
        LockerErrorKind.noRefreshToken.rawValue:             CoreSDK.localized( "err-no-refresh-token" ),
        LockerErrorKind.wrongLockerData.rawValue:            CoreSDK.localized( "err-wrong-locker-data" ),
        LockerErrorKind.userNotRegistered.rawValue:          CoreSDK.localized( "err-user-not-registered" ),
        LockerErrorKind.refreshTokenFailure.rawValue:        CoreSDK.localized( "err-refresh-token-failure" ),
        LockerErrorKind.loginTimeOut.rawValue:               CoreSDK.localized( "err-session-timeout" ),
        LockerErrorKind.loginCanceled.rawValue:              CoreSDK.localized( "err-login-canceled" ),
        LockerErrorKind.protectedDataNotAvailable.rawValue:  CoreSDK.localized( "err-protected-data-not-available" ),
        LockerErrorKind.wrongLockType.rawValue:              CoreSDK.localized( "err-wrong-lock-type" ),
        LockerErrorKind.migrationUnlockFailed.rawValue:      CoreSDK.localized( "err-unlock-after-migration-failed" )
    ]
    
    
    public var kind : LockerErrorKind {
        if let kind = LockerErrorKind(rawValue: self.code) {
            return kind
        }
        return LockerErrorKind.other
    }
    
    
    //--------------------------------------------------------------------------
    public class func isError( _ error: NSError, ofKind kind: LockerErrorKind ) -> Bool
    {
        return ( error is LockerError && ( error as! LockerError ).kind == kind )
    }
    
    //--------------------------------------------------------------------------
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder )
    }
    
    //--------------------------------------------------------------------------
    public init(kind: LockerErrorKind)
    {
        super.init( domain: type(of: self).ERROR_DOMAIN, code: kind.rawValue, userInfo:Dictionary() )
    }
    
    //--------------------------------------------------------------------------
    public override init(domain errorDomain: String, code errorCode: Int, userInfo dict: [String: Any]?)
    {
        super.init( domain:errorDomain, code:errorCode, userInfo:dict as [String : Any]? )
    }
    
    //--------------------------------------------------------------------------
    public init( lockerErrorKind: LockerErrorKind, userInfo dict: [String: Any]?)
    {
        super.init( domain:type(of: self).ERROR_DOMAIN, code:lockerErrorKind.rawValue, userInfo:dict as [String : Any]? )
    }
    
    
    //--------------------------------------------------------------------------
    class public func errorOfKind( _ kind: LockerErrorKind ) -> LockerError
    {
        return LockerError(kind: kind)
    }
    
    //--------------------------------------------------------------------------
    class public func errorOfKind( _ kind: LockerErrorKind, underlyingError: NSError? ) -> LockerError
    {
        if let error: NSError = underlyingError {
            let userInfoDictionary = [NSUnderlyingErrorKey : error]
            return LockerError(domain: LockerError.ERROR_DOMAIN, code:kind.rawValue, userInfo:userInfoDictionary)
        }
        else {
            return LockerError(kind: kind)
        }
        
    }
}
