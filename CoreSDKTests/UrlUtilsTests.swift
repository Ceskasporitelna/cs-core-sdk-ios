//
//  UrlUtilsTests.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 24/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

import Foundation
import XCTest
import CSCoreSDK


//==============================================================================
class UrlUtilsTests: XCTestCase
{

    
    override func setUp() {

    }
    
    
    func testRelativeForwardUrlConstruction(){
        var url = UrlUtils.urlFromBasePath("https://www.example.com/rootResource/subResource/123", relativePath: "./sign/id" )
        XCTAssertEqual(url, "https://www.example.com/rootResource/subResource/123/sign/id")
        url = UrlUtils.urlFromBasePath("https://www.example.com/rootResource/subResource/123/", relativePath: "./sign/id" )
        XCTAssertEqual(url, "https://www.example.com/rootResource/subResource/123/sign/id")
    }
    
    func testRelativeBackwardUrlConstruction(){
        var url = UrlUtils.urlFromBasePath("https://www.example.com/rootResource/subResource/123", relativePath: "../../sign/id" )
        XCTAssertEqual(url, "https://www.example.com/rootResource/sign/id")
        url = UrlUtils.urlFromBasePath("https://www.example.com/rootResource/subResource/123/", relativePath: "../../sign/id" )
        XCTAssertEqual(url, "https://www.example.com/rootResource/sign/id")
    }
    
}