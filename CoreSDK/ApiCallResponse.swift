//
//  ApiCallResponse.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 05/02/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


public class ApiCallResponse{
    /// The URL request sent to the server, if any.
    public let request: Foundation.URLRequest?
    
    /// The server's response to the URL request, if any.
    public let response: HTTPURLResponse?
    
    /// This will be a Dictionary or Array when JSON parsing succeeds, it will be NSData if it does not, it will be null when no data is received from server
    public let data: AnyObject?
    
    
    init()
    {
        self.request  = nil
        self.response = nil
        self.data     = nil
    }
    
    init(request: URLRequest?, response: HTTPURLResponse?, data: AnyObject?){
        self.request  = request
        self.response = response
        self.data     = data
    }
    
}
