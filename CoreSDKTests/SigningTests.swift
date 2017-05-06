//
//  SigningTests.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation
import XCTest
import CSCoreSDK


//==============================================================================
class SigningTests: XCTestCase
{
    var client : TestApiClient!
    var judgeSession : JudgeSession!
    
    override func setUp() {
        super.setUp()
        let config = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: Judge.BaseURL, oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        self.judgeSession = Judge.startNewSession()
        client = TestApiClient(config: config)
    }
    
    fileprivate func constructPostRequest() -> CreatePostRequest{
        let postRequest = CreatePostRequest()
        postRequest.userId = 1
        postRequest.id = 1
        postRequest.title = "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"
        postRequest.body = "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
        return postRequest
    }
    
    func testSigningInvalidOTP(){
        self.judgeSession.setNextCase("webapi.posts.create.signable.immutable.OTP.invalid", xcTestCase: self)
        let postRequest = constructPostRequest()
        let expectation = self.expectation(description: "Create post and sign it expectation")
        client.posts.create(postRequest) { (result) in
            
            result.getObject()?.signing?.getInfo({ (result) in
                result.getObject()?.startSigningWithTac({ (result) in
                    result.getObject()?.finishSigning(withOneTimePassword: "12345", callback: { (result) in
                        if let error = result.getError() as? SigningError{
                            XCTAssertEqual(error.kind, SigningErrorKind.otpInvalid)
                            expectation.fulfill()
                        }else{
                            XCTFail("IT should have failed - OTP was wrong")
                        }
                    })
                })
            })
        }
        self.waitForExpectations( timeout: 20.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
    }
    
    
    func testImmutableSigningSuccess(){
        self.judgeSession.setNextCase("webapi.posts.create.signable.immutable", xcTestCase: self)
        let postRequest = constructPostRequest()
        let expectation = self.expectation(description: "Create post and sign it expectation")
        let sameInfoExpectation = self.expectation(description: "Retrieve cached FilledSigningInfo object")
        client.posts.create(postRequest) { (result) in
            switch result{
            case .success(let post):
                guard let signing = post.signing else{
                    XCTFail("Signing object not received")
                    return
                }
                XCTAssertEqual(signing.isOpen,     true)
                XCTAssertEqual(signing.isDone,     false)
                XCTAssertEqual(signing.isCancelled, false)
                XCTAssertEqual(signing.signId,     "1607878324")
                XCTAssertEqual(signing.state, SigningState.Open)
                //XCTAssertNil(signing.signingInfo)
                signing.getInfo({ (infoResult) in
                    switch(infoResult){
                    case .success(let info):
                        //This should return the same object and not call to the server.
                        info.getInfo({ (result) in
                            switch(result){
                            case .success(_):
                                sameInfoExpectation.fulfill()
                            default:
                                break
                            }
                        })
                        
                        //Verify basic properties
                        XCTAssertEqual(info.isOpen,     true)
                        XCTAssertEqual(info.isDone,     false)
                        XCTAssertEqual(info.isCancelled, false)
                        XCTAssertEqual(info.signId,     "1607878324")
                        XCTAssertEqual(info.state, SigningState.Open)
                        XCTAssertEqual(info.authorizationType, AuthorizationType.TAC)
                        //XCTAssertNotNil(signing.signingInfo)
                        XCTAssert(post.signing is FilledSigningObject)
                        
                        //Verify utility functions
                        XCTAssertEqual(info.canBeSignedWith(AuthorizationType.TAC), true)
                        XCTAssertEqual(info.canBeSignedWith(AuthorizationType.MobileCase), false)
                        XCTAssertEqual(info.canBeSignedWith(AuthorizationType.NoAuthorization), false)
                        
                        XCTAssertEqual(info.getPossibleAuthorizationTypes(),[AuthorizationType.TAC])
                        
                        info.startSigningWithTac({ (result) in
                            switch(result){
                            case .success(let signingProcess):
                                XCTAssertFalse(post.signing is FilledSigningObject)
                                signingProcess.finishSigning(withOneTimePassword: "00000000", callback: { (result) in
                                    switch(result){
                                    case .success(let signResult):
                                        XCTAssertEqual(signResult.isOpen,     false)
                                        XCTAssertEqual(signResult.isDone,     true)
                                        XCTAssertEqual(signResult.isCancelled, false)
                                        XCTAssertEqual(signResult.signId,     "1607878324")
                                        //Verify that the signing on the entity is updated aswell
                                        XCTAssertFalse(post.signing is FilledSigningObject)
                                        XCTAssertEqual(post.signing!.isOpen,     false)
                                        XCTAssertEqual(post.signing!.isDone,     true)
                                        XCTAssertEqual(post.signing!.isCancelled, false)
                                        XCTAssertEqual(post.signing!.signId,     "1607878324")
                                        expectation.fulfill()
                                    default: break
                                    }
                                })
                                break
                            default: break
                                
                            }
                        })
                        
                        
                    default:
                        XCTFail("Filled info was not obtained")
                    }
                })
                
            default:
                XCTFail("Error during api call")
            }

        }
        
        
        self.waitForExpectations( timeout: 20.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
    }
    
    
    
    
    
}
