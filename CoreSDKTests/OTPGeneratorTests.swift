//
//  OTPGeneratorTests.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 04.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import XCTest
@testable import CSCoreSDK


class OTPGeneratorTests: XCTestCase{
    fileprivate var generator : OTPGenerator!
    
    override func setUp() {
        self.generator = OTPGenerator(base64Otkp: "0eaBoyBkUdlZ8X0T/xrntoxK5/MHi2vFt8ui6Zd7SmY=", clientId: "c0f9fe23-21ea-493c-9286-6d3f0d7826b0", fingerprint: "C6F0D156-8F29-43C6-AF59-166F86953F84", otpAttributes: OTPAttributes());
    }
    
    
    func testPayloadGeneration(){
        //Human time (GMT): Fri, 04 Dec 2015 16:20:20 GMT
        let payload = self.generator.constructPayload(1449246020);
        print(payload)
        XCTAssertEqual(payload, "48274530c0f9fe23-21ea-493c-9286-6d3f0d7826b0C6F0D156-8F29-43C6-AF59-166F86953F84")
    }
    
    func testOTPGeneration(){
         //Human time (GMT): Fri, 04 Dec 2015 16:20:20 GMT
        let otp = self.generator.generateOneTimePassword(1449246020);
        XCTAssertEqual(otp, "7217358")
    }
    
    func testTimePartOfPayload(){
        let number = self.generator.constructTimePartOfPayload(1421248092);
        XCTAssertEqual(number, 47341266)
    }
}


