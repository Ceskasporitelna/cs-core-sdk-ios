//
//  TestApiClient.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 15/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK

//==============================================================================
class TestApiClient : WebApiClient
{
    init(config: WebApiConfiguration) {
        super.init(config: config,apiBasePath: "");
    }
    
    //MARK: -
    var posts : PostsResource{
        return PostsResource(path: self.pathAppendedWith("posts"), client: self);
    }
    
    var users : UsersResource{
        return UsersResource(path: self.pathAppendedWith("users"), client: self);
    }
    
    var files : FilesResource{
        return FilesResource(path: self.pathAppendedWith("file"), client: self);
    }
    
    var notes : NotesResource{
        return NotesResource(path: self.pathAppendedWith("notes"), client: self);
    }
    
}

//----------------------------------------------------------------------
public class NotesResource : Resource, ListOfPrimitivesEnabled
{
    public func list(_ callback: @escaping (_ result:CoreResult<ListOfPrimitivesResponse<String>>)->Void)
    {
        ResourceUtils.CallListOfPrimitives(self, pathSuffix:nil, parameters: nil, transform: nil, callback: callback)
    }
    
}







