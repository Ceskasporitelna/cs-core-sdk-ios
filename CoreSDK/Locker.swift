//
//  Locker.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 11.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public struct LockerAttributes
{
    var clientId: String?
    var publicKey: String?
    var environment: Environment?
    var scope: String?
    var clientSecret: String?
    var redirectUrlPath: String?
    var webApiKey: String?
    var requestSigningKey: Data?
    var language: String?
    var lockerClientApiBasePath: String?
}

/**
 * Locker log activities.
 */
//==============================================================================
internal enum LockerActivities: String {
    case Lock                 = "Lock"
    case OTPUnlock            = "OTPUnlock"
    case UserRegistration     = "UserRegistration"
    case UserUnregistration   = "UserUnregistration"
    case UserUnlock           = "UserUnlock"
    case InitLockerClient     = "InitLockerClient"
    case UnlockWithPassword   = "UnlockWithPassword"
    case UnlockAfterMigration = "UnlockAfterMigration"
    case UnlockWithOTP        = "UnlockWithOTP"
    case RegisterUser         = "RegisterUser"
    case RefreshToken         = "RefreshToken"
    case ChangePassword       = "ChangePassword"
    case LockerStateChanged   = "LockerStateChanged"
    case LockerInvalidated    = "LockerInvalidated"
    case LockerCreated        = "LockerCreated"
}

// MARK: -
//==============================================================================
public struct OAuth2Handler
{
    public var oauth2URLhandler: (( _ oauth2url: URL ) -> Bool )?
    public var code: String?
    public var completion: RegistrationCompletion?
    
    public init( handler: (( _ oauth2url: URL ) -> Bool )?, completion: @escaping RegistrationCompletion  )
    {
        self.oauth2URLhandler = handler
        self.completion       = completion
    }
    
    public mutating func setCode( _ code: String )
    {
        self.code = code
    }
    
}


//==============================================================================
public class Locker: NSObject, LockerAPI
{    
    public static let OAuth2RequestFormat              = "%@?state=profile&redirect_uri=%@&client_id=%@&response_type=code&access_type=offline&approval_prompt=force"
    internal static let ModuleName                     = "Locker"
    // MARK: Notifications ...
    //TODO: Remove this intermediary notification in next major version
    public static let UserStateChangedNotification     = "cscoresdk.locker.status.changed"
    
    public var LockerStatusChangedNotification : String {
        get{
            return Locker.UserStateChangedNotification
        }
    }
    
    
    let basePath:       String
    let publicKey:      String
    let webApiKey:      String

    fileprivate var _completionQueue: DispatchQueue?
//    public  var _lockerOauth2Info: LockerOAuth2Info?
    public  var oauth2handler:        OAuth2Handler?
    public  let oauth2UrlPath: String
    public  let oauth2TokenRefreshUrlPath : String
    public  var scope: String?
    
    //--------------------------------------------------------------------------
    public var completionQueue: DispatchQueue {
        get {
            return CoreSDK.sharedInstance.completionQueue
        }
    }
    
    public var accessToken: String? {
        get {
            self.identityKeeper.wipeKeychainIfJustInstalled()
            return self.identityKeeper.accessToken
        }
        set {
            self.identityKeeper.accessToken = newValue
        }
    }
    
    public var touchIdToken: String? {
        get {
            return self.identityKeeper.touchIdToken
        }
        set {
            self.identityKeeper.touchIdToken = newValue
        }
    }
    
    public var status: LockerStatus {
        
        let status = LockerStatus()
        
        let lockStatus = self.identityKeeper.lockStatus
        
        self.identityKeeper.wipeKeychainIfJustInstalled()
        
        status.lockStatus            = ( lockStatus)
        status.lockType              = ( self.identityKeeper.lockType)
        status.clientId              = ( self.identityKeeper.clientId)
        status.hasOneTimePasswordKey = ( self.identityKeeper.oneTimePasswordKey != nil )
        status.hasAesEncryptionKey   = ( self.identityKeeper.aesEncryptionKey != nil )
        
        return status
    }
    
    //--------------------------------------------------------------------------
    public var lockStatus: LockStatus {
        self.identityKeeper.wipeKeychainIfJustInstalled()
        return self.status.lockStatus
    }

    public var otpAttributes: OTPAttributes {
        //THIS CAUSED SEG FAULT 11 When Archiving under Swift 3 and Xcode 8.0 :-(

//        struct Static {
//            static var instance: OTPAttributes = OTPAttributes()
//        }
//        
//        return Static.instance
        return OTPAttributes()

    }

    public var oauth2ClientId: String
    
    public var clientId: String? {
        get {
            self.identityKeeper.wipeKeychainIfJustInstalled()
            return self.identityKeeper.clientId
        }
        set {
            self.identityKeeper.clientId = newValue
        }
    }
    
    public var oneTimePasswordKey: String? {
        get {
            self.identityKeeper.wipeKeychainIfJustInstalled()
            return self.identityKeeper.oneTimePasswordKey
        }
        set {
            self.identityKeeper.oneTimePasswordKey = newValue
        }
    }
    
    public var aesEncryptionKey: String? {
        get {
            return self.identityKeeper.aesEncryptionKey
        }
        set {
            self.identityKeeper.aesEncryptionKey = newValue
        }
    }
    
    public var lockType: LockType {
        self.identityKeeper.wipeKeychainIfJustInstalled()
        return self.identityKeeper.lockType
    }
    
    public var refreshToken: String? {
        get {
            self.identityKeeper.wipeKeychainIfJustInstalled()
            return self.identityKeeper.refreshToken
        }
        set {
            self.identityKeeper.refreshToken = newValue
        }
    }
    
    public var oauth2Code: String? {
        get {
            return self.identityKeeper.oauth2Code
        }
        set {
            self.identityKeeper.oauth2Code = newValue
        }
    }
    
    public var tokenType: String? {
        get {
            return self.identityKeeper.tokenType
        }
        set {
            self.identityKeeper.tokenType = newValue
        }
    }
    
    public var oauth2ClientSecret: String
    
    public var accessTokenExpiration: UInt64? {
        get {
            return self.identityKeeper.accessTokenExpiration
        }
        set {
            self.identityKeeper.accessTokenExpiration = newValue
        }
    }
    
    public var deviceFingerprint: String? {
        get {
            return ( self.identityKeeper.fixedDeviceFingerprint != nil ? self.identityKeeper.fixedDeviceFingerprint : self.identityKeeper.deviceFingerprint )
        }
        set {
            self.identityKeeper.deviceFingerprint = newValue
        }
    }
    
    public var isRunningInTestMode: Bool {
        return ( self._fixedNonce != nil && self._fixedUserPassword != nil && self.identityKeeper.isRunningInTestMode )
    }
    
    public var noAuthTypePassword: String? {
        get {
            return self.identityKeeper.noAuthTypePassword
        }
        set {
            self.identityKeeper.noAuthTypePassword = newValue
        }
    }
    
    var lockerClient: LockerClient {
        if ( self._lockerClient == nil ) {
            self._lockerClient = LockerClient( locker: self, language: self._language, requestSigningKey: self.requestSigningKey, apiBasePath: self.lockerClientBasePath )
        }
        return self._lockerClient!
    }
    
    //--------------------------------------------------------------------------
    public var pinLength: Int = 6
    public internal(set) var redirectUrlPath: String!
    fileprivate var lockerClientBasePath: String!
    fileprivate var _isRunningInTestMode: Bool = false
    public  var identityKeeper: IdentityKeeper = IdentityKeeper()
    fileprivate let requestSigningKey : Data?
    fileprivate var _lockerClient: LockerClient?
    fileprivate var _language: String?
    
    // MARK: Private properties for testing ...
    
    fileprivate var _fixedNonce:        String? = nil     // returned with generateNonce(), if set
    fileprivate var _fixedUserPassword: String? = nil     // returned with distortUserPassword(), if set
    internal var _fixedNewUserPassword: String? = nil     // used as a new password instead of distortUserPassword(), if set
    fileprivate var _fixedCurrentTimestamp: TimeInterval? = nil //returned with getCurrentTimestamp() if set
    
    internal var backgroundQueue = DispatchQueue.init(label: "cz.applifting.locker.backgroundQueue", qos: .background)
    
    // MARK: Init ...
    
    //--------------------------------------------------------------------------
    required public init?( attributes: LockerAttributes )
    {
        let protectedDataAvailable = IdentityKeeper.protectedDataAvailable
        
        guard let clientId          = attributes.clientId,
              let clientSecret      = attributes.clientSecret,
              let publicKey         = attributes.publicKey,
              let basePath          = attributes.environment?.apiContextBaseUrl,
              let oauth2UrlBasePath = attributes.environment?.oAuth2ContextBaseUrl,
              let redirectUrlPath   = attributes.redirectUrlPath,
              let scope             = attributes.scope,
              let webApiKey         = attributes.webApiKey,
              let clientBasePath    = attributes.lockerClientApiBasePath,
              protectedDataAvailable
        else {
            if protectedDataAvailable {
                assert( false, "Mandatory locker attributes not set." )
            }
            else {
                assert( false, "The Locker can not be initialized, because protected data are not available. Avoid the Locker initialization, when iOS device is locked." )
            }
            
            //We have to make compiler happy
            self.oauth2ClientId                  = ""
            self.oauth2ClientSecret              = ""
            self.basePath                        = ""
            self.oauth2UrlPath                   = ""
            self.oauth2TokenRefreshUrlPath       = ""
            self.redirectUrlPath                 = ""
            self.webApiKey                       = ""
            self.publicKey                       = ""
            self.scope                           = ""
            self.lockerClientBasePath            = ""
            self.requestSigningKey               = nil
            self._lockerClient                   = nil
            super.init()
            return nil
        }
        
        self.oauth2ClientId                  = clientId
        self.oauth2ClientSecret              = clientSecret
        self.basePath                        = basePath
        self.oauth2UrlPath                   = oauth2UrlBasePath + "/auth"
        self.oauth2TokenRefreshUrlPath       = oauth2UrlBasePath + "/token"
        self.redirectUrlPath                 = redirectUrlPath
        self.lockerClientBasePath            = clientBasePath
        self.webApiKey                       = webApiKey
        
        self.identityKeeper.wipeKeychainIfJustInstalled()
        self.identityKeeper.wipeKeychainIfEnvironmentChanged(clientId, oAuthClientSecret: clientSecret)
        
        if let language = attributes.language {
            self._language = language
        }
        
        self.publicKey                       = publicKey
        self.scope                           = scope

        if let signingKey = attributes.requestSigningKey {
            self.requestSigningKey = signingKey
        }
        else {
            self.requestSigningKey = nil
        }
        
        self.identityKeeper.saveSelfDkDataSync()
        super.init()
    }
    
    //MARK: -
    func generateSecretData() -> Data
    {
        return self.identityKeeper.generateSecretData() as Data
    }
    
    public func lockUser()
    {
        clog(Locker.ModuleName, activityName: LockerActivities.Lock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "User locked." )
        self.identityKeeper.lockUser()
    }
    
    func unregisterUser()
    {
        clog(Locker.ModuleName, activityName: LockerActivities.UserUnregistration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "User unregistered." )
        self.identityKeeper.unregisterUser()
    }
    
    func saveKeychainData(_ encryptionKey : String?)
    {
        self.identityKeeper.saveKeychainData(encryptionKey == nil ? self.identityKeeper.aesEncryptionKey : encryptionKey)
    }
    
    func generateNonce() -> String
    {
        return ( self._fixedNonce != nil ? self._fixedNonce! : UUID().uuidString )
    }
    
    var currentTimestamp : TimeInterval{
        if let fixedStamp = self._fixedCurrentTimestamp{
            return fixedStamp
        }
        return Date().timeIntervalSince1970
    }
    
    @discardableResult
    func setFixedCurrentTimestamp( _ fixedTimestamp: TimeInterval? ) -> Locker
    {
        self._fixedCurrentTimestamp = fixedTimestamp
        return self
    }
    
    func distortUserPassword( _ password: String ) -> String
    {
        return (  self._fixedUserPassword != nil ? self._fixedUserPassword! : "\(password)\(self.deviceFingerprint!)\(self.identityKeeper.vendorIdentifier())".sha256() )
    }

    @discardableResult
    func setFixedSessionSecretData( _ fixedData: Data ) -> Locker
    {
        self.identityKeeper.fixedSessionSecretData = fixedData
        return self
    }
    
    @discardableResult
    func setFixedDeviceFingerprint( _ fixedFingerprint: String ) -> Locker
    {
        self.identityKeeper.fixedDeviceFingerprint = fixedFingerprint
        return self
    }
    
    @discardableResult
    func setFixedNonce( _ fixedNonce: String ) -> Locker
    {
        self._fixedNonce = fixedNonce
        return self
    }
    
    @discardableResult
    func setFixedUserPassword( _ fixedPassword: String, fixedNewPassword : String ) -> Locker
    {
        self._fixedUserPassword = fixedPassword
        self._fixedNewUserPassword = fixedNewPassword
        return self
    }
    
    public func cancelWithCompletion( _ completion: (( _ status: LockerStatus ) -> ())? )
    {
        self.lockerClient.cancel()
        completion?( self.status )
    }

    func setLockType( _ lockType: LockType )
    {
        self.identityKeeper.lockType = lockType
    }
    
    public func canContinueWithOAuth2UrlPath( _ urlPath: String ) -> Bool
    {
        var canContinue = false
        if urlPath.range( of: self.redirectUrlPath ) != nil {
            if let url = URL( string: urlPath ) {
                
                let parser = OAuth2Parser( url: url )
                let result = parser.parseResponse()
                
                switch result {
                case .success(_):
                    self.setRegistrationCode( parser.code! )
                    canContinue = true
                    
                case .failure:
                    break
                }
            }
        }
        return canContinue
    }
    
    public func useOAuth2URLHandler( _ handler: @escaping (( _ oauth2url: URL ) -> Bool ), completion : @escaping RegistrationCompletion )
    {
        self.oauth2handler = OAuth2Handler( handler: handler, completion: completion )
    }
    
    public func setRegistrationCode( _ code: String )
    {
        self.oauth2handler?.setCode( code )
    }
    
    @discardableResult
    public func continueWithUserRegistrationUsingOAuth2Url(_ oauth2url: URL)-> Bool
    {
        if let handler = self.oauth2handler {
            return handler.oauth2URLhandler!( oauth2url )
        } else {
            assert( false, "CoreSDK.oauth2handler not set!" )
            return false
        }
    }
    
    public func wipeCurrentUser()
    {
        self.identityKeeper.wipeKeychainDataSync()
    }
}
