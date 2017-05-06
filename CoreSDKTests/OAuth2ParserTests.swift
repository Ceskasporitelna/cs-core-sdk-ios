//
//  OAuth2ParserTests.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 17/03/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import XCTest
@testable import CSCoreSDK

//==============================================================================
class OAuth2ParserTests: XCTestCase
{

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //--------------------------------------------------------------------------
    func testRightOAuth2Url()
    {
        let parser  = OAuth2Parser( url: URL( string: "csastest://auth-completed?state=profile&dummy=9834534534&foo=CGAA@bar=&code=b522a128081cee715046c603d8943370" )! )
        let result  = parser.parseResponse()
        
        switch ( result ) {
        case .success(_):
            XCTAssertTrue( parser.code == "b522a128081cee715046c603d8943370", "Wrong parameter code!" )
            XCTAssertTrue( parser.parametres ["dummy"] == "9834534534", "Wrong parameter dummy!" )
            XCTAssertNil( parser.parametres ["bar"], "Wrong parameter bar!" )
            
        case .failure( let error ):
            XCTFail( "Parse error:\(error)" )
        }
    }

    //--------------------------------------------------------------------------
    func testWrongOAuth2Url()
    {
        let parser  = OAuth2Parser( url: URL( string: "csastest://auth-completed?state=profile&dummy9834534534&foo=CGAA@bar=&cod=b522a128081cee715046c603d8943370" )! )
        let result  = parser.parseResponse()
        
        switch ( result ) {
        case .success(_):
            XCTFail( "Parser should fail, code was not present" )
            
        case .failure:
            break
        }
    }
    

}
