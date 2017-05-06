//
//  WebServiceUtilsTests.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 29.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import XCTest
@testable import CoreSDK

//==============================================================================
class WebServiceUtilsTests: XCTestCase {
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGenerateSessionKey()
    {
        let(strKey1, dataKey1) = WebServiceUtils.generateSessionKey()

        // check key length
        XCTAssertEqual(strKey1.characters.count, 32)
        
        // string and data must be the same
        let dataKey1ToString = NSString(data:dataKey1, encoding:NSASCIIStringEncoding) as String?
        XCTAssertEqual(strKey1, dataKey1ToString)
        
        // next key must be different
        let(strKey2, dataKey2) = WebServiceUtils.generateSessionKey()
        XCTAssertNotEqual(strKey1, strKey2)
        XCTAssertNotEqual(dataKey1, dataKey2)
    }
    
    func testEncryptSessionKey()
    {
        let keyToEncrypt = "01234567890123456789012345678901"
        let publicRSAKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDSLxqb9MbdbBkz0BTlvwFFcq6A" +
        "6YRzzW4jFoBr/j7fIH4EAYCf1f8qKjlenZAbP3zaszxySBfgZ1++7Iil7aY5ZCXP" +
        "Trhj/LEZr3/gFWS+qAQIOyLYnLWpbsg6/mFE29lygTTGndmQdQ4NgYOmsM2qamgw" +
        "zfObbQ97jQJABfI/1QIDAQAB"
        
        // private key
        _ = "MIICXAIBAAKBgQDSLxqb9MbdbBkz0BTlvwFFcq6A6YRzzW4jFoBr/j7fIH4EAYCf" +
        "1f8qKjlenZAbP3zaszxySBfgZ1++7Iil7aY5ZCXPTrhj/LEZr3/gFWS+qAQIOyLY" +
        "nLWpbsg6/mFE29lygTTGndmQdQ4NgYOmsM2qamgwzfObbQ97jQJABfI/1QIDAQAB" +
        "AoGBAIrhZQu36c9VJjH+RFCqrQReir/TjRmXnDbDH4g8Lv7wUVQESiFTHY+W5uGF" +
        "6zqV8MHxvPcme+BjbfiSApjhNvtx7GoxcaLEfY+rOL0j2BXy+s3D3eYtpK3/05eZ" +
        "7Zt92Zjwp0WcAmdg8sw3Ih6reBxrVNbPyzwj63ZUJ7lucnMBAkEA90jV0H7jQz0Z" +
        "IrcWB/1naRc/IjvtEiofMK9vKyEm1VA0w89mPViuY0tnraC5JS65X/tH2cweoml4" +
        "JdmgcEAL6QJBANmXhfey+Z4prexo1BlKbxBJ/ylixRISThsXGNVxRUI83oZMOgCj" +
        "q83JYVXPyXmDv5k+mM+hq7Y4U4U/t4auXQ0CQBWWJRwbR4mCFuSh6OlvpIxW/Crn" +
        "4k0YojpkxiaUsUgjxUdmnn0ydZ6zYWyVwDPPvVz0mZQYrn/tBxD+y3OhE6kCQG99" +
        "gBtHDTfJS2CS5fp/dSD3iVJ/VVLJJlQjJYpYG5Cw96QAcsfZFTLAOKtraGRm6Ulw" +
        "FYRt5jnb6o+f8j2EIhECQHw05ZB14l3eqnEbqFh4XmEjyeigYzSvL7uUYrSq9JKS" +
        "1EJMnGtFzej1sbDZdcGYsKQsO9a4ewyD1xJEpRRAKZw="
        
        // result value, tested
        "CdQsL4nwT2t2uyBiq9+uIVUbwVmEszyHHcN0jzuwCu0id3j7QQdDYwR7uaZMGAQR5ApSv1e0kn/1OMgN8ByAcd4CzX3wiYYaP+uUVtx2x3O5tdE2YmmJZIdI3c+XKziGZPRmC7PMwYIXAQlOVvrjrL5cz7dSBQl6Bv7ONuqsXNo="
        
        WebServiceUtils.encryptSessionKey(keyToEncrypt.dataUsingEncoding(NSASCIIStringEncoding)!, publicRSAKey: publicRSAKey)
        
        // Note: because there seems to be a problem with RSAUtils' decryption (not needed here), I have tested the encrypted values externally.
    }
    
    func testEncryptDecryptObjectData()
    {
        let key = "01234567890123456789012345678901"
        let status = Status(pageReference: "page", queryLastPage: "qry", result: "result", totalPageNo: 42)

        let encryptedObjectString:String = WebServiceUtils.encryptObjectData(status, key: key)
        let decryptedObject:Status       = WebServiceUtils.decryptObjectData(encryptedObjectString, key: key)!
        
        XCTAssertEqual(decryptedObject.pageReference, status.pageReference)
        XCTAssertEqual(decryptedObject.queryLastPage, status.queryLastPage)
        XCTAssertEqual(decryptedObject.result, status.result)
        XCTAssertEqual(decryptedObject.totalPageNo, status.totalPageNo)
    }
    
    func testEncodeDecodeRequestObject()
    {
        let key     = "01234567890123456789012345678901"
        let status  = Status(pageReference: "page", queryLastPage: "qry", result: "result", totalPageNo: 42)
        let publicRSAKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDSLxqb9MbdbBkz0BTlvwFFcq6A" +
            "6YRzzW4jFoBr/j7fIH4EAYCf1f8qKjlenZAbP3zaszxySBfgZ1++7Iil7aY5ZCXP" +
            "Trhj/LEZr3/gFWS+qAQIOyLYnLWpbsg6/mFE29lygTTGndmQdQ4NgYOmsM2qamgw" +
            "zfObbQ97jQJABfI/1QIDAQAB"
        
        
        let dataRequest:DataRequest = WebServiceUtils.encodeRequestObject(status, key: key.dataUsingEncoding(NSASCIIStringEncoding)!, publicRSAKey: publicRSAKey)
        
        let dataRequest2:DataRequest = WebServiceUtils.encodeRequestObject(status, key: key.dataUsingEncoding(NSASCIIStringEncoding)!, publicRSAKey: publicRSAKey)
        
        // encrypted session keys must differ
        XCTAssertNotEqual(dataRequest.session, dataRequest2.session)
                
        let decryptedObject:Status = WebServiceUtils.decodeResponseObject(DataResponse(data: dataRequest.data!), sek: key)!
        
        XCTAssertEqual(decryptedObject.pageReference, status.pageReference)
        XCTAssertEqual(decryptedObject.queryLastPage, status.queryLastPage)
        XCTAssertEqual(decryptedObject.result, status.result)
        XCTAssertEqual(decryptedObject.totalPageNo, status.totalPageNo)
    }
    
    
}
