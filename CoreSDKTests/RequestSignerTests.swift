//
//  RequestSignerTests.swift
//  CoreSDKTestApp
//
//  Created by Vratislav Kalenda on 28.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import XCTest
@testable import CSCoreSDK


class RequestSignerTests: XCTestCase{
    fileprivate var signer : RequestSigner!
    
    override func setUp() {
        self.signer = RequestSigner(webApiKey: "adae3c38-be9a-4529-94d7-3c7a33c1201a", privateKey: Data(base64Encoded: "MDhiNjE4NmQtZjhlMi00ZmMzLTk3YmMtY2NhNmQ4N2FhNDZm")!);
    }
    
    func testSignatureWithDataGeneration()
    {
        let signature = signer.generateSignatureForRequest("/some/nice/path", data: "{\"someNice\":\"data\"}", nonce: "123456")
        XCTAssertEqual("TNjt8aVBNmDn76xTzfDAQaziDvA=", signature)
    }
    
    func testSignatureWithoutDataGeneration(){
        //Use empty string if you want to sign request with empty body
        let sginature = signer.generateSignatureForRequest("/some/nice/path", data: "", nonce: "123456")
        XCTAssertEqual("1Yy8df6/CXueKUdN5xU4HXnjKO0=", sginature)
    }
    
    func testPathExtracting(){
        let stripped = signer.stripServerFromPath("https://www.example.com/some/nice/path")
        XCTAssert(stripped == "/some/nice/path");
        
        let justPath = signer.stripServerFromPath("/some/nice/path")
        XCTAssert(justPath == "/some/nice/path");
    }
    
    func testRequestHeaderSigning(){
        let client = WebServiceClient(path: "https://www.example.com/some/nice/path", apiKey: "adae3c38-be9a-4529-94d7-3c7a33c1201a", language: "cs-CZ", requestSigningKey: Data(base64Encoded: "MDhiNjE4NmQtZjhlMi00ZmMzLTk3YmMtY2NhNmQ4N2FhNDZm")!);
        client.requestSigner!.fixedNonce = "123456";
        let params = client.createParametersWithObject(SignerTestDTO());
        let request = client.createRequest(Method.POST, path: "https://www.example.com/some/nice/path", parameters: params);
        XCTAssertEqual("TNjt8aVBNmDn76xTzfDAQaziDvA=",request.value(forHTTPHeaderField: "signature"));
        XCTAssertEqual("123456",request.value(forHTTPHeaderField: "nonce"));
    }
    
    func testNonceIsDifferentWhenNotFixed(){
        let client = WebServiceClient(path: "https://www.example.com/some/nice/path", apiKey: "adae3c38-be9a-4529-94d7-3c7a33c1201a", language: "cs-CZ", requestSigningKey: Data(base64Encoded: "MDhiNjE4NmQtZjhlMi00ZmMzLTk3YmMtY2NhNmQ4N2FhNDZm")!);
        let params = client.createParametersWithObject(SignerTestDTO());
        let request = client.createRequest(Method.POST, path: "https://www.example.com/some/nice/path", parameters: params);
        XCTAssertNotEqual("TNjt8aVBNmDn76xTzfDAQaziDvA=",request.value(forHTTPHeaderField: "signature"));
        XCTAssertNotEqual("123456",request.value(forHTTPHeaderField: "nonce"));
    }
    
    func testRequestIsNotSignedWhenNoKeyIsSpecified(){
        let client = WebServiceClient(path: "https://www.example.com/some/nice/path", apiKey: "adae3c38-be9a-4529-94d7-3c7a33c1201a", language: "cs-CZ", requestSigningKey: nil);
        let params = client.createParametersWithObject(SignerTestDTO());
        let request = client.createRequest(Method.POST, path: "https://www.example.com/some/nice/path", parameters: params);
        XCTAssertNil(request.value(forHTTPHeaderField: "signature"));
        XCTAssertNil(request.value(forHTTPHeaderField: "nonce"));
    }
    
    
}

class SignerTestDTO : ApiDTO{
    var someNice : String?
    
    override init()
    {
        self.someNice = "data";
        super.init();
    }
    
    //--------------------------------------------------------------------------
    required init?(_ map: Map)
    {
        super.init()
    }
    
    override func mapping(_ map: Map) {
        self.someNice  <- map["someNice"]
    }
}
