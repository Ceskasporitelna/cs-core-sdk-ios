//
//  Users.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK

class UsersResource : Resource, HasInstanceResource, PaginatedListEnabled, CreateEnabled
{
    func list(_ parameters: UserListParameters, callback: @escaping (_ result: CoreResult<PaginatedListResponse<User>>) -> Void)
    {
        ResourceUtils.CallPaginatedList(self,itemJSONKey:"users", parameters: parameters.toDictionary(nil), transform: nil, callback: callback);
    }
    
    func withId(_ id: Any) -> UserDetailResource
    {
        return UserDetailResource(id: id, path: self.path, client: self.client);
    }
    
    func create(_ request: CreateUserRequest, callback: @escaping (_ result: CoreResult<UserDetail>) -> Void)
    {
        //Example of transform
        let transform = WebApiTransform<UserDetail>({(t)in
            switch(t){
            case .success:
                break;
            case .failure(let (_, response)):
                if let urlResponse = response.response{
                    //Map to custom error when status code is 400..599
                    if urlResponse.statusCode >= 400 && urlResponse.statusCode < 599{
                        //Check whether we have a valid json dictionary
                        if let errorDictionary = response.data as? [String : AnyObject]{
                            let error = CustomWebApiError(statusCode: urlResponse.statusCode, dict: errorDictionary)
                            return CoreResult.failure(error);
                        }
                    }
                }
                break;
            }
            return t.toCoreResult();
        });
        
        ResourceUtils.CallCreate(self, payload: request, transform: transform, callback: callback);
    }
    
    //Resources can be nested inside other resources
    var queue : UsersQueueResource
    {
        return UsersQueueResource(path: self.pathAppendedWith("queue"), client: self.client)
    }
    
}

//----------------------------------------------------------------------
class UsersQueueResource : Resource, ListEnabled
{
    func list(_ callback: @escaping (_ result: CoreResult<ListResponse<User>>) -> Void)
    {
        ResourceUtils.CallList(self, itemJSONKey: "users", pathSuffix: nil, parameters: nil, transform: nil, callback: callback)
    }
}

//----------------------------------------------------------------------
class UserDetailResource : InstanceResource, GetEnabled, UpdateEnabled, HasParametrizedUrl
{
    
    func get(_ callback: @escaping (_ result: CoreResult<UserDetail>) -> Void) {
        //Example of transform
        let transform = WebApiTransform<UserDetail>({(t)in
            switch(t){
            case .success(let (data, _)):
                //Reject Dog as not user-like enough entity
                if(data.name == "Dog"){
                    let error = CustomWebApiError(statusCode: 400, dict: [
                        CustomWebApiError.errorCodeKey : "THIS_IS_NOT_HUMAN" as AnyObject,
                        CustomWebApiError.errorMessageKey : "Sadly, this is not human" as AnyObject
                        ]);
                    return CoreResult.failure(error)
                }
                break;
            case .failure:

                break;
            }
            return t.toCoreResult();
        });
        ResourceUtils.CallGet(self, parameters: nil, transform: transform, callback: callback)
    }
    
    func update(_ request: UpdateUserRequest, callback: @escaping (_ result: CoreResult<UserDetail>) -> Void) {
        request.userId = self.id
        ResourceUtils.CallUpdate(self, payload: request, transform: nil, callback: callback);
    }
    
    func url(_ parameters : UserDetailUrlParameters)->String{
        return UrlUtils.urlWithParameters(self.path, parameters: parameters.toDictionary(nil))
    }
}

public class UserDetailUrlParameters : Parameters{
    var format : String
    var pageSize : Int
    
    public init(format : String, pageSize : Int){
        self.format = format
        self.pageSize = pageSize
    }
    
    public override func toDictionary(_ existingParams: [String : AnyObject]?) -> [String : AnyObject] {
        return ["format" : format as AnyObject, "pageSize" : pageSize as AnyObject]
    }
    
}

//----------------------------------------------------------------------
public class UserListParameters : Parameters, Paginated, Sortable
{
    public var pagination : Pagination?;
    public var sortBy: Sort<UserSortableField>?
    
    public init(pagination:Pagination?, sortBy : Sort<UserSortableField>? ){
        self.pagination = pagination;
        self.sortBy = sortBy;
        super.init();
    }
    
    public override func toDictionary(_ existingParams: [String : AnyObject]?) -> [String : AnyObject] {
        var params = super.toDictionary(existingParams)
        if let sortBy = sortBy{
            params = sortBy.addSortParams(params)
        }
        return params
    }
}

public enum UserSortableField : HasFieldName{
    case name
    case userId
    
    public var fieldName: String{
        if self == .name{
            return "name"
        }else{
            return "userId"
        }
    }
}

//----------------------------------------------------------------------
public class CreateUserRequest : WebApiEntity
{
    var name : String?;
    var position : String?;
    var fullProfileUrl : String?;
    
    public override init(){
        super.init();
    }
    
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    public override func mapping(_ map: Map)
    {
        name           <- map["name"]
        position       <- map["position"]
        fullProfileUrl <- map["full_profile_url"]
    }
    
}

//----------------------------------------------------------------------
public class UpdateUserRequest : CreateUserRequest
{
    //No need to make it public. This Id will be set in the InstanceResource
    internal var userId : Any?
    
    public override init(){
        super.init();
    }
    
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    public override func mapping(_ map: Map)
    {
        self.userId <- map["userId"]
        super.mapping(map);
    }
}

//----------------------------------------------------------------------
public class User : WebApiEntity, GetEnabled
{
    internal(set) var userId: Int!
    internal(set) var name : String!
    var id : Int! {
        return userId;
    }
    
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    public override func mapping(_ map: Map)
    {
        userId    <- map["userId"]
        name      <- map["name"]
    }
    
    public func get(_ callback: @escaping (_ result: CoreResult<UserDetail>) -> Void) {
        let userDetailResource = self.resource as! UsersResource
        userDetailResource.withId(self.id as AnyObject).get(callback);
    }
}

//----------------------------------------------------------------------
public class UserDetail : WebApiEntity
{
    internal(set) var userId: Int!
    internal(set) var name : String!
    internal(set) var position : String!
    internal(set) var fullProfileUrl : String!
    
    var id : Int! {
        return userId;
    }
    
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    public override func mapping(_ map: Map)
    {
        userId         <- map["userId"]
        name           <- map["name"]
        position       <- map["position"]
        fullProfileUrl <- map["full_profile_url"]
    }
}
