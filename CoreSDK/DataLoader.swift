//
//  DataLoader.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 22.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

public let UnknownHttpStatusCode : Int                 = 1;
public let HttpStatusCodeOK      : Int                 = 200;
public let HttpStatusCodeCreated : Int                 = 201;

public let HttpStatusCodeNoContent : Int               = 204;
public let HttpStatusCodeNotAuthenticated: Int         = 401;
public let HttpStatusCodeNotFound: Int                 = 404;

//==============================================================================
public class DataLoader: NSObject
{
    
    //--------------------------------------------------------------------------
    func loadData(_ request: RequestType,  queue: DispatchQueue?, completion: @escaping ((ApiCallResponse, NSError?) -> Void) )
    {
        self.loadDataInternal( request, queue: queue, remainintAttemptCount: 2, completion: completion );
    }
    
    //------------------------------------------------------------------------------
    func loadDataInternal( _ request: RequestType, queue: DispatchQueue?, remainintAttemptCount: Int, completion: @escaping ((ApiCallResponse, NSError?) -> Void) )
    {
        let loaderQueue             = ( queue ?? DispatchQueue.main )!;
        var alamoRequest : Request? = nil
        var localPath: URL?       = nil
        let requestID               = WebServiceUtils.generateUUID()
        
        switch request {
        case .jsonPayload(let nsRequest):
            alamoRequest = Manager.sharedInstance.request(nsRequest);
            
        case .dataUpload(let nsRequest,let data):
            alamoRequest = Manager.sharedInstance.upload(nsRequest, data: data)
            
        case .dataDownload(let nsRequest):
            clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Download with request: \(nsRequest)" );
            alamoRequest    = Manager.sharedInstance.downloadData(nsRequest)
            
        case .fileDownload(let nsRequest):

            // Download using temp. file ...
             
            let destination: (URL, HTTPURLResponse) -> (URL) = { (temporaryURL, response) in
                
                let manager      = FileManager.default
                let directoryURL = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                localPath        = directoryURL.appendingPathComponent("\(response.suggestedFilename!)")
                
                if ( manager.fileExists(atPath: localPath!.absoluteURL.path)) {
                    do {
                        try manager.removeItem(at: localPath!)
                    }
                    catch let error {
                        clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error \(error) when deleting file at url: \(String(describing: localPath))" );
                    }
                }
                
                return localPath!
            }
            alamoRequest    = Manager.sharedInstance.download(nsRequest, destination: destination)
        }
        
        var requestInfo: String?
        if let url = alamoRequest?.request?.url?.absoluteString {
            requestInfo = "{\(requestID)} \(url)"
        }
        
        if let requestData = alamoRequest?.request?.httpBody {
            clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Request: \((requestInfo != nil ? requestInfo! : ""))\nPayload: \(String(describing: String(data: requestData, encoding: String.Encoding.utf8)))" );
        }
        else {
            clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Request: \((requestInfo != nil ? requestInfo! : ""))" );
        }
        
        alamoRequest!.response(queue: queue) { (req, response, data, error) -> Void in
            
            guard let httpResponse = response else {
                
                // Something went wrong. No response here ...
                
                let coreSDK        = CoreSDK.sharedInstance as! CoreSDK
                let networkStatus  = coreSDK.reachability.currentReachabilityStatus;
                let responseError  = ( error != nil ? CoreSDKError.errorOfKind( .noResponse, underlyingError: error! ) : CoreSDKError( kind: .noResponse ) );
                let responseStatus = ( error != nil ? error!.code : UnknownHttpStatusCode );
                
                clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "No response for: \(String(describing: req?.url!))" );
                clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "HTTP response error: \(responseError), reachability: \(networkStatus)" );
                
                if ( responseStatus < 0 ) {
                    
                    // This is a CFNetworkError ...
                    
                    switch ( networkStatus ) {
                    case .reachableViaWWAN, .reachableViaWiFi:
                        if ( remainintAttemptCount > 0 ) {
                            loaderQueue.asyncAfter( deadline: DispatchTime.now() + Double(Int64( 5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                                self.loadDataInternal( request, queue: queue, remainintAttemptCount: remainintAttemptCount - 1, completion: completion );
                            })
                        }
                        else {
                            loaderQueue.async(execute: {
                                completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), CoreSDKError.errorOfKind( .networkError, underlyingError: error ) );
                            })
                        }
                        
                    case .notReachable:
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), CoreSDKError.errorOfKind( .networkNotAvailable, underlyingError: error ) );
                        })
                    }
                }
                else {
                    loaderQueue.async(execute: {
                        completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), responseError );
                    })
                }
                
                return
            }
            
            GlobalBackgroundQueue.async {
                
                let httpStatus: Int = httpResponse.statusCode
                clog(WebApiClient.ModuleName, activityName: "\(httpStatus)", fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "Response for request: \((requestInfo != nil ? requestInfo! : ""))" );
                
                switch ( request ) {
                case .dataDownload(_):
                    if httpStatus == HttpStatusCodeOK {
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), error)
                        });
                    }
                    else {
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), CoreSDKError.errorWithCode( httpStatus ) );
                        });
                    }
                    
                case .fileDownload(_):
                    if httpStatus == HttpStatusCodeOK {

                        // Download using temp. file ...
                        
                        if let downloadedFileUrl = localPath {
                            let manager      = FileManager.default
                            
                            if ( manager.fileExists(atPath: downloadedFileUrl.absoluteURL.path)) {
                                let filePathData = downloadedFileUrl.absoluteURL.path.data(using: String.Encoding.utf8)
                                loaderQueue.async(execute: {
                                    completion(ApiCallResponse(request: req, response: response, data: filePathData as AnyObject?), error)
                                })
                                return
                            }
                        }
                        
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), CoreSDKError(kind: CoreSDKErrorKind.fileDownloadFailed) )
                        })
                    }
                    else {
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: data as AnyObject?), CoreSDKError.errorWithCode( httpStatus ) )
                        })
                    }
                
                default:
                    let jsonResponseSerializer = Request.JSONResponseSerializer(options: .allowFragments);
                    let result                 = jsonResponseSerializer.serializeResponse(req, httpResponse, data, error);
                    
                    if let responseData = result.value {
                        clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.DataLoading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.debug, format: "\((requestInfo != nil ? requestInfo! : ""))\nResponse data: \(responseData)\n--- END OF RESPONSE DATA ---" );
                    }
                    
                    
                    if httpStatus == HttpStatusCodeOK || httpStatus == HttpStatusCodeCreated {
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: result.value), result.error)
                        })
                    }
                    else {
                        let error = CoreSDKError.errorWithCode( httpStatus )
                        #if DEBUG
                            if let errorInfo = result.value as? [String:AnyObject] {
                                error?.serverErrorInfo = errorInfo
                            }
                        #endif
                        loaderQueue.async(execute: {
                            completion(ApiCallResponse(request: req, response: response, data: result.value), error )
                        })
                    }

                }
                
                // TODO: determine errors that should be caught here and the request repeated, such as auth with refresh tokens
            };
        }
        
    }
    
}
