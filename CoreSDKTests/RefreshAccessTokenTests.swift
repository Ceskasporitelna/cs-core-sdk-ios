//
//  RefreshAccessTokenTests.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class RefreshAccessTokenTests: LockerTestsBase
{
    var apiClient : TestApiClient!

    //--------------------------------------------------------------------------
    override func setUp()
    {
        super.setUp()
        let config                         = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: Judge.BaseURL, oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        self.apiClient                     = TestApiClient(config: config)
        self.apiClient.accessTokenProvider = self.coreSDK.sharedContext
    }
    
    //--------------------------------------------------------------------------
    override func tearDown()
    {
        super.tearDown()
    }
    
    //--------------------------------------------------------------------------
    func makeAccessTokenNotExpired()
    {
        self.locker.accessTokenExpiration = UInt64((Date().timeIntervalSince1970 + 3600) * 1000)
    }
    
    //--------------------------------------------------------------------------
    func testAccessTokenProviderRefreshSuccesful()
    {
        self.registerUser()
        self.makeAccessTokenNotExpired()
        
        self.judgeSession.setNextCase("accessTokenProvider.refresh.succesful.sanitized", xcTestCase: self)
        
        var expectation = self.expectation( description: "Check Access Token" )
        let parametres  = UserListParameters( pagination: nil, sortBy: nil )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(_):
                XCTFail( "User list call must fail in this test." )
                
            case .failure( let error ):
                XCTAssertEqual( error.code, 403, "Error code should be 403.")
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Refresh Access Token" )
        
        self.apiClient.accessTokenProvider?.refreshAccessToken({ result in
            switch(result){
            case .success(_):
                XCTAssertEqual( self.locker.accessToken, "2d2e3b611d17db36b2ad6ca182134b4a" )
                XCTAssertEqual( (self.locker.accessTokenExpiration! / 1000 - UInt64(NSDate().timeIntervalSince1970)) + 5, 3600 )
                XCTAssertEqual( self.locker.tokenType, "bearer" )
                expectation.fulfill()
                
            case .failure(_):
                XCTFail()
            }
        })
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Use new Access Token" )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(let users):
                XCTAssertTrue( users.items.count == 2, "User count must be 2.")
                XCTAssertEqual( users.items [0].userId, 3 )
                XCTAssertEqual( users.items [0].name, "Captain America " )
                
                XCTAssertEqual( users.items [1].userId, 4 )
                XCTAssertNil( users.items [1].name )
                
                expectation.fulfill()
                
            case .failure(_):
                XCTFail()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
    }
    
    //--------------------------------------------------------------------------
    func testAccessTokenProviderRefreshBadRequest()
    {
        self.registerUser()
        self.makeAccessTokenNotExpired()
        
        self.judgeSession.setNextCase("accessTokenProvider.refresh.badRequest.sanitized", xcTestCase: self)
        
        var expectation = self.expectation( description: "Check Access Token" )
        let parametres  = UserListParameters( pagination: nil, sortBy: nil )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(_):
                XCTFail( "User list call must fail in this test." )
                
            case .failure( let error ):
                XCTAssertEqual( error.code, 403, "Error code should be 403.")
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Get Access Token" )
        
        self.locker.refreshToken       = "TestRefreshToken"
        self.locker.oauth2Code         = "TestCode"
        self.locker.oauth2ClientId     = "TestClientID"
        self.locker.oauth2ClientSecret = "TestClientSecret"
        self.locker.redirectUrlPath    = "csastest://auth-completed"
        
        self.apiClient.accessTokenProvider?.refreshAccessToken { result in
            switch(result){
            case .success(_):
                XCTAssertEqual( self.locker.accessToken, "2d2e3b611d17db36b2ad6ca182134b4a" )
                XCTAssertEqual( (self.locker.accessTokenExpiration! / 1000 - UInt64(NSDate().timeIntervalSince1970)) + 5, 3600 )
                XCTAssertEqual( self.locker.tokenType, "bearer" )
                expectation.fulfill()
                
            case .failure(_):
                XCTFail()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Get User List" )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(_):
                XCTFail( "User list call must fail in this test." )
                
            case .failure( let error ):
                XCTAssertEqual( error.code, 400, "Error code should be 400.")
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
    }
    
    //--------------------------------------------------------------------------
    func testAccessTokenProviderRefreshForbidden()
    {
        self.registerUser()
        self.makeAccessTokenNotExpired()

        self.judgeSession.setNextCase("accessTokenProvider.refresh.forbidden.sanitized", xcTestCase: self)
        
        var expectation = self.expectation( description: "Check Access Token" )
        let parametres  = UserListParameters( pagination: nil, sortBy: nil )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(_):
                XCTFail( "User list call must fail in this test." )
                
            case .failure( let error ):
                XCTAssertEqual( error.code, 403, "Error code should be 403.")
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Get Access Token" )
        
        self.locker.refreshToken       = "TestRefreshToken"
        self.locker.oauth2Code         = "TestCode"
        self.locker.oauth2ClientId     = "TestClientID"
        self.locker.oauth2ClientSecret = "TestClientSecret"
        self.locker.redirectUrlPath    = "csastest://auth-completed"
        
        self.apiClient.accessTokenProvider?.refreshAccessToken { result in
            switch(result){
            case .success(_):
                XCTAssertEqual( self.locker.accessToken, "2d2e3b611d17db36b2ad6ca182134b4a" )
                XCTAssertEqual( (self.locker.accessTokenExpiration! / 1000 - UInt64(NSDate().timeIntervalSince1970)) + 5, 3600 )
                XCTAssertEqual( self.locker.tokenType, "bearer" )
                expectation.fulfill()
                
            case .failure(_):
                XCTFail()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        expectation = self.expectation( description: "Check Access Token" )
        
        self.apiClient.users.list(parametres) { result in
            switch(result){
            case .success(_):
                XCTFail( "User list call must fail in this test." )
                
            case .failure( let error ):
                XCTAssertEqual( error.code, 403, "Error code should be 403.")
                expectation.fulfill()
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
    }

}
