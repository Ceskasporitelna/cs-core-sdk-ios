//
//  CoreSDKTests.swift
//  CoreSDKTests
//
//  Created by Vladimír Nevyhoštěný on 24.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class CoreSDKTests: XCTestCase
{

    
    //--------------------------------------------------------------------------
    override func setUp()
    {
        super.setUp()
            CoreSDK.sharedInstance
                .useWebApiKey( "TEST_API_KEY" )
                .useEnvironment(
                    Environment(
                        apiContextBaseUrl: "\(Judge.BaseURL)/webapi",
                        oAuth2ContextBaseUrl:"http://csas-judge.herokuapp.com/widp/oauth2"))
                .useLocker(
                    clientId: "TestClientID",
                    clientSecret: "TestClientSecret",
                    publicKey: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhmgBlAsGkJpbFOuNC7gRbSwmffpf83hC0zTSGE08Mq1xR6cjylZ9tUBV6nS4YlKhsgjr+WuAyKMruPf4b3uyjkZabY7EB1DXV9wzm07+f38PO7jU5Ceo0Rv0LAX/BnKV3uMkXBlQSXPkXMda354qmu7DUD8JjbJTjcpBTRhdy5r0guTC+pjKfdPZM2eDqN3fClaHtLsn4YTI64g1hV18siJxelyXT8EeQGVOfs4ojloieRxqGlrJDQORakHW+4WECG4eWkd8r6VPWl6Ycnvx3Fh0apOZiE1MrqD6ztnxaC74pdAXrhImrIuidccMWKEIorcxJ0dNm5KqZUi66v3ZPwIDAQAB",
                    redirectUrlPath: "csastest://auth-completed",
                    scope: "/v1/netbanking")
        
    }
    
    //--------------------------------------------------------------------------
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //--------------------------------------------------------------------------
    func testStringEncryptAndDecrypt()
    {
        let originalText = "Lorem ipsum dolor.";
        //32 bytes == 256 bits
        let password     = "01234567890123456789012345678901";//NSUUID().UUIDString;
        
        // Test non-empty test and password ...
        
        var encrypted = encryptStringAES( originalText, password: password.data(using: String.Encoding.ascii)!, useIV: false );
        switch ( encrypted ) {
        case .success( let encryptedData ):
            let decrypted = decryptStringAES( encryptedData, password: password.data(using: String.Encoding.ascii)!, useIV: false );
            switch ( decrypted ) {
            case .success( let decryptedString ):
                XCTAssertTrue( decryptedString == originalText, "Original and decrypted text not matching!" );
            case .failure( let error ):
                XCTAssertTrue(false, "Decryption failed with error:\(error.localizedDescription)")
            }
        case .failure:
            XCTAssertTrue(false, "Encryption failed.")
        }
        
        // Test empty text, non-empty password ...
        
        encrypted = encryptStringAES( "", password: password.data(using: String.Encoding.ascii)!, useIV: false );
        switch ( encrypted ) {
        case .success( let encryptedData ):
            let decrypted = decryptStringAES( encryptedData, password: password.data(using: String.Encoding.ascii)!, useIV: false );
            switch ( decrypted ) {
            case .success( let decryptedString ):
                XCTAssertTrue( decryptedString == "", "Original and decrypted text not matching!" );
            case .failure( let error ):
                XCTAssertTrue(false, "Decryption failed with error:\(error.localizedDescription)");
            }
        case .failure: break;
            // OK here.
        }
    }
    
    //--------------------------------------------------------------------------
    func testSerializationAndEncryption()
    {
        var keychainDTO                = KeychainDkDTO();
        
        keychainDTO.clientId           = "client ID";
        keychainDTO.deviceFingerprint  = "device fingerprint";
        keychainDTO.oneTimePasswordKey = "one time password";
        
        let dictionary = keychainDTO.toJSON();
        let rawData    = NSKeyedArchiver.archivedData(withRootObject: dictionary);
        
        var encryptedData: Data?
        let password   = "passw0rd";
        
        let encrypted = encryptDataAES(rawData, password: password.sha1().data(using: String.Encoding.ascii)!, useIV: false );
        switch ( encrypted ) {
        case .success( let data ):
            encryptedData = data;
        case .failure( let error ):
            XCTAssertTrue( false, "Data encrypting failed with error:\(error)." );
        }
        
        var decryptedData: Data?
        
        let decrypted  = decryptDataAES(encryptedData, password: password.sha1().data(using: String.Encoding.ascii)!, useIV: false );
        switch ( decrypted ) {
        case .success( let data ):
            decryptedData = data;
        case .failure( let error ):
            XCTAssertTrue( false, "Data decrypting failed with error:\(error)." );
        }
        
        if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: decryptedData!) as? [String : AnyObject] {
            if let dto: KeychainDkDTO = ApiDTO.fromJSON( dictionary ) {
                keychainDTO = dto;
            }
            else {
                XCTAssertTrue( false, "DTO creating failed." );
            }
        }
        else {
            XCTAssertTrue( false, "Data unarchiving failed." );
        }
        
    }

    //--------------------------------------------------------------------------
    func testSimpleEncryption()
    {
        let rawString       = "012345678901234567890123456789010123456789012345678901234567";
        let rawData         = rawString.data(using: String.Encoding.utf8)!
        let password        = "01234567890123456789012345678901";
        let encoded         = encryptDataAES(rawData, password: password.data(using: String.Encoding.ascii)!, useIV: false );
        switch ( encoded ) {
        case .success( let encodedData ):
            print( "Encoded data: \(rawString), with password: \(password) as base64 string: \(encodedData.base64EncodedString())" );
        case .failure:
            break;
        }
    }
    
    
}
