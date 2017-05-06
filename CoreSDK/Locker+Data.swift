//
//  Locker+Data.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 12.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

public class LockerOAuth2Info
{
    public var code: String?
    public var completion : UnlockCompletion?
        
    required convenience public init( code: String, completion: @escaping UnlockCompletion )
    {
        self.init()
        self.code = code
        self.completion = completion
    }
    
    convenience public init( completion: @escaping UnlockCompletion )
    {
        self.init()
        self.completion = completion
    }

}
