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
    @objc public var locker: LockerObjC {
        get {
            return LockerObjC.sharedInstance
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

@objc public class LockerObjC: NSObject {
    
    /**
     LockerObjC shared instance, singleton.
     */
    @objc public static var sharedInstance = LockerObjC()
    
    /**
     Start date in seconds after 1.1.1970
     */
    @objc var otpStart: UInt32 {
        get {
            return CoreSDK.sharedInstance.locker.otpAttributes.OTP_START
        }
    }
    
    /**
     Time interval in seconds for OTP genarator.
     */
    @objc var otpInterval: Float64 {
        get {
            return CoreSDK.sharedInstance.locker.otpAttributes.OTP_INTERVAL
        }
    }
    
    /**
     Raw length of generated OTP.
     */
    @objc var otpLength: Int {
        get {
            return CoreSDK.sharedInstance.locker.otpAttributes.OTP_LENGTH
        }
    }
    
    /**
     Ther user status descriptor.
     */
    @objc var status: LockerStatus {
        get {
            return CoreSDK.sharedInstance.locker.status
        }
    }
    
    /**
     The user locker status.
     */
    @objc var lockStatus: LockStatus {
        get {
            return CoreSDK.sharedInstance.locker.lockStatus
        }
    }
    
    /**
     A token obtained after the successful registration.
     */
    @objc var accessToken: String? {
        get {
            return CoreSDK.sharedInstance.locker.accessToken
        }
    }
    
    /**
     Access token expiration in msec. since 1.1.1970
     Returns 0 if no expiration information is available (i.e. no token is present)
     */
    @objc var accessTokenExpiration: UInt64 {
        get {
            return CoreSDK.sharedInstance.locker.accessTokenExpiration ?? 0
        }
    }
    
    /**
     A queue used to return of Locker callbacks.
     - seealso: CoreSDK.sharedInstance.completionQueue
     */
    @objc var completionQueue: DispatchQueue {
        get {
            return CoreSDK.sharedInstance.locker.completionQueue
        }
    }
    
    /**
     The current lockType.
     */
    @objc var lockType: LockType {
        get {
            return CoreSDK.sharedInstance.locker.lockType
        }
    }
    
    /**
     * Url to handle registration redirect call
     */
    @objc var redirectUrlPath: String {
        get {
            return CoreSDK.sharedInstance.locker.redirectUrlPath
        }
    }
    
    /**
     Returns the URL to start the registration process.
     */
    @objc var registrationURL: URL? {
        get {
            return CoreSDK.sharedInstance.locker.registrationURL()
        }
    }
    
    /**
     Starts registration process by invoking the Safari OAuth2 login page.
     You have to call the CoreSDK.sharedInstance.continueWithUserRegistrationUsingOAuth2Url( oauth2url: NSURL ) method in the application
     delegate to handle the Safari OAuth2 redirect with token.
     - parameter completion: The completion will be invoked, when the CoreSDK.sharedInstance.continueWithUserRegistrationUsingOAuth2Url( oauth2url: NSURL ) handler will be called.
     Inside of this completion you should ask the user for lockType and password, then call the
     completeUserRegistrationWithLockType( lockType: LockType, password: String, completion: RegistrationCompletion )
     method to complete the registration.
     */
    @objc func registerUserWithCompletion(success: ((Bool)->())?, failure: ((NSError)->())?) {
        CoreSDK.sharedInstance.locker.registerUserWithCompletion {
            (result) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    /**
     Handles Safari OAuth2 callback URL. Should be implemented in the application delegate
     to handle the Safari OAuth2 redirect callback. You have to register appropriate URL scheme in the application .plist file.
     
     - parameter oauth2url: The OAuth2 redirect URL with access code.
     - returns: True, if the URL in input parameter has negotiated URL scheme. False otherwise.
     If returns true and the Locker.registerUserWithCompletion( completion : RegistrationCompletion ) was used to register the user,
     completion is called. You haw to ask the user for lockType and password, then call the
     Locker.completeUserRegistrationWithLockType( lockType: LockType, password: String, completion: UnlockCompletion ) method.
     If returns true and the LockerUI.registerUserWithCompletion( completion : UnlockCompletion ) was used to register the user,
     LockerUI proceeds automatically with dialogs to obtain the lockType and password, completes registration and
     the the LockerUI.registerUserWithCompletion( completion : RegistrationCompletion ) completion will be invoked with registration result.
     - seealso: application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
     */
    @objc func continueWithUserRegistrationUsingOAuth2Url(_ oauth2url: URL) -> Bool {
        return CoreSDK.sharedInstance.locker.continueWithUserRegistrationUsingOAuth2Url(oauth2url)
    }
    
    /**
     Finishes the user registration.
     - parameter lockType: The user lock type.
     - parameter password: The user password.
     - parameter completion: The registration completion.
     */
    @objc func completeUserRegistrationWithLockType(_ lockType: LockType, password: String?, success: ((Bool)->())?, failure: ((NSError)->())?) {
        CoreSDK.sharedInstance.locker.completeUserRegistrationWithLockType(lockType, password: password) {
            (result) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    /**
     Unregisteres the user.
     - parameter completion: The user unregistration process completion.
     */
    @objc func unregisterUserWithCompletion(success: ((Bool)->())?, failure: ((NSError)->())?) {
        CoreSDK.sharedInstance.locker.unregisterUserWithCompletion {
            (result) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    /**
     Unlocks the user using password.
     - parameter password: Password the same type as that used when registering user.
     - parameter completion: The result of user unlock. In case of .Failure see the remainingAttempts attribute. In case of remainingAttempts == 0, the user is automatically unregistered.
     */
    @objc func unlockUserWithPassword(_ password: String?, success: ((Bool)->())?, failure: ((_ error: NSError, _ remainingAttempts: Int)->())?) {
        CoreSDK.sharedInstance.locker.unlockUserWithPassword(password) { (result, remainingAttempts) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error, remainingAttempts ?? -1)
            }
        }
    }
    
    /**
     Unlocks the user using one time password generated by the Locker.
     - parameter completion: The OTP unlock result. There is no remainingAttempts returned from server. After an unsuccessfull unlock is the user automatically unregistered.
     */
    @objc func unlockUserUsingOTPWithCompletion(success: ((Bool)->())?, failure: ((NSError)->())?) {
        CoreSDK.sharedInstance.locker.unlockUserUsingOTPWithCompletion { (result, _) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error)
            }
        }
    }
    
    /**
     Locks the user. This method does no communication to WebApi.
     */
    @objc func lockUser() {
        CoreSDK.sharedInstance.locker.lockUser()
    }
    
    /**
     Changes the user password.
     - parameter oldPassword: The original password of original lockType. Can be nil, when the current lockType is .NoAuth.
     - parameter newLockType: The new lockType for the new password. Can be the same as the original lockType.
     - parameter newPassword: The new password of the new lockType. Can be nil, when the newLockType is .NoAuth.
     - parameter completion: The change password result. In case of .Failure see the remainingAttempts attribute. In case of remainingAttempts == 0, the user is automatically unregistered.
     */
    @objc func changePassword( oldPassword: String?,
                         newLockType: LockType,
                         newPassword: String?,
                         success: ((Bool)->())?,
                         failure: ((_ error: NSError, _ remainingAttempts: Int)->())?) {
        CoreSDK.sharedInstance.locker.changePassword(oldPassword: oldPassword,
                                                     newLockType: newLockType,
                                                     newPassword: newPassword) { (result, remainingAttempts) in
                                                        switch result {
                                                        case .success(let result):
                                                            success?(result)
                                                        case .failure(let error):
                                                            failure?(error, remainingAttempts ?? -1)
                                                        }
        }
    }
    
    
    /**
     Invokes the accessToken refresh using the stored registration code and current access token.
     - parameter completion: The refresh token result.
     */
    @objc func refreshToken(success: ((Bool)->())?, failure: ((_ error: NSError, _ remainingAttempts: Int)->())?) {
        CoreSDK.sharedInstance.locker.refreshToken { (result, remainingAttempts) in
            switch result {
            case .success(let result):
                success?(result)
            case .failure(let error):
                failure?(error, remainingAttempts ?? -1)
            }
        }
    }
    
    /**
     Cancel all running locker operations and return the current lockerStatus in completion handler.
     - parameter completion: The current user status.
     */
    @objc func cancelWithCompletion( _ completion: (( _ status: LockerStatus ) -> ())? ) {
        CoreSDK.sharedInstance.locker.cancelWithCompletion { (status) in
            completion?(status)
        }
    }
    
    /**
     Checks the OAuth2 ULR path returned from the registration callback (from the mobile Safari, for example).
     Parses and stores the OAuth2 registration code for next registration steps.
     - parameter urlPath: The url path to be checked.
     - returns: True, if the urlPath is valid and contains the registration code, false otherwise.
     */
    @objc func canContinueWithOAuth2UrlPath( _ urlPath: String ) -> Bool {
        return CoreSDK.sharedInstance.locker.canContinueWithOAuth2UrlPath(urlPath)
    }
    
    /**
     Unlock after migration. This method will unlock you using the provided data and should be
     used as the migration bridge to unlock without unnecessary new user registration.
     
     - parameter lockType:                 The lockType used.
     - parameter password:                 The password in the raw String format.
     - parameter passwordMigrationProcess: Providing you hash actual hash algorithm.
     - parameter data:                     Locker migration data.
     - parameter callback:                 The result callback.
     */
    func unlockAfterMigration(lockType:                 LockType,
                              password:                 String,
                              passwordMigrationProcess: PasswordMigrationProcess,
                              data:                     LockerMigrationDataDTO,
                              success:                  ((Bool)->())?,
                              failure:                  ((NSError, Int)->())?
        ) {
        CoreSDK.sharedInstance.locker.unlockAfterMigration(lockType: lockType,
                                                           password: password,
                                                           passwordMigrationProcess: passwordMigrationProcess,
                                                           data: data) { (result, remainingAttempts) in
                                                            switch result {
                                                            case .success(let result):
                                                                success?(result)
                                                            case .failure(let error):
                                                                failure?(error, remainingAttempts ?? -1)
                                                            }
        }
    }
    
    @objc func wipeCurrentUser() {
        CoreSDK.sharedInstance.locker.wipeCurrentUser()
    }
    
    
}
