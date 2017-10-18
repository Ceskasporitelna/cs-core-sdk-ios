//
//  Locker+UnlockOrRegister.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 12.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
extension Locker
{
    
    // MARK: User registration ...
    public func registrationURL() -> URL?
    {
        let urlPath = String( format: type(of: self).OAuth2RequestFormat, self.oauth2UrlPath, self.redirectUrlPath, self.oauth2ClientId )
        return URL(string: urlPath )
    }
    
    //--------------------------------------------------------------------------
    public func registerUserWithCompletion( _ completion : @escaping RegistrationCompletion )
    {
        GlobalUserInteractiveQueue.async(execute: {
            if let url = self.registrationURL() {
                
                self.useOAuth2URLHandler( self.proceedWithUserRegistrationUsingOAuth2Url, completion: completion )
                
                GlobalUserInteractiveQueue.async(execute: {
                    clog(Locker.ModuleName, activityName: LockerActivities.UserRegistration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "OAuth2 request has been send with url: \(url)")
                    if UIApplication.shared.openURL(url) {
                        self.completionQueue.async(execute: { completion( CoreResult<Bool>.success(true) ) })
                    }
                    else {
                        self.completionQueue.async(execute: { completion( CoreResult<Bool>.failure(LockerError(kind: .registrationFailed) ) ) })
                    }
                })
            }
        })
    }
    
    
    //--------------------------------------------------------------------------
    internal func proceedWithUserRegistrationUsingOAuth2Url( _ oauth2url: URL ) -> Bool
    {
        let urlPath = oauth2url.absoluteString
        if !self.canContinueWithOAuth2UrlPath(urlPath) {
            return false
        }
        
        clog(Locker.ModuleName, activityName: LockerActivities.UserRegistration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Got OAuth2 URL: \(oauth2url)" )
        
        guard let oauth2handler = self.oauth2handler else {
            assert( false, "Property CoreSDK.sharedInstance.locker.oauth2handler not set, can not proceed with registration!" )
            return false
        }
        guard let completion = oauth2handler.completion else {
            assert( false, "Property CoreSDK.sharedInstance.locker.oauth2handler.completion not set, can not proceed with registration!" )
            return false
        }
        
        self.completionQueue.async(execute: { completion(CoreResult<Bool>.success(true) ) })
        
        return true
    }
    
    
    //--------------------------------------------------------------------------
    public func completeUserRegistrationWithLockType( _ lockType: LockType, password: String?, completion: @escaping RegistrationCompletion )
    {
        guard let oauth2handler = self.oauth2handler else {
            assert( false, "Property CoreSDK.oauth2handler not set, can not proceed with registration!" )
            return
        }
        
        guard let code = oauth2handler.code else {
            completion( CoreResult.failure( LockerError(kind: .wrongOAuth2Url ) ) )
            return
        }
        
        self.completeUserRegistrationWithCode( code, lockType: lockType, password: password, completion: completion )
    }
    
    
    //--------------------------------------------------------------------------
    public func completeUserRegistrationWithCode( _ code: String, lockType: LockType, password: String?, completion: @escaping RegistrationCompletion )
    {
        clog(Locker.ModuleName, activityName: LockerActivities.UserRegistration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "User will be registered with code %@", code )
        
        self.setLockType( lockType )
        
        let deviceFingerprint  = ( self.isRunningInTestMode ? self.deviceFingerprint : WebServiceUtils.generateUUID() )!
        self.deviceFingerprint = deviceFingerprint
        
        var passwordHash: String
        if let userPassword = password {
            passwordHash = self.distortUserPassword( userPassword )
            print("*** PASSWORD HASH ***\n\(passwordHash)\n*** PASSWORD HASH ***")
        } else {
            if lockType == LockType.noLock {
                self.noAuthTypePassword = self.generateNonce()
                passwordHash = self.distortUserPassword( self.noAuthTypePassword! )
            } else {
                assert( false, "User password can't be nil!" )
                return // Make compiler happy.
            }
        }
        
        self.lockerClient.register( code, deviceFingerprint: deviceFingerprint, userPasswordHash: passwordHash, completion: { result in
            switch result {
            case .success( let responseDTO ):
                let parseResult = self.finishUserRegistrationWithResponseDTO( responseDTO, lockType: lockType, deviceFingerprint: deviceFingerprint, code: code )
                self.completionQueue.async(execute: {
                    completion(parseResult )
                })
                
            case .failure( let error ):
                self.completionQueue.async(execute: { completion(CoreResult<Bool>.failure( error) ) })
            }
        })
    }
    
    //--------------------------------------------------------------------------
    fileprivate func finishUserRegistrationWithResponseDTO( _ responseDTO: RegistrationResponseDTO,
        lockType: LockType,
        deviceFingerprint: String,
        code: String ) -> CoreResult<Bool>
    {
        //TODO: all of this should be refactored into identity keeper
        guard let clientId       = responseDTO.clientId,
            let oneTimePassword = responseDTO.oneTimePasswordKey,
            let accessToken     = responseDTO.accessToken,
            let refreshToken    = responseDTO.refreshToken,
            let encryptionKey   = responseDTO.encryptionKey,
            let expiration      = responseDTO.accessTokenExpiration
            else {
                self.unregisterUser()
                clog(Locker.ModuleName, activityName: LockerActivities.UserRegistration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Parsing of RegistrationResponseDTO failed.\nResponse data:%@", responseDTO.toJSONString() )
                return CoreResult<Bool>.failure(LockerError(kind: .parseError))
        }
        print("*** EK Data ***")
        print("clientId:           \(clientId)")
        print("deviceFingerprint:  \(deviceFingerprint)")
        print("encryptionKey:      \(encryptionKey)")
        print("oneTimePasswordKey: \(oneTimePassword)")
        print("refreshToken:       \(refreshToken)")
        print("*** EK Data ***")
        
        self.identityKeeper.initEkData()
        self.clientId              = clientId
        self.deviceFingerprint     = deviceFingerprint
        self.oneTimePasswordKey    = oneTimePassword
        self.accessToken           = accessToken
        self.refreshToken          = refreshToken
        
        self.setLockType( lockType)
        
        self.aesEncryptionKey      = encryptionKey
        self.oauth2Code            = code
        self.accessTokenExpiration = expiration.uint64Value
        
        self.saveKeychainData(encryptionKey)
        self.identityKeeper.fireStatusChangeNotificationIfNeeded()
        
        return CoreResult<Bool>.success(true)
    }
    
    // MARK: User unlock ...
    public func unlockUserWithPassword( _ password: String?, completion: UnlockCompletion? )
    {
        do {
            try self.identityKeeper.attemptToAccessKeychainData()
        }
        catch let error {
            clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Unlock failed with error: %@", error.localizedDescription )
            self.completionQueue.async(execute: {
                completion?( CoreResult.failure(error as! LockerError), nil )
            })
            return
        }
        
        var passwordHash: String
        if let userPassword = password {
            passwordHash = self.distortUserPassword( userPassword )
            
        }
        else {
            if self.lockType == LockType.noLock, let noAuthPassword = self.noAuthTypePassword {
                passwordHash = self.distortUserPassword( noAuthPassword )
            }
            else {
                assert( false, "User password can't be nil." )
                return // Make compiler happy.
            }
        }
        
        self.lockerClient.unlockWithPassword( passwordHash, completion: { unlockResult in
            switch unlockResult {
            case .success( let responseDTO ):
                let parseResult = self.finishUserUnlockWithResponseDTO( responseDTO )
                switch parseResult.result {
                case .success:
                    clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Unlock with success: %@", responseDTO )
                    self.completionQueue.async(execute: { completion?( parseResult.result, parseResult.remainingAttempts ) })
                    
                case .failure( let error ):
                    clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Unlock failed with error: %@", error.localizedDescription )
                    
                    var fireCompletion = true
                    
                    if let attemptsLeft = parseResult.remainingAttempts {
                        clog(CoreSDK.ModuleName, activityName: LockerActivities.UnlockWithPassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.warning, format: "Attempts left:\(attemptsLeft)." )
                        if attemptsLeft <= 0 || self.lockType == LockType.fingerprintLock {
                            fireCompletion = false
                            self.unregisterUserWithCompletion({ result in
                                self.completionQueue.async(execute: { completion?( CoreResult<Bool>.failure( error ), 0 ) })
                            })
                        }
                    }
                    
                    if fireCompletion {
                        self.completionQueue.async(execute: { completion?( CoreResult<Bool>.failure( error ), parseResult.remainingAttempts ) })
                    }
                }
                
            case .failure( let error ):
                clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Unlock failed with error: %@", error.localizedDescription )
                
                if ( error.code == HttpStatusCodeNotAuthenticated || ( error is LockerError && (error as! LockerError).kind == .noAuthToken )) {
                    self.unregisterUser()
                }
                
                self.completionQueue.async(execute: {
                    completion?( CoreResult.failure(error), nil )
                })
            }
        })
    }
    
    internal func finishUserUnlockWithResponseDTO(_ responseDTO: UnlockResponseDTO) -> ( result: CoreResult<Bool>, remainingAttempts: Int? )
    {
        do {
            try self.identityKeeper.attemptToAccessKeychainData()
        }
        catch let error {
            clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Unlock failed with error: %@", error.localizedDescription )
            return ( CoreResult.failure( error as! LockerError), nil )
        }
        
        if let encryptionKey = responseDTO.encryptionKey {
            if responseDTO.accessToken != nil && responseDTO.accessToken == ""{
                self.identityKeeper.unregisterUser()
                return ( CoreResult.failure( LockerError(kind: .noAuthToken)), nil )
            }
            
            self.identityKeeper.unlockUser(encryptionKey)
            
            if let accessToken = responseDTO.accessToken  {
                self.accessToken = accessToken
            }
            
            if let refreshToken = responseDTO.refreshToken {
                self.refreshToken = refreshToken
            }
            
            if let accessTokenExpiration = responseDTO.accessTokenExpiration?.uint64Value {
                self.accessTokenExpiration = accessTokenExpiration
            }

            self.identityKeeper.saveKeychainData(encryptionKey);
            
            self.identityKeeper.fireStatusChangeNotificationIfNeeded();
            
            return ( CoreResult.success(true), nil )
        }
        else {
            if let remainingAttempts = responseDTO.remainingAttempts {
                return ( CoreResult.failure( LockerError(kind: .loginFailed)), remainingAttempts )
            }
            else {
                return ( CoreResult.failure( LockerError(kind: .loginFailed)), nil )
            }
        }
    }
    
}
