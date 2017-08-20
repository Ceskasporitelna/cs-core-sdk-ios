//
//  CoreSDK.swift
//  CoreSDKApp
//
//  Created by Vladimír Nevyhoštěný on 24.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

/**
 * Core log activities.
 */
//==============================================================================
internal enum CoreSDKActivities: String {
    
    // Init ...
    case CoreSDKInit         = "CoreSDKInit"
    case InitReachability    = "InitReachability"
    case InitSharedContext   = "InitSharedContext"
    
    // Data encryption and decryption ...
    
    case DataEncryption      = "DataEncryption"
    case DataDecryption      = "DataDecryption"
    
    // Keychain activities ...
    
    case KeychainReading     = "KeychainReading"
    case KeychainWriting     = "KeychainWriting"
    case KeychainWiping      = "KeychainWiping"
    
    // Other ...
    case VendorInfo          = "VendorInfo"    
}



// MARK: -
//==============================================================================
public protocol CoreSDKLoggerDelegate
{
    func log( _ logLevel: LogLevel, message: String )
}

//------------------------------------------------------------------------------
public func clog( _ moduleName: String?, activityName: String?, fileName: NSString?, functionName: NSString?, lineNumber: Int?, logLevel: LogLevel?, format: String, _ args: CVarArg... )
{
    var message: String!
    let argsCount = args.count
    
    if argsCount > 0 {
        let messageParts = format.components( separatedBy: "%" )
        if ( messageParts.count - 1 != argsCount ) {
            message = format
        }
        else {
            message = String.init(format: format, arguments: args )
        }
    }
    else {
        message = format
    }

    let coreSDK = CoreSDK.sharedInstance as! CoreSDK
    coreSDK.log( moduleName, activityName: activityName, fileName: fileName, functionName: functionName, lineNumber: lineNumber, logLevel: logLevel, message: message )
}


// MARK: -
//==============================================================================
public class CoreSDK: NSObject, CoreSDKAPI
{
    public static let BundleIdentifier  = "cz.applifting.CSCoreSDK"
    internal static let ModuleName      = "Core"
    
    class func getBundle() -> Bundle
    {
        let bundleForThisClass = Bundle(for: CoreSDK.classForCoder())
        if bundleForThisClass.bundleIdentifier == BundleIdentifier {
            return bundleForThisClass
        } else {
            return Bundle( url: bundleForThisClass.url(forResource: BundleIdentifier, withExtension: "bundle")!)!
        }
    }
    
    
    //MARK: Public members ...
    public class var sharedInstance: CoreSDKAPI {
        if let instance = _sharedInstance{
            return instance
        }else{
            let instance = CoreSDK()
            _sharedInstance = instance
            return instance
        }
    }
    fileprivate static var _sharedInstance : CoreSDK?
    
    public var locker: LockerAPI {
        if self._locker == nil {
            
            if ( self._lockerAttributes.clientId == nil
                 ||
                 self._lockerAttributes.publicKey == nil
                 ||
                 self._lockerAttributes.redirectUrlPath == nil
                 ||
                 self._lockerAttributes.clientSecret == nil
                 ||
                 self._lockerAttributes.scope == nil
                ) {
                assert( false, "Locker initialization failed. You have to call CoreSDK.sharedInstance.useLocker(...) before using it." )
            }
            
            self._lockerAttributes.environment = self._environment
            self._locker                       = Locker( attributes: self._lockerAttributes )
        }
        return self._locker!
    }
    
    
    
    public var environment : Environment {
        return self._environment
    }
    
    public var language: String {
        get {
            return self._language
        }
        set {
            self._language = newValue
        }
    }
    
    public var webApiConfiguration : WebApiConfiguration {
        return WebApiConfiguration( webApiKey: self.webApiKey!, environment: self.environment, language: self.language, signingKey: self._lockerAttributes.requestSigningKey )
    }
    
    public var reachability: Reachability {
        var result: Reachability?
        self._propertyQueue.sync(execute: {
            if ( self._reachability == nil ) {
                self._reachability = Reachability()
            }
            result = self._reachability
        })
        return result!
    }
    
    public var completionQueue: DispatchQueue {
        get {
            return ( self._completionQueue ?? DispatchQueue.main )
        }
        set {
            self._completionQueue = newValue
        }
    }
    
    public var isInitialized: Bool {
        return self.webApiKey != nil
    }
    
    public var sharedContext: SharedContext {
        var result: SharedContext?
        self._propertyQueue.sync(execute: {
            if ( self._sharedContext == nil ) {
                self._sharedContext = SharedContext(coreSDKInstance: self)
            }
            result = self._sharedContext
        })
        return result!
    }
    
    
    public  var loggerPrefix:         String?
    public  var loggerDelegate:       CoreSDKLoggerDelegate?
    //TODO: remove public  var oauth2handler:        OAuth2Handler?
    
    fileprivate var _webApiKey : String?
    
    public  var webApiKey: String? {
        get{
            return (self._webApiKey)
        }
    }
    
    
    // MARK: Public members used in extensions ...
    
    public  var _loggerQueue                             = DispatchQueue( label: "coresdk.logger.queue", attributes: [] )
    
    // MARK: Private members ...
    fileprivate var _propertyQueue                           = DispatchQueue( label: "coresdk.property.queue", attributes: [] )
    fileprivate var _requestSigningKey : Data?             = nil
    fileprivate var _completionQueue: DispatchQueue?
    fileprivate var _locker: Locker?
    fileprivate var _lockerAttributes                        = LockerAttributes()
    fileprivate var _environment                             = Environment.Sandbox
    fileprivate var _language                                = "cs-CZ"
    fileprivate var _sharedContext: SharedContext!
    fileprivate var _reachability: Reachability!
    
    //--------------------------------------------------------------------------
    public class func localized( _ string: String ) -> String
    {
        return NSLocalizedString( string, tableName: nil, bundle: CoreSDK.getBundle(), value: "", comment: "")
    }
    
    // MARK: Init & Setup ...
    //--------------------------------------------------------------------------
    override init()
    {
        super.init()
        self.log( CoreSDK.ModuleName, activityName: CoreSDKActivities.CoreSDKInit.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, message: "Core SDK has been initialized." )
    }
    
    public func useWebApiKey( _ webApiKey: String ) -> CoreSDKAPI
    {
        self._webApiKey                  = webApiKey
        self._lockerAttributes.webApiKey = webApiKey
        return self
    }
    
    public func useLanguage( _ language: String ) -> CoreSDKAPI
    {
        self.language                   = language
        self._lockerAttributes.language = language
        return self
    }
    
    public func useLoggerPrefix(_ prefix: String?) -> CoreSDKAPI
    {
        self.loggerPrefix = prefix
        return self
    }
    
    public func useEnvironment( _ environment : Environment ) -> CoreSDKAPI
    {
        self._environment = environment
        WebServiceClient.allowUntrustedCertificates(environment.allowUntrustedCertificates)
        if self._locker != nil {
            self._locker = nil
        }
        return self
    }
    
    public func useRequestSigning(_ privateKey:String) -> CoreSDKAPI
    {
        let privateKeyData = Data(base64Encoded: privateKey, options: NSData.Base64DecodingOptions())
        if privateKeyData == nil {
            assert( false, "The request signing key is not a valid base64 encoded string")
        }
        self._requestSigningKey = privateKeyData!
        self._lockerAttributes.requestSigningKey = privateKeyData!
        return self
    }
    
    public func useLocker( clientId : String, clientSecret : String, publicKey : String, redirectUrlPath : String, scope: String) -> CoreSDKAPI
    {
        return self.useLocker(clientId: clientId, clientSecret: clientSecret, publicKey: publicKey, redirectUrlPath: redirectUrlPath, scope: scope, lockerClientApiBasePath: "api/v1")
    }
    
    private func useLocker( clientId : String, clientSecret : String, publicKey : String, redirectUrlPath : String, scope: String, lockerClientApiBasePath: String) -> CoreSDKAPI
    {
        self._locker                                   = nil
        
        self._lockerAttributes.clientId                = clientId
        self._lockerAttributes.publicKey               = publicKey
        self._lockerAttributes.redirectUrlPath         = redirectUrlPath
        self._lockerAttributes.clientSecret            = clientSecret
        self._lockerAttributes.scope                   = scope
        self._lockerAttributes.lockerClientApiBasePath = lockerClientApiBasePath
        
        return self
    }
    
    
    
}
