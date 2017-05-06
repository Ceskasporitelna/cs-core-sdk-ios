//
//  LockerTestsBase.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 13/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class LockerTestsBase: XCTestCase
{
    
    var judgeSession : JudgeSession!
    var coreSDK :      CoreSDKAPI!
    var checkStatusChanges = false
    
    var locker : Locker {
        get{
            return coreSDK.locker as! Locker
        }
    }
    var currentStateExpectation : XCTestExpectation?
    
    //--------------------------------------------------------------------------
    override func setUp()
    {
        super.setUp()
        self.judgeSession = Judge.startNewSession()
        
        coreSDK = CoreSDK()
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
        
        let passwordBytes:[UInt8] = [141,102,223,10,199,67,120,218,11,29,175,119,156,32,162,13,255,83,251,81,165,118,73,0,46,77,147,218,229,77,70,124]
        let passwordData = Data.init(bytes: UnsafePointer<UInt8>(passwordBytes), count: passwordBytes.count )
        let lockerPrivate = coreSDK.locker as! Locker
        //Make sure we have clean environment
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: self.coreSDK.locker.LockerStatusChangedNotification), object: nil)
        currentStateExpectation = nil
        lockerPrivate.unregisterUser()
        lockerPrivate
            .setFixedSessionSecretData( passwordData )
            .setFixedDeviceFingerprint( "f74f982a24085793" )
            .setFixedNonce( "b2785591-99fc-4b95-b2b1-a67146dc10f6" )
            .setFixedUserPassword( "542e47007247fb36c78fe02e97887f8b35f62659628ff6a75a8987d72e2f498e",fixedNewPassword: "645952bb2dee5d421b311742b62d34e4600f561059d25420fc89195e4aa64c4b" )
        NotificationCenter.default.addObserver(self, selector: #selector(self.lockerStatusChanged(_:)), name: NSNotification.Name(rawValue: self.coreSDK.locker.LockerStatusChangedNotification), object: nil)
        checkStatusChanges = true
    }
    
    
    //--------------------------------------------------------------------------
    override func tearDown()
    {
        checkStatusChanges = false
        super.tearDown()
    }
    
    //--------------------------------------------------------------------------
    func registerUser()
    {
        self.judgeSession.setNextCase("core.locker.register.sanitized", xcTestCase: self)
        
        let registerExpectation = self.expectation( description: "Doing user registration ..." )
        
        self.currentStateExpectation = self.expectation(description: "User registered notification")
        
        self.locker.completeUserRegistrationWithCode( "TestCode", lockType: LockType.pinLock, password: "", completion: { ( result: CoreResult<Bool> ) in
            switch result {
            case .success:
                registerExpectation.fulfill()
                
            case .failure( let error ):
                XCTFail( "User registration failed with error: \(error.localizedDescription), locker state = \(self.locker.status)." )
            }
        })
        
        self.waitForExpectations( timeout: 60.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
    }
    
    //--------------------------------------------------------------------------
    func lockUser()
    {
        self.currentStateExpectation = self.expectation(description: "User locked notification")
        self.coreSDK.locker.lockUser()
        
        self.waitForExpectations( timeout: 60.0, handler: { error in
            if  error != nil  {
                XCTFail("User lock expectation failed with error: \(error!)." )
            }
        })
    }
    
    //--------------------------------------------------------------------------
    func lockerStatusChanged(_ notification: Notification)
    {
        if !checkStatusChanges {
            return
        }
        
        if let expectation = currentStateExpectation{
            expectation.fulfill()
            currentStateExpectation = nil
        }else{
            XCTFail("Locker status changed when it was not expected")
        }
    }
}
