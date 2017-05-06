//
//  Files.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 29/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK


public class FilesResource : Resource, CreateEnabled{
    public func create(_ request: FileCreateRequest, callback: @escaping (_ result: CoreResult<UploadedFile>) -> Void) {
        ResourceUtils.CallUpload(self, method: Method.POST, data: request.fileData, headers: ["content-disposition":"attachment; filename=\"\(request.fileName!)\""], transform: nil, callback: callback)
    }
    
    public func upload(_ request: FileCreateRequest, callback: @escaping (_ result: CoreResult<UploadedFile>) -> Void) {
        self.create(request, callback: callback);
    }
    
}

public class FileCreateRequest : WebApiEntity{
    var fileData : Data!
    var fileName : String!
    
    public init(fileName : String!,data : Data) {
        super.init()
        self.fileData = data;
        self.fileName = fileName;
    }
    
    required public init?(_ map: Map) {
        super.init(map);
    }
}

public class UploadedFile : WebApiEntity{
    //Use internal(set) for response objects so developers consuming the response from outside of the SDK cannot modify it.
    internal(set) var id: String!
    internal(set) var fileName: String!
    internal(set) var size: Int!
    internal(set) var contentType : String!
    internal(set) var status : String!
    
    var isOk : Bool{
        return status == "OK"
    }
    
    
    //----------------------------------------------------------------------
    public required init?(_ map: Map)
    {
        super.init(map);
    }
    
    //----------------------------------------------------------------------
    public override func mapping(_ map: Map)
    {
        fileName      <- map["file_name"]
        id            <- map["id"]
        size          <- map["size"]
        contentType   <- map["content_type"]
        status        <- map["status"]
    }
    
}
