//
//  FilledSigningObject.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


public class FilledSigningObject : SigningObject
{
    public internal(set) var  authorizationType : AuthorizationType?
    public internal(set) var  scenarios : [[AuthorizationType]]?
    
    
    init(signId : String, state:SigningState, authorizationType : AuthorizationType?, signer : Signer){
        self.authorizationType = authorizationType
        super.init(signId: signId, state: state, signer : signer)
    }
    
    
    /**
     Starts signing process with TAC (that usually means signing using OneTimePassword from SMS)
     
     This method will inform the API that the client will sign using TAC.
     
     - parameter callback: called with `TACSigningProcess` that can be used to finish the signing or `SigningError` if the call fails
     */
    public func startSigningWithTac(_ callback: @escaping (_ result:CoreResult<TACSigningProcess>) -> Void)
    {
        self.signer.startSigningWithTAC { (result) in
            switch(result){
            case .success(let process):
                process.signingInfo.signable = self.signable
                process.signingInfo.signable?.signing = process.signingInfo
            case .failure(_):
                break
            }
            callback(result)
        }
    }
    
//    public func startSigningWithMobileCase(callback:(result:CoreResult<MobileCaseSigningProcess>) -> Void){
//        
//    }
    
    
    /**
     Starts signing process with NO_AUTHORIZATION (that usually means signing the order just by clicking some button in UI)
     
     This method signalizes the intent to the API that this order will be signed using NO_AUTHORIZATION method
     
     - parameter callback: called with `NoAuthorizationSigningProcess` that can be used to finish the signing  or `SigningError` if the call fails
     */
    public func startSigningWithNoAuthorization(_ callback: @escaping (_ result:CoreResult<NoAuthorizationSigningProcess>) -> Void)
    {
        self.signer.startSigningWithNoAuthorization { (result) in
            switch(result){
            case .success(let process):
                process.signingInfo.signable = self.signable
                process.signingInfo.signable?.signing = process.signingInfo
            case .failure(_):
                break
            }
            callback(result)
        }
    }
    
    /**
     Determines whether the signing can be currently done with the given AuthorizationType.
    */
    public func canBeSignedWith(_ authorizationType : AuthorizationType) -> Bool
    {
        if self.state == .None{
           return false
        }
        
        if scenarios == nil{
            return authorizationType == self.authorizationType
        }else{
            for (authTypes) in scenarios!{
                if authTypes.first == authorizationType{
                    return true
                }
            }
        }
        return false
    }
    
    /**
     Returns itself in the callback.
    */
    public override func getInfo(_ callback: @escaping (_ result: CoreResult<FilledSigningObject>) -> Void)
    {
        callback(CoreResult.success(self))
    }
    
    /**
     List all current possible authorization types. The list will be empty if the entity is not in a signable state.
     
     - returns: Array of current possible authorization types.
    */
    public func getPossibleAuthorizationTypes() -> [AuthorizationType]
    {
        if self.state == .None{
            return []
        }
        
        if scenarios == nil{
            if let type = self.authorizationType{
                return [type]
            }else{
                return []
            }
        }else{
            return scenarios!.map({$0.first!})
        }
    }
    
    
}
