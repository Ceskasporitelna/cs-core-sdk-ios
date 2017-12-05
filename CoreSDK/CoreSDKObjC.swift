//
//  CoreSDKobjC.swift
//  CSCoreSDKTestApp
//
//  Created by Michal Sverak on 10/23/17.
//  Copyright © 2017 Applifting. All rights reserved.
//

/*
 Here is a short list of Swift features that are not available in objective-c: tuples,
 generics, any global variables, structs, typealiases, or enums defined in swift,
 and the top-level swift functions.
 https://medium.com/ios-os-x-development/swift-and-objective-c-interoperability-2add8e6d6887
 */

import Foundation

@objc public class CoreSDKObjC: NSObject {

    /**
     CSCoreSDK shared instance, singleton.
     */
    @objc public static var sharedInstance = CoreSDKObjC()
    
    /**
     * Accessors for WebAPI Configuration used for sharedInstance
     */
    @discardableResult
    @objc public func useWebApiKey(_ key: String) -> CoreSDKObjC {
        CoreSDK.sharedInstance.useWebApiKey(key)
        return self
    }
    @objc public var webApiKey: String {
        get {
            return CoreSDK.sharedInstance.webApiConfiguration.webApiKey
        }
    }
    
    @discardableResult
    @objc public func useEnvironment(_ environment: Environment) -> CoreSDKObjC {
        CoreSDK.sharedInstance.useEnvironment(environment)
        return self
    }
    @objc public var environment: Environment {
        get {
            return CoreSDK.sharedInstance.webApiConfiguration.environment
        }
    }
    
    @discardableResult
    @objc public func useLanguage(_ language: String) -> CoreSDKObjC {
        CoreSDK.sharedInstance.useLanguage(language)
        return self
    }
    @objc public var language: String {
        get {
            return CoreSDK.sharedInstance.webApiConfiguration.language
        }
    }
    
    @discardableResult
    @objc public func useRequestSigning(privateKey: String) -> CoreSDKObjC {
        CoreSDK.sharedInstance.useRequestSigning(privateKey)
        return self
    }
    @objc public var signingKey: Data? {
        get {
            return CoreSDK.sharedInstance.webApiConfiguration.signingKey
        }
    }
    
    /**
     A logger delegate will receive all log messages from CSCoreSDK. If not set, log messages will appear only in the XCode console.
     */
    @objc public var loggerDelegate: CoreSDKLoggerDelegate? {
        get {
            return CoreSDK.sharedInstance.loggerDelegate
        }
        set(delegate) {
            var coreSDK = CoreSDK.sharedInstance
            coreSDK.loggerDelegate = delegate
        }
    }
    /**
     CSCoreSDK shared context.
     */
    @objc var sharedContext: AccessTokenProviderObjC {
        get {
            return CoreSDK.sharedInstance.sharedContext
        }
    }
    
    /**
     Locker instance.
     */
    public var locker: LockerAPI {
        get {
            return CoreSDK.sharedInstance.locker
        }
    }
    
    /**
     Completion queue to return all CSCoreSDK callbacks. If not set, dispatch_get_main() queue will be used.
     */
    @objc public var completionQueue: DispatchQueue {
        get {
            return CoreSDK.sharedInstance.completionQueue
        }
        set(dispatchQueue) {
            var coreSDK = CoreSDK.sharedInstance
            coreSDK.completionQueue = dispatchQueue
        }
    }
    
    /**
     A flag inicating the CSCoreSDK initialization status. After the useEnvironment() call is set to true.
     */
    @objc public var isInitialized: Bool {
        get {
            return CoreSDK.sharedInstance.isInitialized
        }
    }
    
    /**
     A logger prefix. If set, the loggerPrefix will appear in each log message between timestamp and log message.
     */
    @objc public var loggerPrefix: String? {
        get {
            return CoreSDK.sharedInstance.loggerPrefix
        }
        set {
            var coreSDK = CoreSDK.sharedInstance
            coreSDK.loggerPrefix = loggerPrefix
        }
    }
    
    /**
     Specifies the Locker attributes. Must be called before first locker property call, otherwise an assert is invoked.
     The default lockerClientBasePath "api/v1" is used.
     - parameter clientId: The client identifier.
     - parameter clientSecret:
     - parameter publicKey: A WebApi public key to encrypt request data.
     - parameter redirectUrlPath: Specifies URL scheme and URL path for Safari to redirect the registration callback, for example "csastest://auth-completed". While the "//auth-completed" path is mandatory, the URL scheme is variable and must be defined in the CFBundleURLSchemes property in the application .plist file.
     - parameter scope: A locker scope, such as "/v1/netbanking".
     - returns: A CoreSDKApiObjC reference.
     */
    @objc public func useLocker(clientId: String, clientSecret: String, publicKey: String, redirectUrlPath: String, scope: String) -> CoreSDKObjC {
        CoreSDK.sharedInstance.useLocker(clientId: clientId,
                                         clientSecret: clientSecret,
                                         publicKey: publicKey,
                                         redirectUrlPath: redirectUrlPath,
                                         scope: scope)
        return self
    }
 
}

//==============================================================================
// Obj-C compatibility layer
@objc public protocol AccessTokenProviderObjC
{
    /**
     Returns the access token. If no identity is stored, or locker is not in the Unlocked state, returns error.
     If access token is expired, the refreshAccessToken method is invoked.
     - parameter callback: Access token, or error.
     */
    func getAccessToken(success: ((TAccessToken)->())?, failure: ((NSError)->())?)
    
    /**
     Returns the refreshed access token. If no identity is stored, or locker is not in the Unlocked state, returns error.
     - parameter callback: Refreshed access token, or error.
     */
    func refreshAccessToken(success: ((TAccessToken)->())?, failure: ((NSError)->())?)
}
