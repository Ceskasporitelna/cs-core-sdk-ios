//
//  WebApiPathResolutionTests.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 14/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


import Foundation
import XCTest
@testable import CSCoreSDK


private class PathTestClient : WebApiClient{
    init(config: WebApiConfiguration) {
        super.init(config: config,apiBasePath: "/base/path")
    }
    
    
    var resource : PathResource{
        return PathResource(path: self.pathAppendedWith("resource"), client: self)
    }
    
}

private class PathResource : Resource, HasInstanceResource{
    
    var subResource : PathResource{
        return PathResource(path: self.pathAppendedWith("subresource"), client: self.client)
    }
    
    fileprivate func withId(_ id: Any) -> PathInstanceResource {
        return PathInstanceResource(id: id, path: self.path, client: self.client)
    }
    
}

private class PathInstanceResource : InstanceResource{
    
    var subResource : PathResource{
        return PathResource(path: self.pathAppendedWith("subresource"), client: self.client)
    }
}


class WebApiPathResolutionTests: XCTestCase
{
    var config = WebApiConfiguration(webApiKey: "SOME_KEY", environment: Environment.Production, language: "lang", signingKey: nil)
    
    fileprivate var client : PathTestClient!
    
    override func setUp() {
        self.client = PathTestClient(config: config)
    }
    
    
    func testClientPahtResolution(){
        XCTAssertEqual(client.path, "https://www.csas.cz/webapi/base/path")
    }
    
    
    func testResourcePath(){
        XCTAssertEqual(client.resource.path, "https://www.csas.cz/webapi/base/path/resource")
    }
    
    
    func testSubResourcePath(){
        XCTAssertEqual(client.resource.subResource.path, "https://www.csas.cz/webapi/base/path/resource/subresource")
    }
    
    func testInstanceResourcePath(){
        XCTAssertEqual(client.resource.withId("123").path, "https://www.csas.cz/webapi/base/path/resource/123")
    }
    
    func testInstanceSubResourcePath(){
        XCTAssertEqual(client.resource.withId("123").subResource.path, "https://www.csas.cz/webapi/base/path/resource/123/subresource")
    }
    
    func testInstanceSubResourcePathNested(){
        XCTAssertEqual(client.resource.withId("123").subResource.withId("321").path, "https://www.csas.cz/webapi/base/path/resource/123/subresource/321")
    }
    
    
    func testWebApiClientPath(){
        
        let webServiceClient = WebServiceClient(configuration: WebServicesClientConfiguration(endPoint: "", apiKey: ""))
        
        let resource = client.resource.withId("123").subResource.withId("321")
        let req = webServiceClient.createRequest(.GET, path : resource.path, parameters: nil)
         XCTAssertEqual(resource.path, req.url?.absoluteString)
        
        let resource2 = client.resource.withId("123 00").subResource.withId("321")
        let req2 = webServiceClient.createRequest(.GET, path : resource2.path, parameters: nil)
        XCTAssertEqual(req2.url?.absoluteString, "https://www.csas.cz/webapi/base/path/resource/123%2000/subresource/321")
        XCTAssertNotEqual(resource2.path, req2.url?.absoluteString)
    }
    
}
