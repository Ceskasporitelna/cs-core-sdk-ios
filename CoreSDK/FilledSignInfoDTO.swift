//
//  FilledSignInfoDTO.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 20/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


class FilledSignInfoDTO : WebApiEntity{
    
    var authorizationType : String?
    var scenarios : [[String]]?
    var state : String!
    var signId : String!
    
    var scenariosEnums : [[AuthorizationType]]?{
        
        if let scenarios = self.scenarios{
            var scenariosAsEnums : [[AuthorizationType]] = []
            for scenario in scenarios{
                var sequence : [AuthorizationType] = []
                for auth in scenario{
                    if let authEnum  = AuthorizationType(rawValue: auth){
                        sequence.append(authEnum)
                    }
                }
                if sequence.count > 0{
                    scenariosAsEnums.append(sequence)
                }
            }
            if scenariosAsEnums.count > 0{
                return scenariosAsEnums
            }
        }
        return nil
    }
    
    var stateEnum : SigningState?{
        return SigningState(rawValue: state)
    }
    
    var authorizationTypeEnum : AuthorizationType?{
        if let type = authorizationType{
            return AuthorizationType(rawValue: type)
        }
        return nil
    }
    
    override func mapping(_ map: Map) {
        self.authorizationType <- map["authorizationType"]
        self.scenarios <- map["scenarios"]
        self.state <- map["signInfo.state"]
        self.signId <- map["signInfo.signId"]
    }
    
}
