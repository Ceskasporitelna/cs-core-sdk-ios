//
//  Locker+UnlockAfterMigration.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 28/09/2017.
//  Copyright © 2017 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
extension Locker
{
    //------------------------------------------------------------------------------
    public func unlockAfterMigration(lockType:                 LockType,
                                     password:                 String,
                                     passwordMigrationProcess: PasswordMigrationProcess,
                                     data:                     LockerMigrationDataDTO,
                                     completion:               @escaping UnlockCompletion)
    {
        let state = self.status.lockStatus
        guard state == .unregistered else {
            clog(CoreSDK.ModuleName, activityName: LockerActivities.UnlockAfterMigration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: .error, format: "Migration unlock failed. You have to be in UNREGISTERED state." )
            completion(.failure(LockerError.errorOfKind(.migrationUnlockFailed)), nil)
            return
        }
        
        let migrationData = MigrationKeychainData()
        
        migrationData.encryptionKey      = data.encryptionKey
        migrationData.lockType           = lockType
        migrationData.clientId           = data.clientId
        migrationData.deviceFingerprint  = data.deviceFingerprint
        migrationData.oneTimePasswordKey = data.oneTimePasswordKey
        migrationData.refreshToken       = data.refreshToken
        
        self.identityKeeper.storeMigrationData(migrationData)
        
        self.backgroundQueue.async {
            
            var originalPassword = password
            
            // Transform original password for gesture and pin lock types
            
            if lockType == .gestureLock || lockType == .pinLock {
                originalPassword = passwordMigrationProcess.transformPassword(password)
            }
            
            // Unlock with old version of password ...
            
            let oldPassword = passwordMigrationProcess.hashPassword(originalPassword)
            if #available(iOS 9.0, *) {}
            else {
                self.touchIdToken = oldPassword
            }
            
            self.lockerClient.unlockAfterMigration(clientId: data.clientId, deviceFingerprint: data.deviceFingerprint, passwordHash: oldPassword) { result in
                switch result {
                case .success(let unlockResponse):
                    
                    guard let accessToken           = unlockResponse.accessToken,
                          let accessTokenExpiration = unlockResponse.accessTokenExpiration,
                          let encryptionKey         = unlockResponse.encryptionKey else {
                            let error = LockerError.errorOfKind(.migrationUnlockFailed)
                            self.unregisterUser()
                            clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Unlock after migration failed with error: %@", error.localizedDescription )
                            self.completionQueue.async {
                                completion(.failure(error), nil)
                            }
                            return
                    }
                    
                    self.identityKeeper.accessToken           = accessToken
                    self.identityKeeper.accessTokenExpiration = accessTokenExpiration.uint64Value
                    self.identityKeeper.aesEncryptionKey      = encryptionKey
                    
                    if let refreshToken = unlockResponse.refreshToken {
                        self.identityKeeper.refreshToken = refreshToken
                    }
                    
                    self.identityKeeper.saveKeychainData(encryptionKey)
                    
                    self.clientId                             = data.clientId
                    
                    // Change old version of the password to the new one ...
                    
                    self.changePassword(customHash: passwordMigrationProcess, password: password) { result, remainingAttempts  in
                        switch result {
                        case .success(_):
                            self.completionQueue.async {
                                completion(result, nil)
                            }
                            
                        case .failure(let error):
                            self.unregisterUser()
                            clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Password change after migration failed with error: %@", error.localizedDescription )
                            self.completionQueue.async {
                                completion(.failure(LockerError.errorOfKind(.migrationUnlockFailed, underlyingError: error)), nil)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.unregisterUser()
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.UnlockAfterMigration.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: .error, format: "Migration unlock failed with error: \(error.localizedDescription)." )
                    self.completionQueue.async {
                        completion(.failure(LockerError.errorOfKind(.migrationUnlockFailed, underlyingError: error)), nil)
                    }
                    return
                }
            }
        }

    }
}

