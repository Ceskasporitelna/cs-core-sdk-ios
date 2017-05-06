//
//  Posts.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK

class PostsResource : Resource, ListEnabled, CreateEnabled, HasInstanceResource{
    func list(_ callback: @escaping (_ result: CoreResult<ListResponse<Post>>) -> Void) {
        
        //Example of transform
        let transform = WebApiTransform<ListResponse<Post>>({(t)in
            switch(t){
            case .success:
                break;
            case .failure(let (_, response)):
                if let urlResponse = response.response{
                    if urlResponse.statusCode == 404 {
                        //When 404 (Not found) status code is encountered, return empty list
                        return CoreResult.success(ListResponse<Post>(items: []));
                    }
                }
                break;
            }
            return t.toCoreResult();
        });
        
        ResourceUtils.CallList(self, parameters: nil, transform: transform, callback: callback);
    }
    
    func withId(_ id: Any) -> PostResource {
        return PostResource(id: id, path: self.path, client: self.client);
    }
    
    func create(_ request: CreatePostRequest, callback: @escaping (_ result: CoreResult<Post>) -> Void) {
        ResourceUtils.CallCreate(self, payload: request, transform: nil, callback: callback)
    }
    
}


class PostResource : InstanceResource, GetEnabled, DeleteEnabled{
    func get(_ callback: @escaping (_ result: CoreResult<Post>) -> Void) {
        ResourceUtils.CallGet(self, parameters: nil, transform: nil, callback: callback);
    }
    
    func delete(_ callback: @escaping (_ result: CoreResult<EmptyResponse>) -> Void) {
        //The compiler needs to know what was the intended type of Payload.
        ResourceUtils.CallDelete(self, parameters: nil, transform: nil, callback: callback);
    }
    
}


//----------------------------------------------------------------------
public class CreatePostRequest : WebApiEntity
{
    public var userId: Int?
    public var id: Int?
    public var title: String?
    public var body: String?
    
    public override init(){
        super.init();
    }
    
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    public override func mapping(_ map: Map)
    {
        userId    <- map["userId"]
        id        <- map["id"]
        title     <- map["title"]
        body      <- map["body"]
    }
    
}


//All response objects must inherit from WebApiEntity
//==============================================================================
public class Post : WebApiEntity, Signable
{
    //Use internal(set) for response objects so developers consuming the response from outside of the SDK cannot modify it.
    public internal(set) var userId: Int!
    public internal(set) var id: Int!
    public internal(set) var title: String!
    public internal(set) var body: String!
    
    public var signing: SigningObject?;
    public var signUrl: String{
        return self.resource.path
    }
    
    
    
    //----------------------------------------------------------------------
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    //----------------------------------------------------------------------
    public override func mapping(_ map: Map)
    {
        userId    <- map["userId"]
        id        <- map["id"]
        title     <- map["title"]
        body      <- map["body"]
    }
    
}
