//
//  LockerClient.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 21.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
class LockerClient: NSObject
{
    static let registrationEndPoint   = "locker"
    static let unregistrationEndPoint = "locker"
    static let unlockEndPoint         = "locker/unlock"
    static let passwordChangeEndPoint = "locker/password"
    
    typealias RegistrationResult      = CoreResult<RegistrationResponseDTO>
    typealias UnregisterResult        = CoreResult<ApiDTO>
    typealias UnlockResult            = CoreResult<UnlockResponseDTO>
    typealias UnlockOTPResult         = CoreResult<UnlockOTPResponseDTO>
    typealias PasswordChangeResult    = CoreResult<ChangePasswordResponseDTO>
    typealias RefreshTokenResult      = CoreResult<RefreshTokenResponseDTO>
    
    var locker:          Locker
    var language:        String       = "cs-CZ"
    var requestSigningKey : Data?     = nil
    let wsClientQueue                 = OperationQueue()
    let _syncQueue                    = DispatchQueue( label: "LockerClient.syncQueue")
    var _isCancelled: Bool            = false
    var basePath:        String
    
    //--------------------------------------------------------------------------
    init( locker: Locker, language: String?, requestSigningKey : Data?, apiBasePath: String )
    {
        self.locker            = locker
        self.requestSigningKey = requestSigningKey
        
        if let lang = language {
            self.language = lang
        }
        
        self.wsClientQueue.maxConcurrentOperationCount = 1
        self.wsClientQueue.qualityOfService            = QualityOfService.background
        self.basePath                                  = apiBasePath
        
        super.init()
    }
    
    var isClientCancelled: Bool {
        get {
            var result: Bool!
            self._syncQueue.sync(execute: {
                result = self._isCancelled
            })
            return result
        }
        set {
            self._syncQueue.sync(execute: {
                self._isCancelled = newValue
            })
        }
    }
    
    // MARK: Register user ...
    func register(   _ code: String,
        deviceFingerprint: String,
        userPasswordHash: String,
        completion:@escaping (RegistrationResult) -> Void)
    {
        self.isClientCancelled = false
        
        let dataObject = RegistrationRequestDTO(
            code: code,
            password: userPasswordHash,
            deviceFingerprint: deviceFingerprint,
            scope: self.locker.scope!,
            nonce: self.locker.generateNonce()
        )
        
        let sekData       = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey)
        
        let wsClient = WebServiceClient(
            configuration: WebServicesClientConfiguration(
                endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).registrationEndPoint)",
                apiKey: self.locker.webApiKey,
                language: self.language,
                requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(RegistrationResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(requestObject) { (result:ApiCallResult<DataResponseDTO>) in
                switch result {
                case .success(let (data,_)):
                    
                    if let resultObject:RegistrationResponseDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(RegistrationResult.success(resultObject))
                    }
                    else {
                        completion(RegistrationResult.failure(LockerError(kind: .registrationFailed)))
                    }
                    
                case .failure(let (error,_)):
                    completion(RegistrationResult.failure(error))
                }
            }
            
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.InitLockerClient.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Will send registration\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    // MARK: Unregister user ...
    func unregisterWithCompletion( _ completion: @escaping (UnregisterResult) -> Void)
    {
        self.isClientCancelled = false
        
        guard let clientId          = self.locker.clientId,
            let deviceFingerprint = self.locker.deviceFingerprint
            else {
                completion( UnregisterResult.failure( LockerError(kind: .userUnregistrationFailed ) ) )
                return
        }
        
        let dataObject = UnregisterRequestDTO.init(
            clientId:          clientId,
            deviceFingerprint: deviceFingerprint,
            scope:             self.locker.scope!,
            nonce:             self.locker.generateNonce()
        )
        
        // Generate SEK and encrypt object
        let sekData       = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey)
        
        let wsClient = WebServiceClient( configuration: WebServicesClientConfiguration(
            endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).unregistrationEndPoint)",
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(UnregisterResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.delete(requestObject) { (result:ApiCallResult<DataResponseDTO>) -> Void in
                switch result {
                case .success(let (data, _)):
                    if let resultObject:ApiDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(UnregisterResult.success(resultObject))
                    }
                    else {
                        completion(UnregisterResult.failure(LockerError(kind: .loginFailed)))
                    }
                    
                case .failure(let (error, _)):
                    completion(UnregisterResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.UserUnregistration.rawValue, fileName:  #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Will send unregister user\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    // MARK: Unlock user ...
    func unlockWithPassword( _ passwordHash: String, completion:@escaping (UnlockResult) -> Void)
    {
        self.isClientCancelled = false
        
        guard let clientId = self.locker.clientId,
            let deviceFingerprint = self.locker.deviceFingerprint
            else {
                completion( UnlockResult.failure( LockerError(kind: .loginFailed ) ) )
                return
        }
        
        let dataObject = UnlockRequestDTO.init(clientId: clientId,
            password: passwordHash, deviceFingerprint: deviceFingerprint,
            scope: self.locker.scope!, nonce: self.locker.generateNonce())
        
        // Generate SEK and encrypt object
        let sekData = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey )
        
        let wsClient = WebServiceClient( configuration: WebServicesClientConfiguration(endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).unlockEndPoint)",
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(UnlockResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(requestObject) { (result:ApiCallResult<DataResponseDTO>) -> Void in
                
                if self.isClientCancelled {
                    completion(UnlockResult.failure(CoreSDKError(kind:.operationCancelled)))
                    return
                }
                
                switch result {
                case .success(let (data, _)):
                    if let resultObject:UnlockResponseDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(UnlockResult.success(resultObject))
                    }
                    else {
                        completion(UnlockResult.failure(LockerError(kind: .loginFailed)))
                    }
                    
                case .failure(let (error, _)):
                    completion(UnlockResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.UnlockWithPassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Will send unlock\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())\nlock type:\(self.locker.lockType.toString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    //--------------------------------------------------------------------------
    func unlockAfterMigration( clientId: String, deviceFingerprint: String, passwordHash: String, completion: @escaping (UnlockResult) -> Void)
    {
        self.isClientCancelled = false
        
        let dataObject = UnlockRequestDTO(clientId:          clientId,
                                          password:          passwordHash,
                                          deviceFingerprint: deviceFingerprint,
                                          scope:             self.locker.scope!,
                                          nonce:             self.locker.generateNonce())
        
        // Generate SEK and encrypt object
        let sekData       = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey )
        
        let wsClient      = WebServiceClient( configuration: WebServicesClientConfiguration(endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).unlockEndPoint)",
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(UnlockResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(requestObject) { (result:ApiCallResult<DataResponseDTO>) -> Void in
                
                if self.isClientCancelled {
                    completion(UnlockResult.failure(CoreSDKError(kind:.operationCancelled)))
                    return
                }
                
                switch result {
                case .success(let (data, _)):
                    if let resultObject:UnlockResponseDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(UnlockResult.success(resultObject))
                    }
                    else {
                        completion(UnlockResult.failure(LockerError(kind: .loginFailed)))
                    }
                    
                case .failure(let (error, _)):
                    completion(UnlockResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.UnlockWithPassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Will send unlock\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())\nlock type:\(self.locker.lockType.toString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    func unlockWithOneTimePassword( _ oneTimePassword: String, completion:@escaping (UnlockOTPResult) -> Void)
    {
        self.isClientCancelled = false
        
        guard let clientId = self.locker.clientId,
            let deviceFingerprint = self.locker.deviceFingerprint
            else {
                completion( UnlockOTPResult.failure( LockerError(kind: .loginFailed ) ) )
                return
        }
        
        let dataObject = UnlockOTPRequestDTO.init(clientId: clientId,
            oneTimePassword: oneTimePassword, deviceFingerprint: deviceFingerprint,
            scope: self.locker.scope!, nonce: self.locker.generateNonce())
        
        // Generate SEK and encrypt object
        let sekData = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey )
        
        let wsClient = WebServiceClient( configuration: WebServicesClientConfiguration( endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).unlockEndPoint)",
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(UnlockOTPResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(requestObject) { (result:ApiCallResult<DataResponseDTO>) -> Void in
                
                if self.isClientCancelled {
                    completion(UnlockOTPResult.failure(CoreSDKError(kind:.operationCancelled)))
                }
                
                switch result {
                case .success(let (data, _)):
                    
                    if let resultObject:UnlockOTPResponseDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(UnlockOTPResult.success(resultObject))
                    }
                    else {
                        completion(UnlockOTPResult.failure(LockerError(kind: .loginFailed)))
                    }
                case .failure(let (error, _)):
                    completion(UnlockOTPResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.UnlockWithOTP.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Will send OTP unlock\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    // MARK: Refresh token ...
    
    //--------------------------------------------------------------------------
    func refreshTokenWithCode( _ code: String, refreshToken: String, clientSecret: String, completion:@escaping (RefreshTokenResult) -> Void)
    {
        self.isClientCancelled = false
        
        let dataObject = RefreshTokenRequestDTO(
            code: code,
            clientId: self.locker.oauth2ClientId,
            clientSecret: clientSecret,
            redirectURI: self.locker.redirectUrlPath,
            grantType: "refresh_token",
            refreshToken: refreshToken)

        let wsClient = WebServiceClient(configuration: WebServicesClientConfiguration(endPoint: self.locker.oauth2TokenRefreshUrlPath,
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        wsClient.headers [WebServiceClient.ContentTypeHeaderName] = WebServiceClient.ContentTypeFormUrlEncodedHeaderValue
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(RefreshTokenResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(dataObject) { (result:ApiCallResult<RefreshTokenResponseDTO>) in
                switch result {
                case .success(let (data, _)):
                    completion(RefreshTokenResult.success(data))
                case .failure(let (error, _)):
                    completion(RefreshTokenResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.RefreshToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Will send the refresh token\nURL: \(wsClient.path)\nJSON: \(dataObject.toJSONString())" )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    // MARK: Password change
    func changePassword( _ oldPasswordHash: String,
        newPasswordHash: String,
        completion:@escaping (PasswordChangeResult) -> Void)
    {
        self.isClientCancelled = false
        
        guard let clientId = self.locker.clientId,
            let deviceFingerprint = self.locker.deviceFingerprint
            else {
                completion( PasswordChangeResult.failure( LockerError(kind: .passwordChangeFailed ) ) )
                return
        }
        
        let dataObject = ChangePasswordRequestDTO.init( clientId: clientId,
            oldPassword: oldPasswordHash, newPassword: newPasswordHash,
            deviceFingerprint: deviceFingerprint, scope: self.locker.scope!,
            nonce: self.locker.generateNonce())
        
        // Generate SEK and encrypt object
        let sekData = self.locker.generateSecretData()
        let requestObject = WebServiceUtils.encodeRequestObject(dataObject, key: sekData, publicRSAKey: self.locker.publicKey )
        
        let wsClient = WebServiceClient( configuration: WebServicesClientConfiguration(endPoint: "\(self.locker.basePath)/\(self.basePath)/\(type(of: self).passwordChangeEndPoint)",
            apiKey: self.locker.webApiKey,
            language: self.language,
            requestSigningKey: self.requestSigningKey))
        
        let wsClientOperation = BlockOperation()
        
        wsClientOperation.addExecutionBlock( {
            
            if self.isClientCancelled {
                completion(PasswordChangeResult.failure(CoreSDKError(kind:.operationCancelled)))
            }
            
            wsClient.post(requestObject) { (result:ApiCallResult<DataResponseDTO>) -> Void in
                switch result {
                case .success(let (data, _)):
                    if let resultObject:ChangePasswordResponseDTO = WebServiceUtils.decodeResponseObject(data, sek: sekData) {
                        completion(PasswordChangeResult.success(resultObject))
                    }
                    else {
                        completion(PasswordChangeResult.failure(LockerError(kind: .loginFailed)))
                    }
                case .failure(let (error, _)):
                    completion(PasswordChangeResult.failure(error))
                }
            }
        })
        
        clog(Locker.ModuleName, activityName: LockerActivities.ChangePassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Will send change password\nURL: \(wsClient.path)\n JSON: \(dataObject.toJSONString())"  )
        
        self.addWsClientOperation( wsClientOperation )
    }
    
    func addWsClientOperation( _ operation: BlockOperation )
    {
        self.wsClientQueue.addOperation( operation )
    }
    
    func cancel()
    {
        self.isClientCancelled = true
    }
    
}
