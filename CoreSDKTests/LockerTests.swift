//
//  LockerTests.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 22.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class LockerTests: XCTestCase
{
    var judgeSession : JudgeSession!
    var coreSDK : CoreSDKAPI!
    var checkStatusChanges = false
    var locker : Locker{
        get{
            return coreSDK.locker as! Locker
        }
    }
    var currentStateExpectation : XCTestExpectation?
    
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
            .useLoggerPrefix("<*>")
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(LockerTests.lockerStatusChanged(_:)), name: NSNotification.Name(rawValue: self.coreSDK.locker.LockerStatusChangedNotification), object: nil)
        checkStatusChanges = true
    }
    
    override func tearDown()
    {
        NotificationCenter.default.removeObserver(self)
        checkStatusChanges = false
        super.tearDown()
    }
    
    

    
    fileprivate func verifyLockerIsInUnregisteredState()
    {
        XCTAssertEqual(LockStatus.unregistered, self.locker.status.lockStatus)
        XCTAssertEqual(LockType.noLock, self.locker.status.lockType)
        XCTAssertEqual(nil, self.locker.status.clientId)
        XCTAssertEqual(false, self.locker.status.hasAesEncryptionKey)
        XCTAssertEqual(false, self.locker.status.hasOneTimePasswordKey)
        XCTAssertEqual(nil,self.locker.accessToken)
        XCTAssertEqual(nil,self.locker.accessTokenExpiration)
        XCTAssertEqual(nil, self.locker.identityKeeper.aesEncryptionKey)
    }
    
    fileprivate func verifyUserIsRegistredAndUnlock()
    {
        XCTAssertEqual(LockStatus.unlocked, self.locker.status.lockStatus)
        XCTAssertEqual(LockType.pinLock, self.locker.status.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", self.locker.status.clientId)
        XCTAssertEqual(true, self.locker.status.hasAesEncryptionKey)
        XCTAssertEqual(true, self.locker.status.hasOneTimePasswordKey)
        XCTAssertEqual("31001130941a89f6df37749d0b736ce9",self.locker.accessToken)
        XCTAssertEqual(1448017910237,self.locker.accessTokenExpiration)
    }

    //MARK: -  Register user
    fileprivate func registerUser()
    {
        self.judgeSession.setNextCase("core.locker.register.sanitized", xcTestCase: self)
        
        let registerExpectation = self.expectation( description: "Doing user registration ..." )
        
        self.currentStateExpectation = self.expectation(description: "User registered notification")
        
        locker.completeUserRegistrationWithCode( "TestCode", lockType: LockType.pinLock, password: "", completion: { ( result: CoreResult<Bool> ) in
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
    
    //MARK: -Lock User
    fileprivate func lockUser()
    {
        self.currentStateExpectation = self.expectation(description: "User locked notification")
        self.coreSDK.locker.lockUser()
        
        self.waitForExpectations( timeout: 60.0, handler: { error in
            if  error != nil  {
                XCTFail("User lock expectation failed with error: \(error!)." )
            }
        })
    }
    
    fileprivate func verifyIdentityKeeperIntegrity(){
        //Disable state change observing for this test
        self.checkStatusChanges = false
        //Register user first
        self.judgeSession.setNextCase("core.locker.register.sanitized", xcTestCase: self)
        
        let registerExpectation = self.expectation( description: "Doing user registration ..." )
        
        locker.completeUserRegistrationWithCode( "TestCode", lockType: LockType.pinLock, password: "", completion: { ( result: CoreResult<Bool> ) in
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
        
        //Make sure data are saved
        self.locker.identityKeeper.saveKeychainDataSync(self.locker.identityKeeper.aesEncryptionKey)
        
        //Check that user is registered even when you load up a new identyty keeper
        let anotherIdentityKeeper = IdentityKeeper()
        anotherIdentityKeeper.loadDkDataSync()
        XCTAssertEqual(LockStatus.locked, anotherIdentityKeeper.lockStatus)
        XCTAssertEqual(LockType.pinLock, anotherIdentityKeeper.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", anotherIdentityKeeper.clientId)
        XCTAssertEqual(nil, anotherIdentityKeeper.accessToken)
        XCTAssertEqual(nil, anotherIdentityKeeper.accessTokenExpiration)
        XCTAssertEqual("0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY=", anotherIdentityKeeper.oneTimePasswordKey)
        XCTAssertEqual("f74f982a24085793" , anotherIdentityKeeper.deviceFingerprint)
        anotherIdentityKeeper.saveSelfDkDataSync()
        
        //Check that encrypted data
        let yetAnotherIdentityKeeper = IdentityKeeper()
        yetAnotherIdentityKeeper.aesEncryptionKey = "aeHuppyi/sxkDgxu+fauc1nUa/5u7AmB2BC0HmpBrGM="
        yetAnotherIdentityKeeper.loadDkDataSync()
        yetAnotherIdentityKeeper.loadEkDataSync(yetAnotherIdentityKeeper.aesEncryptionKey)
        XCTAssertEqual(LockStatus.unlocked, yetAnotherIdentityKeeper.lockStatus)
        XCTAssertEqual(LockType.pinLock, yetAnotherIdentityKeeper.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", yetAnotherIdentityKeeper.clientId)
        XCTAssertEqual("31001130941a89f6df37749d0b736ce9", yetAnotherIdentityKeeper.accessToken)
        XCTAssertEqual(1448017910237, yetAnotherIdentityKeeper.accessTokenExpiration)
        XCTAssertEqual("0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY=", yetAnotherIdentityKeeper.oneTimePasswordKey)
        XCTAssertEqual("f74f982a24085793" , yetAnotherIdentityKeeper.deviceFingerprint)
    }
    
    @objc func lockerStatusChanged(_ notification: Notification){
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
    
    //MARK: - TEST
    func testLockerInitialStateIsUnregistered()
    {
        verifyLockerIsInUnregisteredState()
    }
    
    func testLockerStateIsPerservedAcrossInstances()
    {
        verifyIdentityKeeperIntegrity()
    }
    
    func testUserRegistration()
    {
        registerUser()
        
        verifyUserIsRegistredAndUnlock()
    }
    
    /*func testRegisterEmptyAccessToken()
    {
        self.judgeSession.setNextCase("core.locker.registerNoAccesToken", xcTestCase: self)
        
        let registerExpectation = self.expectation( description: "Doing user registration ..." )
        
        locker.completeUserRegistrationWithCode( "TestCode", lockType: LockType.pinLock, password: "", completion: { ( result: CoreResult<Bool> ) in
            switch result {
            case .success:
                XCTFail( "User registration should failed." )
            case .failure( let error ):
                print("error: \(error.localizedDescription)")
                registerExpectation.fulfill()
            }
        })
        
        self.waitForExpectations( timeout: 60.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        //Verify state after registration
        XCTAssertEqual(LockStatus.unregistered, self.locker.status.lockStatus)
    }*/
    
    func testUserRegistrationLockAndUnlock()
    {
        registerUser()
    
        lockUser()
        
        //Verify state after lock
        XCTAssertEqual(LockStatus.locked, self.locker.status.lockStatus)
        XCTAssertEqual(LockType.pinLock, self.locker.status.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", self.locker.status.clientId)
        XCTAssertEqual(false, self.locker.status.hasAesEncryptionKey)
        XCTAssertEqual(true, self.locker.status.hasOneTimePasswordKey)
        XCTAssertEqual(nil,self.locker.accessToken)
        XCTAssertEqual(nil,self.locker.accessTokenExpiration)
        
        // Unlock user ...
        self.judgeSession.setNextCase("core.locker.unlock", xcTestCase: self)
        self.currentStateExpectation = self.expectation(description: "User unlock notification")
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        
        locker.unlockUserWithPassword(locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                unlockExpectation.fulfill()
                
            case .failure:
                XCTFail( "User unlock failed." )
            }
        })
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        verifyUserIsRegistredAndUnlock()
    }
    
    func performTestAfterDelay(_ seconds: TimeInterval, completion: @escaping (() -> ()))
    {
        let stopTime  = Date().addingTimeInterval(seconds)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
            while (Date().compare(stopTime) == .orderedAscending) {
                Thread.sleep(forTimeInterval: 0.1)
            }
            DispatchQueue.main.async(execute: completion)
        })
    }
    
    func testFailedUnlock(){
        self.registerUser()
        self.lockUser()
        
        self.judgeSession.setNextCase("core.locker.unlock.badPassword", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        
        self.locker.unlockUserWithPassword(self.locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTFail( "User unlock should fail, not succeed." )
            case .failure:
                XCTAssertEqual(remainingAttempts,2)
                unlockExpectation.fulfill()
            }
        })
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unregister expectation failed with error: \(error!)." )
            }
        })
        
        //Verify state after unsuccessfull unlock
        XCTAssertEqual(LockStatus.locked, self.locker.status.lockStatus)
        XCTAssertEqual(LockType.pinLock, self.locker.status.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", self.locker.status.clientId)
        XCTAssertEqual(false, self.locker.status.hasAesEncryptionKey)
        XCTAssertEqual(true, self.locker.status.hasOneTimePasswordKey)
        XCTAssertEqual(nil,self.locker.accessToken)
        XCTAssertEqual(nil,self.locker.accessTokenExpiration)
    }
    
    func testUserRegistrationAfherUnregistrationCausedByFailedUnlock()
    {
        self.registerUser()
          verifyUserIsRegistredAndUnlock()
        
        self.lockUser()
        
        self.judgeSession.setNextCase("core.locker.unlock.unregister", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unregister notification")
        locker.unlockUserWithPassword(locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTFail( "User unlock should fail, not succeed." )
                
            case .failure:
                unlockExpectation.fulfill()
            }
        })
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unregister expectation failed with error: \(error!)." )
            }
        })
        //Verify state after unregistration
        verifyLockerIsInUnregisteredState()
        
        registerUser()
        verifyUserIsRegistredAndUnlock()
    }
    
    func testUseUnlockWithMissingAccessToken()
    {
        registerUser()
        lockUser()
        
        // Unlock user ...
        self.judgeSession.setNextCase("core.locker.unlockBadAccesToken", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unregistered notification")
        
        locker.unlockUserWithPassword(locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTAssert(self.locker.accessToken != nil)
                unlockExpectation.fulfill()
                
            case .failure:
                XCTFail( "User should not unlock." )
            }
        })
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })

    }
    
    func testUseUnlockWithEmptyAccessToken()
    {
        registerUser()
        lockUser()
        
        // Unlock user ...
        self.judgeSession.setNextCase("core.locker.unlockEmptyAccesToken", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unregistered notification")
        
        locker.unlockUserWithPassword(locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTFail( "User should not unlock." )
            case .failure:
                unlockExpectation.fulfill()
            }
        })
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        })
        
        verifyLockerIsInUnregisteredState()
    }
    
    func testUserUnregistration()
    {
        self.registerUser()
        
        self.judgeSession.setNextCase("core.locker.unregister", xcTestCase: self)
        self.currentStateExpectation = self.expectation(description: "User unregister notification")
        let unregisterExpectation = self.expectation( description: "Doing user unregistration ..." )
        
        locker.unregisterUserWithCompletion { result in
            switch result {
            case .success:
                unregisterExpectation.fulfill()
            case .failure( let error ):
                XCTFail( "User unregistration failed with error: \(error.localizedDescription), locker state = \(self.locker.status)." )
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unregister expectation failed with error: \(error!)." )
            }
        })
        verifyLockerIsInUnregisteredState()
    }
    
    func testUserUnregistrationAfterFailedUnlock()
    {
        self.registerUser()
        
        self.lockUser()
        
        self.judgeSession.setNextCase("core.locker.unlock.unregister", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unregister notification")
        locker.unlockUserWithPassword(locker.distortUserPassword(""), completion:  { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTFail( "User unlock should fail, not succeed." )
                
            case .failure:
                unlockExpectation.fulfill()
            }
        })
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unregister expectation failed with error: \(error!)." )
            }
        })
        //Verify state after unregistration
        verifyLockerIsInUnregisteredState()
    }
    
    func testUserUnregistrationAfterFailedOTPUnlock()
    {
        self.registerUser()
        self.verifyUserIsRegistredAndUnlock()
        
        self.lockUser()
        
        self.judgeSession.setNextCase("core.locker.unlockWithOneTimePassword.unregister", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unregister notification")
        locker.unlockUserUsingOTPWithCompletion { (result, remainingAttempts) -> () in
            switch result {
            case .success:
                XCTFail( "User unlock should fail, not succeed." )
                
            case .failure:
                unlockExpectation.fulfill()
            }
        }
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unregister expectation failed with error: \(error!)." )
            }
        })

        verifyLockerIsInUnregisteredState()
    }
   
    func testPasswordChange()
    {
        self.registerUser()
        
        self.judgeSession.setNextCase("core.locker.password", xcTestCase: self)
        
        let changePassExpectation = self.expectation( description: "Changing password ..." )
        //Passwords are fixed in the setUp() function
        self.locker.setFixedUserPassword( "542e47007247fb36c78fe02e97887f8b35f62659628ff6a75a8987d72e2f498e",fixedNewPassword: "645952bb2dee5d421b311742b62d34e4600f561059d25420fc89195e4aa64c4b" )
        self.locker.changePassword(oldPassword: "", newLockType: .gestureLock, newPassword: "") { (result, remainingAttempts) -> () in
            switch result {
            case .success:
                changePassExpectation.fulfill()
            case .failure:
                XCTFail( "User unlock should fail, not succeed." )
            }
        }
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unlock expectation failed with error: \(error!)." )
            }
        })
        
        //Verify state after password change
        XCTAssertEqual(LockStatus.unlocked, self.locker.status.lockStatus)
        XCTAssertEqual(.gestureLock, self.locker.status.lockType)
        XCTAssertEqual("d02017df-96f0-4766-90e8-383661164495", self.locker.status.clientId)
        XCTAssertEqual(true, self.locker.status.hasAesEncryptionKey)
        XCTAssertEqual(true, self.locker.status.hasOneTimePasswordKey)
        XCTAssertEqual("31001130941a89f6df37749d0b736ce9",self.locker.accessToken)
        XCTAssertEqual(1448017910237,self.locker.accessTokenExpiration)
    }
    
    func testOTPUnlock()
    {
        //Setup
        self.checkStatusChanges = false
        self.locker.setFixedCurrentTimestamp(1449246020)
        self.locker.setLockType( LockType.pinLock )
        self.locker.clientId = "d02017df-96f0-4766-90e8-383661164495"
        self.locker.aesEncryptionKey = "aeHuppyi/sxkDgxu+fauc1nUa/5u7AmB2BC0HmpBrGM="
        self.locker.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        self.locker.saveKeychainData(self.locker.aesEncryptionKey)
        self.checkStatusChanges = true
        
        self.lockUser()
        
        self.judgeSession.setNextCase("core.locker.unlockWithOneTimePassword", xcTestCase: self)
        let unlockExpectation = self.expectation( description: "Doing user unlock ..." )
        self.currentStateExpectation = self.expectation(description: "User unlock notification")

        self.locker.unlockUserUsingOTPWithCompletion { (result, remainingAttempts) -> () in
            switch result {
            case .success:
                unlockExpectation.fulfill()
            case .failure:
                XCTFail( "User unlock should fail, not succeed." )
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Unlock expectation failed with error: \(error!)." )
            }
        })
        
       verifyUserIsRegistredAndUnlock()
    }
    
    func testGracefullFailWhenLockerDataAreCorrupted(){
        //Verify that there are some valid data in the keychain
        self.verifyIdentityKeeperIntegrity()
        //Get access to keychain
        let keychain   = Keychain( service: CoreSDKKeychainService )
        do{
            //Store some nonsense into the keychain
            try keychain.set(Data(base64Encoded: "U29tZVNoaXR0eURhdGFJbktleWNoYWlu")! , key: kCoreSDKDataDk)
            try keychain.set(Data(base64Encoded: "U29tZVNoaXR0eURhdGFJbktleWNoYWlu")! , key: kCoreSDKDataEk)
        }
        catch(let error){
            XCTFail("Exception was thrown during the test: \(error)." )
        }
        //Verify that the identity is lost
        let identityKeeper = IdentityKeeper()
        identityKeeper.loadDkDataSync()
        identityKeeper.loadEkDataSync("SomeEncryptionKey")
        XCTAssertNil(identityKeeper.accessToken)
        XCTAssertNil(identityKeeper.accessTokenExpiration)
        XCTAssertNil(identityKeeper.clientId)
        XCTAssertNil(identityKeeper.deviceFingerprint)
        XCTAssertEqual(identityKeeper.lockStatus, LockStatus.unregistered)
        XCTAssertEqual(identityKeeper.lockType, LockType.noLock)
        //Verify that we are able to store identity again
        self.verifyIdentityKeeperIntegrity()
    }
    
     func testRefreshToken(){
        self.registerUser()
        
        self.judgeSession.setNextCase("core.locker.refreshAccessToken.sanitized", xcTestCase: self)
        let refreshExpectation = self.expectation( description: "Doing token refresh ..." )
        self.locker.refreshToken { (result, remainingAttempts) in
            switch result {
            case .success:
                XCTAssertEqual("2d2e3b611d17db36b2ad6ca182134b4a",self.locker.accessToken)
                let expectedExpiration = UInt64(Date().timeIntervalSince1970 + Double(3600) - 5)*1000
                if(expectedExpiration.distance(to: self.locker.accessTokenExpiration!) > 10){
                    XCTFail("Expiration is not computed correctly")
                }
                
                //Verify that the new token and expiration date is persisted
                self.locker.identityKeeper.saveKeychainDataSync(self.locker.aesEncryptionKey!)
                let identityKeeper = IdentityKeeper()
                identityKeeper.loadDkDataSync()
                identityKeeper.loadEkDataSync(self.locker.aesEncryptionKey!)
                XCTAssertEqual("2d2e3b611d17db36b2ad6ca182134b4a",identityKeeper.accessToken)
                if(expectedExpiration.distance(to: identityKeeper.accessTokenExpiration!) > 10){
                    XCTFail("Expiration is not computed correctly")
                }
                refreshExpectation.fulfill()
                
            case .failure(_): break
                
            }
        }
        
        self.waitForExpectations( timeout: 10.0, handler: { error in
            if error != nil {
                XCTFail("Refresh token expectation failed with error: \(error!)." )
            }
        })
        
        
    }
    
}
