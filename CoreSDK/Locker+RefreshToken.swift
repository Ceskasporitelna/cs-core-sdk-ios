//
//  Locker+RefreshToken.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 17.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
extension Locker
{
    
    // MARK: Refresh token ...
    
    //--------------------------------------------------------------------------
    public func refreshToken( _ completion : @escaping UnlockCompletion )
    {
        guard let oAuth2Code   = self.oauth2Code,
              let refreshToken = self.refreshToken else {
                let error = LockerError(kind: .noRefreshToken )
                clog(CoreSDK.ModuleName, activityName: LockerActivities.RefreshToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Refresh token failed with error: %@", error.localizedDescription )
                self.completionQueue.async(execute: { completion( CoreResult.failure(error), nil ); })
                
                return
        }
        
        self.lockerClient.refreshTokenWithCode( oAuth2Code,
                                      refreshToken: refreshToken,
                                      clientSecret: self.oauth2ClientSecret,
                                        completion: { result in
            let refreshResult = result;
            switch ( refreshResult) {
            case .success( let responseDTO ):
                let parseResult = self.finishRefreshTokenWithResponseDTO( responseDTO );
                switch ( parseResult ) {
                case .success:
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.RefreshToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Refresh token with success: %@", responseDTO );
                    self.completionQueue.async(execute: { completion( parseResult, nil ); });
                    
                case .failure( let error ):
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.RefreshToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Refresh token failed with error: %@", error.localizedDescription );
                    self.completionQueue.async(execute: { completion( CoreResult<Bool>.failure( error ), nil ); });
                }
                
            case .failure( let error ):
                clog(CoreSDK.ModuleName, activityName: LockerActivities.RefreshToken.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Refresh token failed with error: %@", error.localizedDescription );
                self.completionQueue.async(execute: { completion( CoreResult.failure(error), nil ); });
            }
        });
    }
    
    // MARK: Private methods ...
    
    //--------------------------------------------------------------------------
    fileprivate func finishRefreshTokenWithResponseDTO( _ responseDTO: RefreshTokenResponseDTO ) -> CoreResult<Bool>
    {
        guard let expiresIn             = responseDTO.expiresIn,
              let tokenType             = responseDTO.tokenType,
              let accessToken           = responseDTO.accessToken else {
                return CoreResult.failure( LockerError(kind: .loginFailed));
        }
        
        self.accessToken           = accessToken;
        self.tokenType             = tokenType;
        //Convert to milisecond timestamp -> We have to multiply it by 1000 because the returned time interval is in seconds
        //Also substract 5 seconds to account for roundtrip time to server and back
        let accessTokenExpiration = UInt64(Date().timeIntervalSince1970 + Double(expiresIn) - 5)*1000
        self.accessTokenExpiration = accessTokenExpiration;
        //Save refreshed token into the keychain
        self.saveKeychainData(nil)
        return CoreResult.success(true);
    }
    
}
