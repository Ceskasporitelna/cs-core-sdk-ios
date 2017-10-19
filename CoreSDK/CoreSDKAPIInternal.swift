//
//  CoreSDKAPIInternal.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 10/12/2016.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 * Protocol used to support smart enums in the ObjectMapper
 */

//==============================================================================
public protocol Transformable
{
    associatedtype T
    
    /**
     * Returns enum from string value.
     */
    static func enumerate(string: String) -> T
    
    /**
     * Returns the ObjectMapper transformation.
     */
    static func transform() -> TransformOf<T, String>
}

//==============================================================================
public protocol TransformableArray: Transformable
{
    //associatedtype T
    
    /**
     * Returns the ObjectMapper transformation array.
     */
    static func transformArray() -> TransformOf<[T], [String]>
}

