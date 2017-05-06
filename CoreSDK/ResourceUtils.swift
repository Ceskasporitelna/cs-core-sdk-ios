//
//  ResourceUtils.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 19/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


public class ResourceUtils
{
   static let ItemKey = "_ITEMS_"
    
    fileprivate static func defaultTransform<TResponse:WebApiEntity>(_ result:ApiCallResult<TResponse>) -> ApiCallResult<TResponse>
    {
        switch result {
        case .failure(let (error,response)):
            if error.code == HttpStatusCodeNoContent {
                let emptyData = TResponse(Map(mappingType: MappingType.fromJSON, JSONDictionary: [:]))
                if let empty = emptyData{
                    return ApiCallResult.success(empty,response)
                }
            }
            else if let responseData = response.data {
                if let _ = responseData.count {
                    let coreError             = CoreSDKError.errorWithCode(error.code, underlyingError: error)!
                    if ( responseData is [String:AnyObject] ) {
                        coreError.serverErrorInfo = (responseData as! [String:AnyObject])
                        return ApiCallResult.failure(coreError, response)
                    }
                    else if ( responseData is [AnyObject] ) {
                        coreError.serverErrorInfo = ["root":responseData as! [AnyObject] as AnyObject]
                        return ApiCallResult.failure(coreError, response)
                    }
                    else {
                        if let errorString = String(data: responseData as! Data, encoding: String.Encoding.utf8) {
                            coreError.serverErrorInfo = ["error":errorString as AnyObject]
                            return ApiCallResult.failure(coreError, response)
                        }
                    }
                }
            }
            else if response.request?.httpMethod == Method.DELETE.rawValue {
                let emptyData = TResponse(Map(mappingType: MappingType.fromJSON, JSONDictionary: [:]))
                if let empty = emptyData{
                    return ApiCallResult.success(empty,response)
                }
            }
            
        default: break
        }
        return result
    }
    
    //MARK: -
    public static func CallGet<TResponse:WebApiEntity>(
        _ resource : Resource,
        parameters:[String:AnyObject]?,
        transform: WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            CallGet(resource, pathSuffix: nil, parameters: parameters, transform: transform, callback: callback)
    }
    
    public static func CallGet<TResponse:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.GET, parameters:parameters, headers: nil) { ( originalResult : ApiCallResult<TResponse>) -> Void in
                
                var result = originalResult
                result     = self.defaultTransform(result)
                
                switch result {
                case .success(let (entity, response)):
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                
                if let t = transform{
                    callback((t.transform(result) as! CoreResult<TResponse>))
                } else {
                    callback(result.toCoreResult())
                }
            }
    }
    
    //MARK: -
    public static func CallCreate<TRequest:Mappable,TResponse:WebApiEntity>(
        _ resource : Resource,
        payload:TRequest?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            CallCreate(resource, pathSuffix:nil, payload: payload, transform: transform, callback: callback)
    }
    
    public static func CallCreate<TRequest:Mappable,TResponse:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        payload:TRequest?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.POST, payload:payload, headers: nil) { ( originalResult : ApiCallResult<TResponse>) -> Void in
                var result = originalResult
                result = defaultTransform(result)
                switch result {
                case .success(let (entity, response)):
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                
                if let t = transform{
                    callback((t.transform(result) as! CoreResult<TResponse>))
                } else {
                    callback(result.toCoreResult())
                }
            }
    }
    
    
    public static func CallDownload( method: Method, resource: Resource, pathSuffix: String?, parameters: [String:AnyObject]?, contentType: String?, callback: @escaping (_ result:CoreResult<String>)->Void)
    {
        CallDownload( method: method, resource: resource, customPath: nil, pathSuffix: pathSuffix, parameters: parameters, contentType: contentType, callback: callback )
    }
    
    public static func CallDownload( method: Method, resource: Resource, customPath: String?, pathSuffix: String?, parameters: [String:AnyObject]?, contentType: String?, callback: @escaping (_ result:CoreResult<String>)->Void)
    {
        var headers: [String:String]?
        if let cntType = contentType {
            headers = ["content-type":cntType]
        }
        
        var downloadPath: String!
        if let custPath = customPath {
            let custResource = Resource(path: custPath, client: resource.client )
            downloadPath = custResource.pathAppendedWith(pathSuffix)
        }
        else {
            downloadPath = resource.pathAppendedWith(pathSuffix)
        }
        
        resource.client.callApi( method: method, url: downloadPath, headers: headers, parameters: parameters, dataTransform: nil, callback: { result in
            switch ( result ) {
            case .success(let filePath, _):
                callback(CoreResult.success(filePath))
            case .failure(let error, _):
                callback(CoreResult.failure(error))
            }
        })
    }
    
    //MARK: -
    public static func CallDelete<TResponse:WebApiEntity>(
        _ resource : Resource,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            CallDelete(resource, pathSuffix: nil, parameters: parameters, transform: transform, callback: callback)
    }

    public static func CallDelete<TResponse:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.DELETE, parameters:parameters, headers: nil) { ( originalResult : ApiCallResult<TResponse>) -> Void in
                var result = originalResult
                result = defaultTransform(result)
                switch result {
                case .success(let (entity, response)):
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                
                if let t = transform{
                    callback((t.transform(result) as! CoreResult<TResponse>))
                }else{
                    callback(result.toCoreResult())
                }
            }
    }
    
    //MARK: -
    public static func CallUpdate<TRequest:Mappable,TResponse:WebApiEntity>(
        _ resource : Resource,
        payload:TRequest?,
        transform:  WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            CallUpdate(resource, pathSuffix: nil, payload: payload, transform: transform, callback: callback)
    }
    
    public static func CallUpdate<TRequest:Mappable,TResponse:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        payload:TRequest?,
        transform: WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void){
            resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.PUT, payload:payload, headers: nil) { ( originalResult : ApiCallResult<TResponse>) -> Void in
                var result = originalResult
                result     = defaultTransform(result)
                switch result {
                case .success(let (entity, response)):
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                
                if let t = transform{
                    callback((t.transform(result) as! CoreResult<TResponse>))
                } else{
                    callback(result.toCoreResult())
                }
            }
    }
    
    
    //MARK: -
    public static func CallListOfPrimitives<TItem>(
        _ resource : Resource,
        pathSuffix: String?,
        parameters:[String:AnyObject]?,
        transform: WebApiTransform<ListOfPrimitivesResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<ListOfPrimitivesResponse<TItem>>)->Void){
        
        resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.GET, parameters: parameters, headers: nil,
                                dataTransform:{ (data) in
                                    if let array = data as? [AnyObject] {
                                        let dictionary = [ResourceUtils.ItemKey: array]
                                        return dictionary as AnyObject?
                                    }
                                    return data
            },
                                callback:
            {(callResult : ApiCallResult<ListOfPrimitivesResponse<TItem>>) in
                let transformedResult = defaultTransform(callResult)
                switch transformedResult {
                case .success(let (entity,response)):
                    entity.transform = transform
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    entity.parameters = parameters
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                
                if let t = transform {
                    callback((t.transform(transformedResult) as! CoreResult<ListOfPrimitivesResponse<TItem>>))
                } else {
                    callback(transformedResult.toCoreResult())
                }
        })
    }
    
    public static func CallList<TItem:WebApiEntity>(
        _ resource : Resource,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<ListResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<ListResponse<TItem>>)->Void){
            CallList(resource, pathSuffix: nil, parameters: parameters, transform: transform, callback: callback)
    }
    
    public static func CallList<TItem:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<ListResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<ListResponse<TItem>>)->Void){
            CallList(resource, itemJSONKey: nil, pathSuffix: pathSuffix, parameters: parameters, transform: transform, callback: callback)
    }
    
    public static func CallList<TItem:WebApiEntity>(
        _ resource : Resource,
        itemJSONKey : String?,
        pathSuffix : String?,
        parameters:[String:AnyObject]?,
        transform:  WebApiTransform<ListResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<ListResponse<TItem>>)->Void
        ){
            var itemKey = ResourceUtils.ItemKey
            if itemJSONKey != nil{
                itemKey = itemJSONKey!
            }
            resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.GET, parameters: parameters, headers: nil,
                dataTransform:{ (data) in
                    if let array = data as? [[String : AnyObject]] {
                        let dictionary = [ResourceUtils.ItemKey: array]
                        return dictionary as AnyObject?
                    }else if var dictionary = data as? [String : AnyObject]{
                        dictionary[ResourceUtils.ItemKey] = dictionary[itemKey]
                        return dictionary as AnyObject?
                    }
                    return data
                },
                callback:
                
                {(callResult : ApiCallResult<ListResponse<TItem>>) in
                    let transformedResult = defaultTransform(callResult)
                    switch transformedResult {
                    case .success(let (entity,response)):
                        entity.transform = transform
                        entity.resource = resource
                        entity.pathSuffix = pathSuffix
                        entity.itemKey = itemKey
                        entity.parameters = parameters
                        entity.setResourceAndPathSuffixToItems()
                        injectSigningInfo(entity, apiCallResponse: response)
                    default: break
                    }
                    
                    if let t = transform {
                        callback((t.transform(transformedResult) as! CoreResult<ListResponse<TItem>>))
                    } else {
                        callback(transformedResult.toCoreResult())
                    }
            })
    }
    
  
    public static func CallPaginatedList<TItem:WebApiEntity>(
        _ resource : Resource,
        itemJSONKey  : String,
        parameters:[String:AnyObject]?,
        transform: WebApiTransform<PaginatedListResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<PaginatedListResponse<TItem>>)->Void)
    {
        CallPaginatedList(resource, pathSuffix: nil, itemJSONKey: itemJSONKey, parameters: parameters, transform: transform, callback: callback)
    }
    
    public static func CallPaginatedList<TItem:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        itemJSONKey  : String,
        parameters:[String:AnyObject]?,
        transform: WebApiTransform<PaginatedListResponse<TItem>>?,
        callback:@escaping (_ result:CoreResult<PaginatedListResponse<TItem>>)->Void)
    {
        resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: Method.GET, parameters: parameters, headers: nil,
                                dataTransform:{ (data) in
                                    if var dictionary = data as? [String : AnyObject]{
                                        dictionary[ResourceUtils.ItemKey] = dictionary[itemJSONKey]
                                        return dictionary as AnyObject?
                                    }
                                    return data
            },
                                callback:
            
            {( originalResult : ApiCallResult<PaginatedListResponse<TItem>>) in
                let result = defaultTransform(originalResult)
                switch(result){
                case .success(let (entity, response)):
                    entity.transform = transform
                    entity.resource = resource
                    entity.pathSuffix = pathSuffix
                    entity.itemKey = itemJSONKey
                    entity.parameters = parameters
                    entity.setResourceAndPathSuffixToItems()
                    injectSigningInfo(entity, apiCallResponse: response)
                default: break
                }
                if let t = transform{
                    callback((t.transform(result) as! CoreResult<PaginatedListResponse<TItem>>))
                } else{
                    callback(result.toCoreResult())
                }
        })
    }
    
    //MARK: -
    public static func CallUpload<TResponse:WebApiEntity>(
        _ resource : Resource,
        method : Method,
        data:Data,
        headers : [String:String],
        transform: WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void)
    {
        CallUpload(resource, pathSuffix: nil, method: method, data: data, headers: headers, transform: transform, callback: callback)
    }
    
    public static func CallUpload<TResponse:WebApiEntity>(
        _ resource : Resource,
        pathSuffix : String?,
        method : Method,
        data:Data,
        headers : [String:String],
        transform: WebApiTransform<TResponse>?,
        callback:@escaping (_ result:CoreResult<TResponse>)->Void)
    {
        resource.client.callApi(resource.pathAppendedWith(pathSuffix), method: method, data:data, headers: headers, dataTransform:nil) { ( originalResult : ApiCallResult<TResponse>) -> Void in
            let result = defaultTransform(originalResult)
            switch result {
            case .success(let (entity, response)):
                entity.resource = resource
                entity.pathSuffix = pathSuffix
                injectSigningInfo(entity, apiCallResponse: response)
            default: break
            }
            if let t = transform{
                callback(t.transform(result) as! CoreResult<TResponse>)
            } else{
                callback(result.toCoreResult())
            }
        }
    }
    
    
    fileprivate static func injectSigningInfo<TResponse:WebApiEntity>(_ entity : TResponse, apiCallResponse : ApiCallResponse){
        if(entity is Signable){
            let signableEntity = entity as! Signable
            if let data = apiCallResponse.data{
                SignableResponseInjector().injectSigningObject(data, signableEntity: signableEntity, client: entity.resource.client)
            }
        }

    }
    
}
