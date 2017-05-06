//
//  ApiQuery.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


/**
 Marks Resource or Entity that supports .get Verb.
 */
public protocol GetEnabled
{
    associatedtype TGetResponse:WebApiEntity
    
    /**
     Makes a GET call to WebApi and returns a `TGetResponse` back.
     
     - parameter callback: Callback will be called with `TResponse` entity inside `CoreResult`
     */
    func get(_ callback: @escaping (_ result:CoreResult<TGetResponse>)->Void)
}

/**
 Marks Resource or Entity that supports .get verb with parameters.
 */
public protocol ParametrizedGetEnabled
{
    associatedtype TGetResponse:WebApiEntity
    associatedtype TGetParameters:Parameters
    func get(_ parameters:TGetParameters, callback: (_ result:CoreResult<TGetResponse>)->Void)
}

//MARK: -
/**
 Marks Resource or Entity that returns InstanceResource through .withId call
 */
public protocol HasInstanceResource
{
    associatedtype TInstanceResource:InstanceResource
    
    /**
     Get an instance resource with a given id.
     
     - parameter id: id of the resource instance.
     
     - returns: an InstanceResource that represents resource on URL path `./PathToThisReosurce/id`
     
     - note: This method does not make any calls to the WebApi by itself. Use  other methods, such as `.get()` on the returned `InstanceResource`
     to make the call.
     
     */
    //func withId(_ id : AnyObject) -> TInstanceResource
    func withId(_ id : Any) -> TInstanceResource
}

//MARK: -
/**
 Marks Resource or Entity that supports .update verb
 */
public protocol UpdateEnabled
{
    associatedtype TUpdateRequest:WebApiEntity
    associatedtype TUpdateResponse:WebApiEntity
    func update(_ request : TUpdateRequest, callback: @escaping (_ result:CoreResult<TUpdateResponse>)->Void)
}

/**
 Marks Resource or Entity that supports .update Verb without any parameters
 */
public protocol EmptyUpdateEnabled
{
    associatedtype TUpdateResponse:WebApiEntity
    func update(_ callback: (_ result:CoreResult<TUpdateResponse>)->Void)
}

//MARK: -
/**
 Marks Resource or Entity that supports .delete verb
 */
public protocol ParametrizedDeleteEnabled
{
    associatedtype TDeleteRequest:WebApiEntity
    associatedtype TDeletResponse:WebApiEntity
    
    func delete(_ parameters: TDeleteRequest, callback: (_ result:CoreResult<TDeletResponse>)->Void)
}

/**
 Marks Resource or Entity that supports .delete verb without any parameters
 */
public protocol DeleteEnabled
{
    associatedtype TDeleteResponse:WebApiEntity
    func delete(_ callback: @escaping (_ result:CoreResult<TDeleteResponse>)->Void)
}

//MARK: -
/**
 Marks Resource or Entity that supports .create verb
 */
public protocol CreateEnabled
{
    associatedtype TCreateRequest: WebApiEntity
    associatedtype TCreateResponse: WebApiEntity
    
    /**
     Makes a POST call to WebApi and returns a `TResponse` returned from server.
     - parameter request:  Entity that will be sent to server.
     - parameter callback: This callback will contain CoreResult with a `TResponse`.
     */
    func create(_ request: TCreateRequest, callback: @escaping (_ result:CoreResult<TCreateResponse>)->Void)
}

/**
 Marks Resource or Entity that supports .create verb without any parameters
 */
public protocol EmptyCreateEnabled
{
    associatedtype TCreateResponse:WebApiEntity
    
    /**
     Makes a POST call to WebApi and returns a `TResponse` returned from server.
     
     - parameter callback: This callback will contain CoreResult with a `TResponse`.
     */
    func create(_ callback: (_ result:CoreResult<TCreateResponse>)->Void)
}

//MARK: -
/**
 Marks Resource or Entity that supports .list verb
 */
public protocol ListOfPrimitivesEnabled
{
    associatedtype TListItem
    
    /**
     Makes a GET call to WebApi and returns a `CallbackWebApi<T>` returned from server.
     - param callback the callback of type CallbackWebApi<T>
     */
    func list(_ callback: @escaping (_ result:CoreResult<ListOfPrimitivesResponse<TListItem>>)->Void)
}

/**
 Marks Resource or Entity that supports .list verb
 */
public protocol ListEnabled
{
    associatedtype TListItem:WebApiEntity
    
    /**
     Calls WebApi and returns list of items in the callback.
     
     - parameter callback: This callback will contain CoreResult with a `ListResponse`.
     */
    func list(_ callback: @escaping (_ result:CoreResult<ListResponse<TListItem>>)->Void)
}

/**
 Marks Resource or Entity that supports .list verb with parameters
 */
public protocol ParametrizedListEnabled
{
    /**
     Parameters Type.
     */
    associatedtype TListParameters:Parameters
    
    /**
     Type of the item in list
     */
    associatedtype TListItem:WebApiEntity
    
    /**
     Calls WebApi and returns list of items in the callback according to the given pagination parameters.
     
     
     - parameter parameters: Parameters for the listing call
     - parameter callback: This callback will contain `CoreResult` with `ListResponse`.
     
     - seealso: [WebApi Basic Mechanisms](https://developers.csas.cz/html/devs/transparent-accounts.html#/reference/basic-mechanisms)
     */
    func list(_ parameters:TListParameters, callback: @escaping (_ result:CoreResult<ListResponse<TListItem>>)->Void)
}

/**
 Marks Resource or Entity that supports .list verb with paginated list result.
 */
public protocol PaginatedListEnabled
{
    /**
     Type of the item in list
     */
    associatedtype TListItem : WebApiEntity
    
    /**
     Parameters Type conforming to Paginated protocol.
     */
    associatedtype TListParameters:Paginated
    
    /**
     Calls WebApi and returns paginated list of items in the callback according to the given pagination parameters.
     
     There is no default limit on how much items get returned. If pagination is `nil`, all records are returned in one large list. However, some calls might introduce a size limit due the fact that a certain backend would be overloaded by returning too many items in one call - in such a case, the individual call descriptions will state that clearly.
     
     - parameter parameters: Parameters for the listing that include the intended pagination.
     - parameter callback: This callback will contain `CoreResult` with a `PaginatedListResponse` obeject.
     
     - seealso: [WebApi Basic Mechanisms](https://developers.csas.cz/html/devs/transparent-accounts.html#/reference/basic-mechanisms)
     */
    func list(_ parameters:TListParameters, callback: @escaping (_ result:CoreResult<PaginatedListResponse<TListItem>>)->Void)
}

/**
 Marks Resource or Entity that supports .list verb with paginated list result.
 */
public protocol OptionalPaginatedListEnabled
{
    /**
     Type of the item in list
     */
    associatedtype TListItem : WebApiEntity
    
    /**
     Parameters Type conforming to Paginated protocol.
     */
    associatedtype TListParameters:Paginated
    
    /**
     Calls WebApi and returns paginated list of items in the callback according to the given optional pagination parameters.
     
     There is no default limit on how much items get returned. If pagination is `nil`, all records are returned in one large list. However, some calls might introduce a size limit due the fact that a certain backend would be overloaded by returning too many items in one call - in such a case, the individual call descriptions will state that clearly.
     
     - parameter parameters: Optional parameters for the listing that include the intended pagination.
     - parameter callback: This callback will contain `CoreResult` with a `PaginatedListResponse` obeject.
     
     - seealso: [WebApi Basic Mechanisms](https://developers.csas.cz/html/devs/transparent-accounts.html#/reference/basic-mechanisms)
     */
    func list(_ parameters:TListParameters?, callback: @escaping (_ result:CoreResult<PaginatedListResponse<TListItem>>)->Void)
}



/**
 Marks Resource or Entity that has its own url where it can be accessed
 */
public protocol HasUrl{
    
    /**
     Returns url of given Resource/Rntity as string
    */
    func url() -> String
}

/**
 Marks Resource Or Entity that has its own parametrized url where it can be accessed
 */
public protocol HasParametrizedUrl{
    associatedtype TUrlParameters : Parameters
    
    /**
     Returns url of given Resource/Entity as string
     */
    func url(_ parameters:TUrlParameters) -> String
}
