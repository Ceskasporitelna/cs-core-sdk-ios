//
//  ErrorsTests.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 20/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class ErrorsTests: XCTestCase
{

    //--------------------------------------------------------------------------
    override func setUp()
    {
        super.setUp()
    }
    
    //--------------------------------------------------------------------------
    override func tearDown()
    {
        super.tearDown()
    }

    //--------------------------------------------------------------------------
    func testErrors()
    {
        XCTAssertEqual(LockerError(lockerErrorCode: .EmptyClientId).localizedDescription, "Empty clientId.")
    }

}
