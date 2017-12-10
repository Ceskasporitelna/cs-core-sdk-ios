//
//  CoreSdkAPI.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 21.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//




import Foundation


//==============================================================================
public protocol CoreSDKAPI
{
    /**
     CSCoreSDK shared instance, singleton.
     */
    static var sharedInstance   : CoreSDKAPI             { get }
    
    /**
    * WebApiConfiguration used for sharedInstance
    */
    var webApiConfiguration     : WebApiConfiguration    { get }
    
    /**
     Locker instance.
     */
    var locker                  : LockerAPI             { get }
    /**
     CSCoreSDK environment.
     */
    var environment             : Environment           { get }
    /**
     Completion queue to return all CSCoreSDK callbacks. If not set, dispatch_get_main() queue will be used.
     */
    var completionQueue         : DispatchQueue         { get set }
    /**
     A flag inicating the CSCoreSDK initialization status. After the useEnvironment() call is set to true.
     */
    var isInitialized           : Bool                  { get }
    /**
     A logger prefix. If set, the loggerPrefix will appear in each log message between timestamp and log message.
     */
    var loggerPrefix            : String?               { get set }
    /**
     A logger delegate will receive all log messages from CSCoreSDK. If not set, log messages will appear only in the XCode console.
     */
    var loggerDelegate          : CoreSDKLoggerDelegate? { get set }
    /**
     A Web API key used by CSCoreSDK.
     */
    var webApiKey               : String?               { get }
    /**
     Language used for communication with WebApi. If not defined, a default value cs-CZ is set.
     */
    var language                : String                { get set }
    /**
     CSCoreSDK shared context.
     */
    var sharedContext           : SharedContext         { get }

    /**
     Set other then the default language cs-CZ.
     - parameter lanuage: A language to be set.
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useLanguage( _ language: String ) -> CoreSDKAPI
    
    /**
     Set other then the default (nil) logger prefix.
     - parameter prefix: A logger prefix to be set.
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useLoggerPrefix(_ prefix: String?) -> CoreSDKAPI
    
    /**
     Set the WebAPI key.
     - parameter webApiKey: A WebApiKey to be set.
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useWebApiKey( _ webApiKey: String ) -> CoreSDKAPI
    /**
     Set the CSCoreSDK environment.
     - parameter environment: The environment to be set.
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useEnvironment( _ environment : Environment ) -> CoreSDKAPI
    /**
     Specifies the private key for CSCoreSDK request signing.
     - parameter privateKey: The private key to sign reguests.
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useRequestSigning(_ privateKey : String) -> CoreSDKAPI
    /**
     Specifies the Locker attributes. Must be called before first locker property call, otherwise an assert is invoked.
     The default lockerClientBasePath "api/v1" is used.
     - parameter clientId: The client identifier.
     - parameter clientSecret:
     - parameter publicKey: A WebApi public key to encrypt request data.
     - parameter redirectUrlPath: Specifies URL scheme and URL path for Safari to redirect the registration callback, for example "csastest://auth-completed". While the "//auth-completed" path is mandatory, the URL scheme is variable and must be defined in the CFBundleURLSchemes property in the application .plist file.
     - parameter scope: A locker scope, such as "/v1/netbanking".
     - returns: A CoreSDKApi reference.
     */
    @discardableResult
    func useLocker( clientId : String, clientSecret : String, publicKey : String, redirectUrlPath : String, scope: String) -> CoreSDKAPI    
}



//==============================================================================
/**
    Generic result type.
    - Success A successfull result with data object.
    - Failure An unsuccessfull result with NSError
*/
public enum CoreResult<T>
{
    case success(T)
    case failure(NSError)
    
    /*
     Returns unwrapped object if this is a successfull result
     
     - returns: Object of type T if the call was successfull, nil if the `CoreResult` represents a failure.
    */
    public func getObject() -> T?{
        switch self {
        case .success(let object):
            return object
        default:
            return nil
        }
    }
    
    /**
     Returns unwrapped error if any
     
     - returns: Error if any, nil otherwise
     */
    public func getError() -> NSError?{
        switch self{
        case .failure(let error):
            return error
        default:
            return nil
        }
    }

}


//==============================================================================
/**
    Log level. Specify in the CoreSDKLoggerDelegate.
    - All A maximal level of log details.
    - DetailedDebug Detailed debug messages.
    - Debug Common debug messages.
    - Info Info messages.
    - Error All error messages. <== Recommended for production build
    - Fatal Fatal error only messages.
*/
@objc public enum LogLevel: Int8
{
    case all                 = 0 // The default value
    case detailedDebug       = 1
    case debug               = 2
    case info                = 3
    case warning             = 4
    case error               = 5 // Recommended for the production build
    case fatal               = 6
}


//==============================================================================
@objc public class Environment : NSObject {
    
    public static let Sandbox = Environment(
        apiContextBaseUrl: "https://api.csas.cz/sandbox/webapi",
        oAuth2ContextBaseUrl: "https://api.csas.cz/sandbox/widp/oauth2")
    
    public static let Production = Environment(
        apiContextBaseUrl: "https://www.csas.cz/webapi",
        oAuth2ContextBaseUrl: "https://www.csas.cz/widp/oauth2")
    
    /**
    A CSCoreSDK context base URL path.
    */
    public let apiContextBaseUrl : String
    /**
     A Locker base URL path for OAuth2 authentication.
     */
    public let oAuth2ContextBaseUrl : String
    
    public let allowUntrustedCertificates : Bool
    
    
    /**
    Initializes the environment.
    - parameter apiContextBaseUrl: A CSCoreSDK context base URL path.
    - parameter oAuth2ContextBaseUrl: A Locker base URL path for OAuth2 authentication.
    */
    //--------------------------------------------------------------------------
    @objc public convenience init(apiContextBaseUrl : String, oAuth2ContextBaseUrl : String)
    {
        self.init(apiContextBaseUrl: apiContextBaseUrl,oAuth2ContextBaseUrl: oAuth2ContextBaseUrl,allowUntrustedCertificates: false)
    }
    
    
    /**
     Initializes the environment.
     - parameter apiContextBaseUrl: A CSCoreSDK context base URL path.
     - parameter oAuth2ContextBaseUrl: A Locker base URL path for OAuth2 authentication.
     */
     //--------------------------------------------------------------------------
    @objc public init(apiContextBaseUrl : String, oAuth2ContextBaseUrl : String,allowUntrustedCertificates: Bool)
    {
        self.apiContextBaseUrl    = apiContextBaseUrl
        self.oAuth2ContextBaseUrl = oAuth2ContextBaseUrl
        self.allowUntrustedCertificates = allowUntrustedCertificates
        super.init()
    }
    
}

public typealias TAccessToken = String

//==============================================================================
public protocol AccessTokenProvider
{
    /**
     Returns the access token. If no identity is stored, or locker is not in the Unlocked state, returns error.
     If access token is expired, the refreshAccessToken method is invoked.
     - parameter callback: Access token, or error.
     */
    func getAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    
    /**
     Returns the refreshed access token. If no identity is stored, or locker is not in the Unlocked state, returns error.
     - parameter callback: Refreshed access token, or error.
     */
    func refreshAccessToken( _ callback: @escaping ( _ result: CoreResult<TAccessToken>) -> () )
    
}

