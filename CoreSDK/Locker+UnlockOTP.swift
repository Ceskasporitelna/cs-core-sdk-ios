//
//  Locker+UnlockOTP.swift
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
    public func unlockUserUsingOTPWithCompletion( _ completion: UnlockCompletion? )
    {
        do {
            try self.identityKeeper.attemptToAccessKeychainData()
        }
        catch let error {
            clog(Locker.ModuleName, activityName: LockerActivities.UserUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "OTP unlock failed with error: %@", error.localizedDescription )
            self.completionQueue.async(execute: {
                completion?( CoreResult.failure(error as! LockerError), nil )
            })
            return
        }
        
        guard let otp = self.generateOneTimePassword() else {
            self.unregisterUser();
            completion?( CoreResult<Bool>.failure(LockerError(kind: .otpUnlockFailed)), nil );
            return;
        }
        
        clog( Locker.ModuleName, activityName: LockerActivities.OTPUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "New OTP generated: \(otp) with key: \(self.oneTimePasswordKey!) DFP: \(self.deviceFingerprint!) CID: \(self.clientId!)" );
        
        self.lockerClient.unlockWithOneTimePassword( otp, completion: { result in
            switch ( result) {
            case .success( let responseDTO ):
                let parseResult = self.finishUserOTPUnlockWithResponseDTO( responseDTO );
                switch ( parseResult.result ) {
                case .success:
                    clog(Locker.ModuleName, activityName: LockerActivities.OTPUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "OTP login with success: %@", responseDTO );
                    self.completionQueue.async(execute: { completion?( parseResult.result, parseResult.remainingAttempts ); });
                    
                case .failure( let error ):
                    self.unregisterUser();
                    clog(Locker.ModuleName, activityName: LockerActivities.OTPUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "OTP login failed with error: %@", error.localizedDescription );
                    self.completionQueue.async(execute: { completion?( CoreResult<Bool>.failure( error ), parseResult.remainingAttempts ); });
                }
                
            case .failure( let error ):
                if ( error.code == HttpStatusCodeNotAuthenticated ) {
                    self.unregisterUser();
                }
                clog(Locker.ModuleName, activityName: LockerActivities.OTPUnlock.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "OTP login failed with error: %@", error.localizedDescription );
                self.completionQueue.async(execute: { completion?( CoreResult.failure(error), nil ); });
            }
        });
    }
    
    // MARK: Private methods ...
    
    //--------------------------------------------------------------------------
    fileprivate func finishUserOTPUnlockWithResponseDTO( _ responseDTO: UnlockOTPResponseDTO ) -> ( result: CoreResult<Bool>, remainingAttempts: Int? )
    {
        if let encryptionKey = responseDTO.encryptionKey {
            // User is successfully logged in ...
            self.identityKeeper.unlockUser(encryptionKey);
            
            if let refreshToken = responseDTO.refreshToken {
                self.refreshToken = refreshToken;
            }
            if let accessToken = responseDTO.accessToken {
                self.accessToken = accessToken;
            }
            if let accessTokenExpiration = responseDTO.accessTokenExpiration?.uint64Value {
                self.accessTokenExpiration = accessTokenExpiration;
            }
            //Save any changes to keychain data
            self.identityKeeper.saveKeychainData(encryptionKey);
            self.identityKeeper.fireStatusChangeNotificationIfNeeded()
            return ( CoreResult.success(true), nil );
        }
        else {
            return ( CoreResult.failure( LockerError(kind: .loginFailed)), nil );
        }
    }
    
    //--------------------------------------------------------------------------
    func generateOneTimePassword() -> String?
    {
        guard let otpk        = self.oneTimePasswordKey,
              let clientId    = self.clientId,
              let fingerPrint = self.deviceFingerprint
            else {
                return nil;
        }
        let generator = OTPGenerator(base64Otkp: otpk, clientId: clientId, fingerprint: fingerPrint, otpAttributes: self.otpAttributes);
        return generator.generateOneTimePassword(self.currentTimestamp);
    }

}
