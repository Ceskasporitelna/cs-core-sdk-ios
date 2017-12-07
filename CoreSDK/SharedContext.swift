//
//  SharedContext.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 19/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

let AccessTokenProviderNotSetMsg = "AccessTokenProvider has to be set on SharedContext if you want to call SharedContext's methods."

//==============================================================================
public class SharedContext: AccessTokenProvider, AccessTokenProviderObjC
{
    
    internal var accessTokenProvider : LockerAccessTokenProvider? {
        get {
            var result: LockerAccessTokenProvider?
            
            self._propertyQueue.sync(execute: {
                if ( self._lockerAccessTokenProvider == nil ) {
                    self._lockerAccessTokenProvider = LockerAccessTokenProvider( locker: self._coreSDK.locker )
                }
                result = self._lockerAccessTokenProvider
            })
            return result
        }
        set {
            self._propertyQueue.sync(execute: {
                self._lockerAccessTokenProvider = newValue
            })
        }
    }
    
    fileprivate var _lockerAccessTokenProvider: LockerAccessTokenProvider?
    fileprivate var _propertyQueue  = DispatchQueue( label: "coresdk.shared_context.property_queue", attributes: [] )
    fileprivate var _coreSDK: CoreSDK!
    
    
    init( coreSDKInstance: CoreSDK )
    {
        // This will fail, if .useLocker is not called before ...
        let _         = coreSDKInstance.locker
        
        self._coreSDK = coreSDKInstance
        clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.InitSharedContext.rawValue, fileName:  #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "SharedContext has been initialized." )
    }
    
    //--------------------------------------------------------------------------
    public func getAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    {
        guard let provider = self.accessTokenProvider else {
            assert( false, AccessTokenProviderNotSetMsg)
            return
        }
        
        return provider.getAccessToken({result in
            callback(result)
        })
    }
    
    //--------------------------------------------------------------------------
    @objc public func getAccessToken(success: ((TAccessToken)->())?, failure: ((NSError)->())?){
        self.getAccessToken { (result) in
            switch result {
            case .success(let accessToken):
                success?(accessToken)
                break
            case .failure(let error):
                failure?(error)
                break
            }
        }
    }
    
    //--------------------------------------------------------------------------
    public func refreshAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    {
        guard let provider = self.accessTokenProvider else {
            assert( false, AccessTokenProviderNotSetMsg)
            return
        }
        
        return provider.refreshAccessToken({result in
            callback(result)
        })
    }

    //--------------------------------------------------------------------------
    @objc public func refreshAccessToken(success: ((TAccessToken) -> ())?, failure: ((NSError) -> ())?) {
        self.refreshAccessToken { (result) in
            switch result {
            case .success(let accessToken):
                success?(accessToken)
            case .failure(let error):
                failure?(error)
            }
        }
    }
}
