//
//  CoreSDKobjC.swift
//  CSCoreSDKTestApp
//
//  Created by Michal Sverak on 10/23/17.
//  Copyright © 2017 Applifting. All rights reserved.
//

/*
 Here is a short list of Swift features that are not available in objective-c: tuples,
 generics, any global variables, structs, typealiases, or enums defined in swift,
 and the top-level swift functions.
 https://medium.com/ios-os-x-development/swift-and-objective-c-interoperability-2add8e6d6887
 */

import Foundation

public class CoreSDKobjC: NSObject {
    
    public static var sharedInstance = CoreSDKobjC()
    
    // MARK: Configuration
    
    public func useWebApiKey(key: String) {
        
        CoreSDK.sharedInstance.useWebApiKey(key)
    }
    
    public func useEnvironment(environment: Environment) {
        
        CoreSDK.sharedInstance.useEnvironment(environment)
    }
    
    public func useLanguage(language: String) {
        
        CoreSDK.sharedInstance.useLanguage(language)
    }
    
    public func useRequestSigning(signing: String) {
        
        CoreSDK.sharedInstance.useRequestSigning(signing)
    }
    
    public func useLocker(clientId: String, clientSecret: String, publicKey: String, redirectUrlPath: String, scope: String) {
        
        CoreSDK.sharedInstance.useLocker(clientId: clientId,
                                         clientSecret: clientSecret,
                                         publicKey: publicKey,
                                         redirectUrlPath: redirectUrlPath,
                                         scope: scope)
    }
    
    public func customEnvironment(apiContextBaseUrl: String, oAuth2ContextBaseUrl: String) -> Environment {
        
        return Environment(apiContextBaseUrl: apiContextBaseUrl, oAuth2ContextBaseUrl: oAuth2ContextBaseUrl)
    }
}
