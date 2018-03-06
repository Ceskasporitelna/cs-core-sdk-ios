//
//  LockerApi.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 25.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

/**
The Locker public API.
*/
public protocol LockerAPI
{
    /**
     Name of the notification that will be delivered through NSNotificatoinCenter when locker status changes
     */
    var LockerStatusChangedNotification : String {get}
    
    /**
     Parametres for the one time password generator.
     */
    var otpAttributes: OTPAttributes      { get }
    
    /**
     Ther user status descriptor.
     */
    var status: LockerStatus              { get }
    /**
     The user locker status.
     */
    var lockStatus: LockStatus            { get }
    /**
     A token obtained after the successful registration.
     */
    var accessToken: String?              { get }
    
    /**
     Access token expiration in msec. since 1.1.1970
     */
    var accessTokenExpiration: UInt64?    { get }
    
    /**
     A queue used to return of Locker callbacks.
     - seealso: CoreSDK.sharedInstance.completionQueue
     */
    var completionQueue: DispatchQueue { get }
    
    /**
     The current lockType.
    */
    var lockType: LockType                { get }
    
    /**
     * Url to handle registration redirect call
     */
    var redirectUrlPath:String!  {get}
    
    /**
     Returns the URL to start the registration process.
    */
    func registrationURL() -> URL?

    /**
     Starts registration process by invoking the Safari OAuth2 login page.
     You have to call the CoreSDK.sharedInstance.continueWithUserRegistrationUsingOAuth2Url( oauth2url: NSURL ) method in the application
     delegate to handle the Safari OAuth2 redirect with token.
     - parameter completion: The completion will be invoked, when the CoreSDK.sharedInstance.continueWithUserRegistrationUsingOAuth2Url( oauth2url: NSURL ) handler will be called.
     Inside of this completion you should ask the user for lockType and password, then call the
     completeUserRegistrationWithLockType( lockType: LockType, password: String, completion: RegistrationCompletion )
     method to complete the registration.
     */
    func registerUserWithCompletion( _ completion : @escaping RegistrationCompletion )
    
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
    func continueWithUserRegistrationUsingOAuth2Url(_ oauth2url: URL) -> Bool

    
     /**
     Finishes the user registration.
     - parameter lockType: The user lock type.
     - parameter password: The user password.
     - parameter completion: The registration completion.
     */
    func completeUserRegistrationWithLockType( _ lockType: LockType, password: String?, completion: @escaping RegistrationCompletion )
    
    /**
     Unregisteres the user.
     - parameter completion: The user unregistration process completion.
     */
    func unregisterUserWithCompletion( _ completion: (( _ result: CoreResult<Bool> ) ->())? )
    
    /**
     Unlocks the user using password.
     - parameter password: Password the same type as that used when registering user.
     - parameter completion: The result of user unlock. In case of .Failure see the remainingAttempts attribute. In case of remainingAttempts == 0, the user is automatically unregistered.
     */
    func unlockUserWithPassword( _ password: String?, completion: UnlockCompletion? )
    
    /**
     Unlocks the user using one time password generated by the Locker.
     - parameter completion: The OTP unlock result. There is no remainingAttempts returned from server. After an unsuccessfull unlock is the user automatically unregistered.
     */
    func unlockUserUsingOTPWithCompletion( _ completion: UnlockCompletion? )
    
    /**
     Locks the user. This method does no communication to WebApi.
     */
    func lockUser()
    
    /**
     Changes the user password.
     - parameter oldPassword: The original password of original lockType. Can be nil, when the current lockType is .NoAuth.
     - parameter newLockType: The new lockType for the new password. Can be the same as the original lockType.
     - parameter newPassword: The new password of the new lockType. Can be nil, when the newLockType is .NoAuth.
     - parameter completion: The change password result. In case of .Failure see the remainingAttempts attribute. In case of remainingAttempts == 0, the user is automatically unregistered.
     */
    func changePassword( oldPassword: String?,
                         newLockType: LockType,
                         newPassword: String?,
                         completion: @escaping UnlockCompletion )
    // Refresh token ...
    /**
    Invokes the accessToken refresh using the stored registration code and current access token.
    - parameter completion: The refresh token result.
    */
    func refreshToken( _ completion : @escaping UnlockCompletion )
    
    /**
    Cancel all running locker operations and return the current lockerStatus in completion handler.
     - parameter completion: The current user status.
    */
    func cancelWithCompletion( _ completion: (( _ status: LockerStatus ) -> ())? )
    
    /**
     Checks the OAuth2 ULR path returned from the registration callback (from the mobile Safari, for example).
     Parses and stores the OAuth2 registration code for next registration steps.
     - parameter urlPath: The url path to be checked.
     - returns: True, if the urlPath is valid and contains the registration code, false otherwise.
    */
    func canContinueWithOAuth2UrlPath( _ urlPath: String ) -> Bool
    
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
                              completion :              @escaping UnlockCompletion
                             )
    
    func wipeCurrentUser()
}

//==============================================================================
/**
 * Class PasswordMigrationProcess is required for
 * unlockAfterMigration(password, passwordMigrationProcess, lockerMigrationData, callback)
 * to handle custom password hashing before migration.
 */

@objc public class PasswordMigrationProcess: NSObject
{
    /**
      Transform password according to used hashing algorithm with appropriate salt.
     
      - parameter password:  Password in a raw format before hashing
      - returns: hashed password
     */
    var hashPassword:     ((_ password: String) -> String)
    
    /**
     * Migrate old password string to locker type password string.
     * Required only for lock types .gestureLock and .pinLock
     * --------------------------------------------------
     * GESTURE format: column * matrix_size + row
     * coordinate system is situated into up-left corner.
     * example (gesture grid 3x3, gesture length 5):
     * -------
     * |x|x|x|
     * -------
     * |0|0|x|
     * -------
     * |0|0|x|
     * -------
     * key = "0003060708"
     * --------------------------------------------------
     * PIN format: "123....", numeric value entered by keypad.
     * -------------------------------------------------------------------------
     * HASH computing:
     * hash = (key + deviceFingerprint + vendorIdentifier).sha256()
     * -------------------------------------------------------------------------
     
     - parameter oldPassword: old password in a format used in previous implementation
     - returns: the new password in a format used in Locker SDK implementation. See above description
     */
    var transformPassword:((_ oldPassword: String) -> String)

    //--------------------------------------------------------------------------
   @objc public init(hashPassword: @escaping ((_ password: String) -> String), transformPassword: @escaping ((_ oldPassword: String) -> String))
    {
        self.hashPassword      = hashPassword
        self.transformPassword = transformPassword
    }
}


//==============================================================================
/**
    User locker status.
    - Unregistered: User is not registered yet.
    - Locked: User is registered, but locked.
    - Unlocked: User is registered and unlocked.
*/
@objc public enum LockStatus: UInt8
{
    case unregistered        = 0
    case locked              = 1
    case unlocked            = 2
    

    public func toString() -> String
    {
        switch ( self ) {
        case .unregistered: return CoreSDK.localized("lock-status-unregistered")
        case .locked:       return CoreSDK.localized("lock-status-locked")
        case .unlocked:     return CoreSDK.localized("lock-status-unlocked")
        }
    }
    
    internal func toActivityName() -> String
    {
        switch ( self ) {
        case .unregistered: return "UNREGISTERED"
        case .locked:       return "LOCKED"
        case .unlocked:     return "UNLOCKED"
        }
    }
}

//==============================================================================
/**
    The lock type selected by the user.
    - PinLock: Locked by PIN.
    - BiometricLock: Locked by Biometric - TouchID or FaceID ( available only for iPhone 5s and above, iPad Air 2 and above).
    - GestureLock: Locked by gesture.
    - NoLock: Locked by generated token without user input.
*/
@objc public enum LockType: Int
{
    case pinLock             = 0
    case biometricLock       = 1
    case gestureLock         = 2
    case noLock              = 3
    
    public init(string: String)
    {
        switch string {
        case CoreSDK.localized("auth-method-pin"):
            self = .pinLock
        case CoreSDK.localized("auth-method-fingerprint"):
            self = .biometricLock
        case CoreSDK.localized("auth-method-gesture"):
            self = .gestureLock
        default:
            self = .noLock
        }
    }
    
    public func toString() -> String
    {
        switch ( self ) {
        case .pinLock:         return CoreSDK.localized("auth-method-pin")
        case .biometricLock: return CoreSDK.localized("auth-method-fingerprint")
        case .gestureLock:     return CoreSDK.localized("auth-method-gesture")
        case .noLock:          return CoreSDK.localized("auth-method-none")
        }
    }
}


//==============================================================================
/**
    User status decriptor.
    - lockStatus: The user locker status.
    - lockType: The current LockType.
    - clientId: The clientId, obtained after the sucessfull registration.
    - hasOneTimePasswordKey: A flag indicating, a presence of one time password key in the storage.
    - hasAesEncryptionKey: A flag indicating a presence of the AES encryption key in the storage.
*/
@objc public class LockerStatus: NSObject
{
    @objc public var lockStatus:            LockStatus
    @objc public var lockType:              LockType
    @objc public var clientId:              String?
    @objc public var hasOneTimePasswordKey: Bool = false
    @objc public var hasAesEncryptionKey:   Bool = false
    
    
    override init()
    {
        self.lockStatus = LockStatus.unregistered
        self.lockType = LockType.noLock
        super.init()
    }
}


//==============================================================================
/**
    Attributes for the one time password (OTP) generator used inside of the Locker. Values must match to the WebApi settings.
    - OTP_START: Start date in seconds after 1.1.1970
    - OTP_INTERVAL: Time interval in seconds for OTP genarator.
    - OTP_LENGTH: Raw length of generated OTP.
*/
public struct OTPAttributes
{
    var OTP_START:         UInt32
    var OTP_INTERVAL:      Float64
    var OTP_LENGTH:        Int
    

    public init()
    {
        self.OTP_START    = 1010101010 //In miliseconds
        self.OTP_INTERVAL = 30.0 //Seconds
        self.OTP_LENGTH   = 7 //Seconds
    }
}

/**
    Common completion block type alias for locker unlock methods.
    - parameter result: Result of method call.
    - parameter remainingAttempts: Remaining attempts (for unlock, or password change) returned from server.
*/
public typealias UnlockCompletion = (( _ result: CoreResult<Bool>, _ remainingAttempts: Int? ) -> Void )

/**
 Common completion block type alias for locker registration methods.
 - parameter result: Result of method call.
 */
public typealias RegistrationCompletion = (( _ result: CoreResult<Bool> ) -> Void )

/**
 Completion block that is called when token refresh finishes. Returns true inside the CoreResult if it succeeds, error otherwise
 */
//public typealias RefreshTokenCompletion = (( result: CoreResult<Bool>) -> Void)

