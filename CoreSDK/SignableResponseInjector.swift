//
//  SignableResponseInjector.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 12/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


class SignableResponseInjector
{
    init(){
    }
    
    func injectSigningObject(_ json:AnyObject, signableEntity:Signable, client : WebApiClient){
        let entity = signableEntity
        if let rawSignInfo = SignableResponseParser.parseSignableResponse(json){
            let signer = Signer(signUrl: entity.signUrl, signId: rawSignInfo.signId, client: client)
            let signInfo = SigningObject(signId: rawSignInfo.signId, state: rawSignInfo.state, signer: signer)
            entity.signing = signInfo
        }
        entity.signing?.signable = entity
    }
    
}

private class SignableResponseParser
{
    static func parseSignableResponse(_ json : AnyObject) -> (signId : String, state : SigningState)?{
        if let jsonDict = json  as? [String : AnyObject]{
            if let signInfoData = jsonDict["signInfo"] as? [String: AnyObject]{
                guard
                    let signId : String = signInfoData["signId"] as? String,
                    let state : String  = signInfoData["state"] as? String,
                    let stateEnum = SigningState(rawValue: state)
                else{
                    return nil
                }
                return (signId: signId, state:stateEnum)
            }
        }
        return nil
    }
}
