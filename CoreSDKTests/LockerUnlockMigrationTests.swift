//
//  LockerUnlockMigrationTests.swift
//  CoreSDKTests
//
//  Created by Vladimír Nevyhoštěný on 29/09/2017.
//  Copyright © 2017 Applifting. All rights reserved.
//

import XCTest

@testable import CSCoreSDK

//==============================================================================
class LockerUnlockMigrationTests: LockerTestsBase
{
    //var apiClient : TestApiClient!
    
    //--------------------------------------------------------------------------
    override func setUp()
    {
        super.setUp()
        self.checkStatusChanges = false
        //let config                         = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: Judge.BaseURL, oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        //self.apiClient                     = TestApiClient(config: config)
        //self.apiClient.accessTokenProvider = self.coreSDK.sharedContext
    }
    
    //--------------------------------------------------------------------------
    override func tearDown()
    {
        super.tearDown()
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigration()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
                                         },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTAssert(self.locker.lockStatus == .unlocked, "User must be unlocked now!")
                                                XCTAssert(self.locker.accessToken == "31001130941a89f6df37749d0b736ce9", "Wrong access token!")
                                                XCTAssert(self.locker.accessTokenExpiration == 1448017910237, "Wrong access token expiration!")
                                                XCTAssertTrue(self.locker.status.hasAesEncryptionKey, "Must have EK!")
                                                XCTAssertTrue(self.locker.status.hasOneTimePasswordKey, "Must have OTP!")
                                                expectation.fulfill()
                                                
                                            case .failure(let error):
                                                XCTFail("User unlock after migration failed with error: \(error.localizedDescription).")
                                            }
                                         }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationBadPassword()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.badPassword", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, bad password ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
                                         },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration must fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                expectation.fulfill()
                                                
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationPasswordServerError()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.password.serverError", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, password server error ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="

        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
                                         },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 500)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationPasswordServerUnavailable()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.password.serverUnavailable", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, password server error ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
        },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 503)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationPasswordUnregister()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.password.unregister", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, password unregister ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
        },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 401)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationServerError()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.serverError", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, server error ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
        },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 500)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationServerUnavailable()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.serverUnavailable", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, server error ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
        },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 503)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
    
    //--------------------------------------------------------------------------
    func testUnlockMigrationUnregister()
    {
        self.judgeSession.setNextCase("core.locker.unlockMigration.unregister", xcTestCase: self)
        
        let expectation                       = self.expectation( description: "Unlock migration, password unregister ..." )
        
        self.locker.setFixedUserPassword("711471ce89b4f632d2c61b1bdf3a7a49ffed939a4cfdb4eec4988504303c58ad", fixedNewPassword: "d765cd0fb1e8330dbc80e5a103db46ef4f753e08f360f26b7623b3960977fe31")
        
        let lockerMigrationDTO                = LockerMigrationDataDTO()
        lockerMigrationDTO.clientId           = "d02017df-96f0-4766-90e8-383661164495"
        lockerMigrationDTO.deviceFingerprint  = "f74f982a24085793"
        lockerMigrationDTO.oneTimePasswordKey = "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY="
        lockerMigrationDTO.encryptionKey      = "jWbfCsdDeNoLHa93nCCiDf9T+1GldkkALk2T2uVNRnw="
        
        self.locker.unlockAfterMigration(lockType: .fingerprintLock,
                                         password: "random password",
                                         passwordHashProcess: { password in
                                            return password.sha256(salt: "f74f982a24085793")
        },
                                         data: lockerMigrationDTO) { result in
                                            switch result.0 {
                                            case .success(_):
                                                XCTFail("User unlock after migration has to fail here!")
                                                
                                            case .failure(let error):
                                                XCTAssert(self.locker.lockStatus == .unregistered, "User must be unregistered now!")
                                                XCTAssert((error as! LockerError).kind == .migrationUnlockFailed)
                                                if let nestedError = (error as! LockerError).userInfo [NSUnderlyingErrorKey] as? NSError {
                                                    XCTAssert(nestedError.code == 401)
                                                    expectation.fulfill()
                                                }
                                                else {
                                                    XCTFail()
                                                }
                                            }
        }
        
        self.waitForExpectations(timeout: 5.0) { error in
            if error != nil {
                XCTFail("Expectation Failed with error: \(error!)." )
            }
        }
    }
}
