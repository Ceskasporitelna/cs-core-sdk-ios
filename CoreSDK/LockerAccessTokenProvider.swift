//
//  LockerAccessTokenProvider.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 17/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 * Locker Access Token Provider log activities.
 */
//==============================================================================
internal enum LockerAccessTokenProviderActivities: String {
    case GetAccessToken          = "GetAccessToken"
    case RefreshAccessToken      = "RefreshAccessToken"
}

//==============================================================================
public class LockerAccessTokenProvider: NSObject, AccessTokenProvider
{
    fileprivate static let ModuleName      = "LockerAccessTokenProvider"
    fileprivate var locker: LockerAPI!
    
    //--------------------------------------------------------------------------
    required public init( locker: LockerAPI )
    {
        super.init()
        self.locker = locker
    }
    
    //--------------------------------------------------------------------------
    public func getAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    {
        let lockStatus = self.locker.lockStatus
        var lockerError: LockerError?
        
        switch ( lockStatus ) {
        case .unlocked, .locked:
            if let accessToken = self.locker.accessToken {
                if let accessTokenExpiration = self.locker.accessTokenExpiration {
                    let expirationDate = Date(timeIntervalSince1970: TimeInterval(accessTokenExpiration)/1000.0 )
                    if ( (Date() as NSDate).laterDate( expirationDate ) == expirationDate ) {
                        clog(LockerAccessTokenProvider.ModuleName, activityName: LockerAccessTokenProviderActivities.GetAccessToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Returning an non-expired access token." );
                        callback( CoreResult.success( accessToken ) )
                    }
                    else {
                        self.refreshAccessToken( { result in
                            switch ( result ) {
                            case .success( let accessToken ):
                                callback( CoreResult.success(accessToken) )
                            case .failure(let error):
                                callback( CoreResult.failure(error))
                            }
                        })
                    }
                }
                else {
                    lockerError = LockerError(kind: .wrongLockerData )
                    callback( CoreResult.failure( lockerError! ) )
                }
            }
            else {
                lockerError = LockerError(kind: .noAccessToken )
                callback( CoreResult.failure( lockerError! ) )
            }
            
        case .unregistered:
            lockerError = LockerError(kind: .userNotRegistered )
            callback( CoreResult.failure( lockerError! ) )
        }
        
        if let error = lockerError {
            clog(LockerAccessTokenProvider.ModuleName, activityName: LockerAccessTokenProviderActivities.GetAccessToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error when getting access token: %@", error.localizedDescription );
        }
    }
    
    //--------------------------------------------------------------------------
    public func refreshAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    {
        self.locker.refreshToken( { (result, remainingAttempts) -> Void in
            switch ( result ) {
            case .success(_):
                clog(LockerAccessTokenProvider.ModuleName, activityName: LockerAccessTokenProviderActivities.RefreshAccessToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Access token has been successfully refreshed." );
                callback( CoreResult.success(self.locker.accessToken!) )
                
            case .failure( let error ):
                clog(LockerAccessTokenProvider.ModuleName, activityName: LockerAccessTokenProviderActivities.RefreshAccessToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Access token refresh was unsuccessfull, error: %@", error.localizedDescription );
                callback( CoreResult.failure( error ) )
            }
        })
    }
}
