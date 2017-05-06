//
//  Locker+Unregister.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 12.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
extension Locker
{
    //--------------------------------------------------------------------------
    public func unregisterUserWithCompletion( _ completion: (( _ result: CoreResult<Bool> ) ->())? )
    {
        self.lockerClient.unregisterWithCompletion( { result in
            self.unregisterUser();
            switch ( result) {
            case .success:
                clog(CoreSDK.ModuleName, activityName: LockerActivities.UserUnregistration.rawValue, fileName:#file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "User unregistration failed." );
                self.completionQueue.async(execute: { completion?( CoreResult<Bool>.failure( LockerError(kind: .userUnregistrationFailed ) ) ); });
                
            case .failure( let error ):
                if ( error.code == CoreSDKErrorKind.emptyJSONBody.rawValue || error.code == HttpStatusCodeNoContent ) {
                    // Empty JSON is OK here.
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.UserUnregistration.rawValue, fileName:#file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "User unregistered." );
                    self.completionQueue.async(execute: { completion?( CoreResult.success(true) ); });
                }
                else {
                    clog(CoreSDK.ModuleName, activityName: LockerActivities.UserUnregistration.rawValue, fileName:#file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "User unregistration failed with error \(error.localizedDescription)." );
                    self.completionQueue.async(execute: { completion?( CoreResult.failure(error) ); });
                }
            }
        });
    }

}
