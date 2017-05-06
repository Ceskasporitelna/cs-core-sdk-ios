//
//  WebServiceClient.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 28.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


//==============================================================================
public struct WebServicesClientConfiguration
{
    var endPoint: String!
    var apiKey: String?
    var language: String?
    var requestSigningKey: Data?
    
    
    public init( endPoint: String, apiKey: String?, language: String?, requestSigningKey : Data? )
    {
        self.apiKey = apiKey
        self.endPoint = endPoint
        self.language = language
        self.requestSigningKey = requestSigningKey
    }
    
    public init( endPoint: String, apiKey: String? )
    {
        self.init( endPoint: endPoint, apiKey: apiKey, language: nil,requestSigningKey:nil )
    }
    
}

//==============================================================================
public class WepApiConvertibleRequest: URLRequestConvertible
{
    var URLRequest: NSMutableURLRequest {
        return self._mutableUrlRequest
    }

    
    fileprivate var _mutableUrlRequest: NSMutableURLRequest
    
    required public init( url: Foundation.URL! )
    {
        self._mutableUrlRequest = NSMutableURLRequest(url: url)
    }
}

//==============================================================================
public class WebServiceClient: NSObject
{
    static let ApiKeyHeaderName             = "web-api-key"
    static let ContentTypeHeaderName        = "content-type"
    static let AcceptLanguageHeaderName     = "accept-language"
    static let AcceptHeaderName             = "accept"
    static let ContentTypeFormUrlEncodedHeaderValue = "application/x-www-form-urlencoded"
    
    let path: String // URL path
    var queue: DispatchQueue = DispatchQueue.main // Queue to call callbacks on
    public var headers: [String:String]
    
    //Used when some http header should be present in requests in all clients. This is usefull for testing
    public static var globalHeaders :[String:String] = [:]
    
    let _requestSigner: RequestSigner?
    var requestSigner: RequestSigner? {
        get{
            return _requestSigner
        }
    }
    
    var dataTransform : ((_ data:AnyObject?) -> AnyObject?)?
    
    static func allowUntrustedCertificates(_ allow:Bool){
        let manager = Manager.sharedInstance
        if allow {
            // Trust any server certificate ...
            clog( CoreSDK.ModuleName, activityName: WebApiClientActivities.TrustCertificate.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "WARNING! Allowing untrusted certificates across the APP!" )
            manager.delegate.sessionDidReceiveChallenge = { session, challenge in
                
                var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
                var credential: URLCredential?
                
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    disposition = URLSession.AuthChallengeDisposition.useCredential
                    credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                } else {
                    if challenge.previousFailureCount > 0 {
                        disposition = .cancelAuthenticationChallenge
                    } else {
                        credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                        
                        if credential != nil {
                            disposition = .useCredential
                        }
                    }
                }
                return (disposition, credential)
            }
        } else{
            manager.delegate.sessionDidReceiveChallenge = nil
        }
    }
    
    init(path: String, apiKey: String?, language: String?, requestSigningKey : Data?)
    {
        self.path = path
        if let apiKeyHeader = apiKey {
            self.headers = [type(of: self).ApiKeyHeaderName: apiKeyHeader]
        } else {
            self.headers = [String: String]()
        }
        
        for (headerName, headerVal) in WebServiceClient.globalHeaders{
            self.headers[headerName] = headerVal
        }
        
        //Set default accept to application/json
        self.headers[WebServiceClient.AcceptHeaderName]  = "application/json"
        
        if let acceptLanguage = language {
            self.headers [type(of: self).AcceptLanguageHeaderName] = acceptLanguage
        }
        
        if let signingKey = requestSigningKey, let webApiKey = apiKey{
            _requestSigner = RequestSigner(webApiKey: webApiKey, privateKey: signingKey)
        } else {
            _requestSigner = nil
        }
        super.init()
    }
    
    public convenience init( configuration: WebServicesClientConfiguration )
    {
        self.init( path: configuration.endPoint, apiKey: configuration.apiKey, language: configuration.language, requestSigningKey: configuration.requestSigningKey )
    }
    
    //MARK: -
    func createParametersWithObject<T:Mappable>( _ object:T? ) -> [String:AnyObject]?
    {
        if let requestObject = object {
            return Mapper<T>().toJSON(requestObject)
        } else {
            return nil
        }
    }
    
    public func uploadData<P:Mappable>(_ data:Data,method:Method,callback:@escaping (_ result:ApiCallResult<P>) -> Void)
    {
        let request = self.createRequest(method,path: self.path, parameters:nil)
        DataLoader().loadData(RequestType.dataUpload(request as URLRequest, data), queue: self.queue) { (response, error) in
            let result = self.dataResultFromResponse(response, error: error) as ApiCallResult<P>
            callback(result)
        }
    }

    public func downloadDataWithMethod( _ method: Method, parameters:[String:AnyObject]?, callback:@escaping (_ result:ApiCallResult<Data>) -> Void)
    {
        // Use GET to make Alamofire happy ...
        let request        = self.createRequest(.GET, path: self.path, parameters:parameters)
        
        // ... then use targed method to make Netbanking API happy.
        if ( method != .GET ) {
            request.httpMethod = method.rawValue
        }
        
        DataLoader().loadData(RequestType.dataDownload(request as URLRequest), queue: self.queue) { (response, error) in
            let result = self.dataResultFromResponse(response, error: error) as ApiCallResult<Data>
            callback(result)
        }
    }
    
    public func downloadFileWithMethod( _ method: Method, parameters:[String:AnyObject]?, callback:@escaping (_ result:ApiCallResult<String>) -> Void)
    {
        // Use GET to make Alamofire happy ...
        let request        = self.createRequest(.GET, path: self.path, parameters:parameters)
        
        // ... then use targed method to make Netbanking API happy.
        if ( method != .GET ) {
            request.httpMethod = method.rawValue
        }
        
        DataLoader().loadData(RequestType.fileDownload(request as URLRequest), queue: self.queue) { (response, error) in
            let result = self.filePathFromResponse(response, error: error) as ApiCallResult<String>
            callback(result)
        }
    }
    
    public func callApi<T:Mappable,P:Mappable>(_ payload:T?, method:Method,callback:@escaping (_ result:ApiCallResult<P>) -> Void)
    {
        let parameters = ( self.createParametersWithObject(payload) ?? nil )
        self.callApi(parameters, method: method, callback: callback)
    }
    
    public func callApi<P:Mappable>(_ parameters:[String:AnyObject]?, method:Method,callback:@escaping (_ result:ApiCallResult<P>) -> Void)
    {
        let request = self.createRequest(method,path: self.path, parameters:parameters)
        DataLoader().loadData(RequestType.jsonPayload(request as URLRequest), queue: self.queue) { (response, error) in
            
            let result = self.dataResultFromResponse(response, error: error) as ApiCallResult<P>
            callback(result)
        }
    }
    
    public func post<T:Mappable,P:Mappable>(_ object:T?, callback: @escaping (_ result:ApiCallResult<P>) -> Void)
    {
        self.callApi(object, method: Method.POST,callback:callback)
    }
    
    public func delete<T:Mappable,P:Mappable>(_ object:T?, callback: @escaping (_ result:ApiCallResult<P>) -> Void)
    {
        self.callApi(object, method: Method.DELETE,callback:callback)
    }
    
    func createRequest(_ method: Method, path : String, parameters: [String:AnyObject]?) -> NSMutableURLRequest
    {
        let escapedAddress = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = Foundation.URL(string: escapedAddress!)
        let urlRequest = WepApiConvertibleRequest(url: url!)
        
        var encoding = ParameterEncoding.json
        
        
        //Send parameters as query string if it is GET
        if ( method == Method.GET || headers[WebServiceClient.ContentTypeHeaderName] ==  WebServiceClient.ContentTypeFormUrlEncodedHeaderValue ) {
            encoding = ParameterEncoding.url
        }
        
        for ( headerName, headerValue ) in self.headers {
            urlRequest.URLRequest.setValue( headerValue, forHTTPHeaderField: headerName )
        }
        
        urlRequest.URLRequest.httpMethod = method.rawValue
        let request = encoding.encode(urlRequest, parameters: parameters).0
        if let signer = self.requestSigner{
            signer.signRequest(request)
        }
        return request
    }
    
    fileprivate func dataResultFromResponse<P:Mappable>(_ response: ApiCallResponse, error: NSError?) -> ApiCallResult<P>
    {
        if let err = error {
            return ApiCallResult<P>.failure(err, response)
        } else {
            var processedData = response.data
            if let dt = self.dataTransform{
                processedData = dt(processedData)
            }
            
            if let parsedObject = Mapper<P>().map(processedData) {
                return ApiCallResult<P>.success(parsedObject, response)
            }
            
            return ApiCallResult<P>.failure(CoreSDKError(kind:.noPagesError), response)
        }
    }

    
    fileprivate func dataResultFromResponse(_ response: ApiCallResponse, error: NSError?) -> ApiCallResult<Data>
    {
        if let err = error {
            return ApiCallResult<Data>.failure(err, response)
        }
        else {
            var processedData = response.data
            if let dt = self.dataTransform{
                processedData = dt(processedData)
            }
            
            return ApiCallResult<Data>.success(processedData as! Data, response)
        }
    }
    
    fileprivate func filePathFromResponse(_ response: ApiCallResponse, error: NSError?) -> ApiCallResult<String>
    {
        if let err = error {
            return ApiCallResult<String>.failure(err, response)
        }
        else {
            var processedData = response.data
            if let dt = self.dataTransform {
                processedData = dt(processedData)
            }
            
            let filePath = String(data: processedData as! Data, encoding: String.Encoding.utf8)
            return ApiCallResult<String>.success(filePath!, response)
        }
    }
    
}
