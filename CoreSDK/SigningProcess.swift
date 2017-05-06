//
//  SigningProcess.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

public class SigningProcess{
    var signingInfo : SigningObject
    
    init(signingInfo : SigningObject){
        self.signingInfo = signingInfo
    }
        
//    func cancel(callback:CoreResult<FilledSigningObject>){
//        
//    }
}

///Represents signing in progress using the TAC authorization method
public class TACSigningProcess : SigningProcess{
    /**
     Finishes signing process with TAC (that usually means signing using OneTimePassword from SMS)
     
     It takes the `oneTimePassword` from the client and sends it to API to finish the TAC signing.
     
     You can call this method only if you successfully called `startSigningWithTAC` before.
     
     - parameter oneTimePassword: One time password obtained from SMS or other means
     - parameter callback: called with `SigningObject` returned from API. Its state will be DONE if the order was signed, the state will be public if more signing is required or `SigningError` if the call fails
     
     */
    public func finishSigning(withOneTimePassword:String, callback:@escaping (_ result:CoreResult<SigningObject>)->Void){
        self.signingInfo.signer.finishSigningWithTAC(withOneTimePassword) { (result) in
            switch(result){
            case .success(let signingInfo):
                signingInfo.signable = self.signingInfo.signable
                signingInfo.signable?.signing = signingInfo
            case .failure(_):
                break
            }
            callback(result)
        }
    }
}

///Represents signing in progress using the NO_AUTHORIZATION authorization method
public class NoAuthorizationSigningProcess : SigningProcess{
    /**
     Finishes signing process using NO_AUTHORIZATION method
     
     This method signalizes the API that the user confirmed signing the order by consent (usually by clicking some button in the UI).
     
     You can call this method only if you successfully called `startSigningWithNoAuthorization` before.
     
     - parameter callback: called with `SigningObject` returned from API. Its state will be DONE if the order was signed, the state will be public if more signing is required or `SigningError` if the call fails
     
     */
    public func finishSigning(_ callback: @escaping (_ result:CoreResult<SigningObject>)->Void){
        self.signingInfo.signer.finishSigningWithNoAuthorization { (result) in
            switch(result){
            case .success(let signingInfo):
                signingInfo.signable = self.signingInfo.signable
                signingInfo.signable?.signing = signingInfo
            case .failure(_):
                break
            }
            callback(result)
        }
    }
}
