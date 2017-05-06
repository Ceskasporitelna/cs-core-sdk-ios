//
//  WebApiConfiguration.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 06/01/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


public class WebApiConfiguration{
    
    public let webApiKey : String
    public var language : String
    public let environment  : Environment
    public var signingKey : Data?
    
    public init(webApiKey:String,environment:Environment,language: String, signingKey : Data?)
    {
        self.webApiKey = webApiKey
        self.language = language
        self.signingKey = signingKey
        self.environment = environment
    }
    
    public func copyConfig() -> WebApiConfiguration
    {
        return WebApiConfiguration(webApiKey: self.webApiKey, environment: self.environment, language: self.language, signingKey: self.signingKey)
    }
    
}
