//
//  WebApiClientBase.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 11.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

/**
 * WebApiClient log activities.
 */
//==============================================================================
internal enum WebApiClientActivities: String {
    case TrustCertificate    = "TrustCertificate"
    case DataLoading         = "DataLoading"
    case JSONSerialization   = "JSONSerialization"
}

//==============================================================================
open class WebApiClient
{
    internal static let ModuleName      = "WebApiClient"
    
    fileprivate(set) public var config : WebApiConfiguration
    
    
    public let path : String;
    
    
    public var completionQueue: DispatchQueue {
        get {
            return ( self._completionQueue ?? DispatchQueue.main )
        }
        set {
            self._completionQueue = newValue
        }
    }
    
    public var accessTokenProvider: AccessTokenProvider?
    
    fileprivate var _completionQueue: DispatchQueue?

    fileprivate let apiBasePath : String
        
    internal var responseTransforms : [((_ result:MappableApiCallResult) -> MappableApiCallResult)] = [];
    
    //MARK: -

    public init(config : WebApiConfiguration,apiBasePath : String){
        self.config = config
        self.apiBasePath = apiBasePath
        self.path = self.config.environment.apiContextBaseUrl+apiBasePath
        //TODO: validate configuration
    }
    
    /**
     Adds a response trasformation which is applied on each request made by this ApiClient
    */
    public func addResponseTransform(_ transform : @escaping ((_ result:MappableApiCallResult) -> MappableApiCallResult)){
        self.responseTransforms.append(transform)
    }
    
    public func callApi<TResponse:Mappable>(_ url : String,method: Method, headers:[String:String]?,callback: @escaping (_ result:ApiCallResult<TResponse>)->Void){
        self.callApi(url,method:method,payload:nil as ApiDTO?,headers:headers,callback:callback)
    }
    
    public func callApi<TRequest:Mappable,TResponse:Mappable>(_ url : String,method: Method,payload:TRequest?, headers:[String:String]?,callback:@escaping (_ result:ApiCallResult<TResponse>)->Void)
    {
        GlobalUtilityQueue.async(execute: {
            let webServiceClient = WebServiceClient(path: url, apiKey: self.config.webApiKey, language: self.config.language, requestSigningKey: self.config.signingKey)
            //self.setHeaders(webServiceClient,headers: headers)
            self.setHeaders(webServiceClient,headers: headers, completion: { result in
                switch ( result ) {
                case .success(_):
                    webServiceClient.callApi(payload, method: method) { (result : ApiCallResult<TResponse>) -> Void in
                        let transformed = self.applyResponseTransforms(result) as! ApiCallResult<TResponse>
                        self.completionQueue.async(execute: {
                            callback(transformed)
                        })
                    }

                case .failure( let error ):
                    callback( ApiCallResult.failure(error, ApiCallResponse()))
                }
            })
            
        })
    }
    
    public func callApi<TResponse:Mappable>(_ url : String,method: Method,parameters:[String:AnyObject]?, headers:[String:String]?,callback:@escaping (_ result:ApiCallResult<TResponse>)->Void)
    {
        //TODO refactor to call the callApi with all parameters
        GlobalUtilityQueue.async(execute: {
            let webServiceClient = WebServiceClient(path: url, apiKey: self.config.webApiKey, language: self.config.language, requestSigningKey: self.config.signingKey)
            //self.setHeaders(webServiceClient,headers: headers)
            self.setHeaders(webServiceClient,headers: headers, completion: { result in
                switch ( result ) {
                case .success(_):
                    webServiceClient.callApi(parameters, method: method) { (result : ApiCallResult<TResponse>) -> Void in
                        let transformed = self.applyResponseTransforms(result) as! ApiCallResult<TResponse>
                        self.completionQueue.async(execute: {
                            callback(transformed)
                        })
                    }
                    
                case .failure( let error ):
                    callback( ApiCallResult.failure(error, ApiCallResponse()))
                }
            })
        })
    }
    
    public func callApi<TResponse:Mappable>(_ url : String,method: Method,parameters:[String:AnyObject]?, headers:[String:String]?,dataTransform:((_ data:AnyObject?)->AnyObject?)?,callback:@escaping (_ result:ApiCallResult<TResponse>)->Void)
    {        
        GlobalUtilityQueue.async(execute: {
            let webServiceClient = WebServiceClient(path: url, apiKey: self.config.webApiKey, language: self.config.language, requestSigningKey: self.config.signingKey)
            
            self.setHeaders(webServiceClient,headers: headers, completion: { result in
                switch ( result ) {
                case .success(_):
                    webServiceClient.dataTransform = dataTransform
                    webServiceClient.callApi(parameters, method: method) { (result : ApiCallResult<TResponse>) -> Void in
                        let transformed = self.applyResponseTransforms(result) as! ApiCallResult<TResponse>
                        self.completionQueue.async(execute: {
                            callback(transformed)
                        })
                    }
                    
                case .failure( let error ):
                    callback( ApiCallResult.failure(error, ApiCallResponse()))
                }
            })
        })
    }
    
    public func callApi<TResponse:Mappable>(_ url : String,method: Method,data:Data, headers:[String:String]?,dataTransform:((_ data:AnyObject?)->AnyObject?)?,callback:@escaping (_ result:ApiCallResult<TResponse>)->Void)
    {
        GlobalUtilityQueue.async(execute: {
            let webServiceClient = WebServiceClient(path: url, apiKey: self.config.webApiKey, language: self.config.language, requestSigningKey: self.config.signingKey)
            var headersDict = headers != nil ? headers! : [:]
            if(headersDict["content-type"] == nil) {
                headersDict["content-type"] = "application/octet-stream"
            }
            self.setHeaders(webServiceClient,headers: headersDict, completion: { result in
                switch ( result ) {
                case .success(_):
                    webServiceClient.dataTransform = dataTransform
                    webServiceClient.uploadData(data, method: method, callback: { (result : ApiCallResult<TResponse>) -> Void  in
                        let transformed = self.applyResponseTransforms(result) as! ApiCallResult<TResponse>
                        self.completionQueue.async(execute: {
                            callback(transformed)
                        })
                    })
                    
                case .failure( let error ):
                    callback( ApiCallResult.failure(error, ApiCallResponse()))
                }
            })
        })
    }
    
    public func callApi(method: Method, url : String, headers:[String:String]?, parameters:[String:AnyObject]?, dataTransform:((_ data:AnyObject?)->AnyObject?)?, callback: @escaping (_ result:ApiCallResult<String>)->Void)
    {
        GlobalUtilityQueue.async(execute: {
            let webServiceClient = WebServiceClient(path: url, apiKey: self.config.webApiKey, language: self.config.language, requestSigningKey: self.config.signingKey)
            let headersDict      = headers != nil ? headers! : [:]
            
            self.setHeaders(webServiceClient,headers: headersDict, completion: { result in
                switch ( result ) {
                case .success(_):
                    webServiceClient.dataTransform = dataTransform
                    webServiceClient.downloadFileWithMethod( method, parameters: parameters, callback: { (result : ApiCallResult<String>) -> Void  in
                        self.completionQueue.async(execute: {
                            callback(result)
                        })
                    })
                    
                case .failure( let error ):
                    callback( ApiCallResult.failure(error, ApiCallResponse()))
                }
            })
        })
    }
    
    
    public func pathAppendedWith(_ appendix:String?) -> String
    {
        if let appendixString = appendix{
            return self.path + "/" + appendixString
        } else {
            return self.path
        }
    }
    
    fileprivate func setHeaders(_ webServiceClient : WebServiceClient,headers:[String:String]?, completion: ( (_ result: CoreResult<Bool>) -> Void )? )
    {
        if let accessTokenProvider = self.accessTokenProvider {
            accessTokenProvider.getAccessToken( { result in
                switch ( result ) {
                case .success( let accessToken ):
                    webServiceClient.headers["authorization"] = "bearer \(accessToken)"
                    
                case .failure( let error ):
                    if ( !LockerError.isError( error, ofKind: .noAccessToken ) ) {
                        completion?( CoreResult.failure(error))
                        return
                    }
                }
                
                if let headers = headers{
                    for (key, value) in headers {
                        webServiceClient.headers[key] = value
                    }
                }
                
                completion?( CoreResult.success(true))
            })
        }
        else {
            if let headers = headers{
                for (key, value) in headers {
                    webServiceClient.headers[key] = value
                }
            }
            completion?( CoreResult.success(true))
        }
    }
    
    fileprivate func applyResponseTransforms<TResponse:Mappable>(_ response:ApiCallResult<TResponse>) -> Any{
        var transformedResponse = response
        for (transform) in self.responseTransforms{
            transformedResponse = transform(MappableApiCallResult.fromApiCallResult(response) ).toApiCallResult(response)
        }
        return transformedResponse
    }
    
    
}
