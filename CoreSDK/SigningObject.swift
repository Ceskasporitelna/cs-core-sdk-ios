//
//  SigningObject.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

public class SigningObject
{
    public internal(set) var  state : SigningState
    
    public internal(set) var  signId : String
    
    public internal(set) weak var signable : Signable?
    
    internal let signer : Signer
    
    var signingInfo : FilledSigningObject?{
        if (self is FilledSigningObject){
            return self as? FilledSigningObject
        }else{
            return nil
        }
    }
    
    init(signId : String, state:SigningState, signer : Signer){
        self.signId = signId
        self.state = state
        self.signer = signer
    }
    
    ///Will be true if the signing is complete
    public var isDone : Bool{
        if(self.state == .Done){
            return true
        }
        return false
    }
    
    ///Will be true if the signing was cancelled
    public var isCancelled : Bool{
        if(self.state == .Cancelled){
            return true
        }
        return false
    }
    
    ///Will be true if signing still needs to be done
    public var isOpen : Bool{
        if(self.state == .Open){
            return true
        }
        return false
    }
    
    /**
     Obtains current signing info with full details from the API OR it returns itself if this signing object is already a `FilledSigningObject`
     
     - parameter callback: called with `FilledSigningObject` or `SigningError` if the call fails
     */
    public func getInfo(_ callback: @escaping (_ result:CoreResult<FilledSigningObject>)->Void){
        self.signer.getSigningInfo { (result) in
            switch result {
            case .success(let filledInfo):
                filledInfo.signable = self.signable
                filledInfo.signable?.signing = filledInfo
            case .failure(_):
                break
            }
            callback(result)
        }
    }
    
    /**
     Obtains current signing info with full details from the API. This method always fetches fresh `FilledSigningObject` from the API.
     
     - parameter callback: called with `FilledSigningObject` returned from API  or `SigningError` if the call fails
     */
    public func refreshInfo(_ callback: @escaping (_ result: CoreResult<FilledSigningObject>) -> Void){
        self.getInfo(callback)
    }
    
    
}
