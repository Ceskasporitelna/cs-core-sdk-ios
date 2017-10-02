//
//  Locker+ChangePassword.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 12.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
extension Locker
{
    // MARK: Public methods ...
    //--------------------------------------------------------------------------
    public func changePassword( oldPassword: String?,
                                newPassword: String?,
                                 completion: @escaping UnlockCompletion )
    {
        self.changePassword(oldPassword: oldPassword, newLockType: self.lockType, newPassword: newPassword, completion: completion );
    }
    
    
    
    //--------------------------------------------------------------------------
    public func changePassword( oldPassword: String?,
                                newLockType: LockType,
                                newPassword: String?,
                                completion: @escaping UnlockCompletion )
    {
        self.changePasswordInternal(oldPassword: oldPassword, newLockType: self.lockType, newPassword: newPassword, completion: completion )
    }
    
    //--------------------------------------------------------------------------
    internal func changePassword( customHash: @escaping PasswordHashProcess,
                                  password:   String,
                                  completion: @escaping UnlockCompletion )
    {
        self.changePasswordInternal(oldPassword: customHash(password), distortOldPassword: false, newLockType: self.lockType, newPassword: password, completion: completion )
    }
    
    //--------------------------------------------------------------------------
    fileprivate func changePasswordInternal( oldPassword:        String?,
                                             distortOldPassword: Bool = true,
                                             newLockType:        LockType,
                                             newPassword:        String?,
                                             completion:         @escaping UnlockCompletion )
    {
        var oldPasswordHash: String;
        if let userOldPassword = oldPassword {
            oldPasswordHash = distortOldPassword ? self.distortUserPassword( userOldPassword ) : userOldPassword
        }
        else {
            if self.lockType == LockType.noLock, let noAuthPassword = self.noAuthTypePassword  {
                oldPasswordHash = self.distortUserPassword( noAuthPassword )
            }
            else {
                assert( false, "User password can't be nil!" );
                return; // Make compiler happy.
            }
        }
        
        var newPasswordHash: String;
        if ( newLockType == LockType.noLock ) {
            self.noAuthTypePassword = self.generateNonce()
            newPasswordHash         = self.distortUserPassword( self.noAuthTypePassword! )
        }
        else {
            guard let unwrappedPassword = newPassword else {
                assert( false, "New password must not be nil for lockType \(newLockType.toString())" );
                return;
            }
            newPasswordHash = self.distortUserPassword( unwrappedPassword );
        }
        
        //Override newPasswordHash by _fixedNewUserPassword if set. This should be refactored so it is not necesarry
        if ( self._fixedNewUserPassword != nil ) {
            newPasswordHash = self._fixedNewUserPassword!;
        }
        
        self.lockerClient.changePassword( oldPasswordHash, newPasswordHash: newPasswordHash, completion: { result in
            switch ( result) {
            case .success( let responseDTO ):
                let parseResult = self.finishPasswordChangeWithResponseDTO( responseDTO );
                switch ( parseResult.result ) {
                case .success:
                    self.setLockType( newLockType );
                    self.saveKeychainData(nil);
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.ChangePassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Password has been changed successfully." );
                    self.completionQueue.async(execute: { completion( parseResult.result, parseResult.remainingAttempts ); });
                    
                case .failure( let error ):
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.ChangePassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Password change failed with error: %@", error.localizedDescription );
                    
                    var fireCompletion = true;
                    
                    if let attemptsLeft = parseResult.remainingAttempts {
                        if ( attemptsLeft <= 0 ) {
                            fireCompletion = false;
                            self.unregisterUserWithCompletion({ result in
                                self.completionQueue.async(execute: { completion( CoreResult<Bool>.failure( error ), 0 ); });
                            });
                        }
                    }
                    
                    if ( fireCompletion ) {
                        self.completionQueue.async(execute: { completion( CoreResult<Bool>.failure( error ), parseResult.remainingAttempts ); });
                    }
                }
                
            case .failure( let error ):
                if ( error.code == CoreSDKErrorKind.emptyJSONBody.rawValue ) {
                    // Empty JSON is OK here.
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.ChangePassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Password has been changed successfully." );
                    self.setLockType( newLockType );
                    self.saveKeychainData(nil);
                    self.completionQueue.async(execute: { completion( CoreResult.success(true), nil ); });
                }
                else {
                    self.lockUser();
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.ChangePassword.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Password change failed with error: %@", error.localizedDescription );
                    self.completionQueue.async(execute: { completion( CoreResult<Bool>.failure( error ), nil ); });
                }
            }
        });
    }
    
    // MARK: Private methods ...
    
    //--------------------------------------------------------------------------
    fileprivate func finishPasswordChangeWithResponseDTO( _ responseDTO: ChangePasswordResponseDTO ) -> ( result: CoreResult<Bool>, remainingAttempts: Int? )
    {
        if let remainingAttempts = responseDTO.remainingAttempts {
            // Password change failed!
            return ( CoreResult.failure( LockerError(kind: .passwordChangeFailed )), remainingAttempts );
        }
        else {
            // Empty response body is OK.
            return ( CoreResult<Bool>.success(true), nil );
        }
    }

}
