//
//  JudgeUtils.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 05.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import XCTest
@testable import CSCoreSDK

class Judge{
    static let JudgeSessionHeaderName       = "x-judge-session";
    static let JudgeCaseHeaderName          = "x-judge-case";
    static let BaseURL          = "http://csas-judge.herokuapp.com";
    static func startNewSession() -> JudgeSession{
        let sessionId = UUID().uuidString;
        WebServiceClient.globalHeaders[Judge.JudgeSessionHeaderName] = sessionId;
        let session = JudgeSession(sessionId: sessionId);
        return session;
    }
}


class JudgeSession{
    let sessionId : String;
    let nextCaseClient : WebServiceClient;
    fileprivate var currentExpectation : XCTestExpectation?;
    init(sessionId : String){
        self.sessionId = sessionId;
        self.nextCaseClient = WebServiceClient( configuration: WebServicesClientConfiguration(
            endPoint: "\(Judge.BaseURL)/judge/nextCase",
            apiKey: nil
        ));
    }
    func setNextCase(_ caseId:String,xcTestCase : XCTestCase){
        self.nextCaseClient.headers [Judge.JudgeCaseHeaderName]    = caseId;
        print("Preparing judge case \(caseId)");
        self.currentExpectation = xcTestCase.expectation(description: "Preparing judge case \(caseId)");
        
        self.nextCaseClient.post(JudgeRequestDTO()){ (result:ApiCallResult<DataResponseDTO>) in
            switch result {
            case .success:
                print("Test case: '\(caseId)' set");
                self.currentExpectation!.fulfill();
            case .failure:
                XCTAssertTrue( false, "Preparing of user registration failed." );
            }
        }
        //There is a longer timeout bacause Heroku dino needs some time to wind-up
        xcTestCase.waitForExpectations( timeout: 40.0, handler: { error in
            if ( error != nil ) {
                XCTFail("Expectation Failed with error: \(error!)." );
            }
        });
    }
    
    
}

class JudgeRequestDTO : ApiDTO{
    
}

