//
//  DateMapHelper.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 27/10/2016.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
public class DateMapHelper
{
    fileprivate let dateFormatter = DateFormatter()
    
    //--------------------------------------------------------------------------
    public init( dateFormat: String )
    {
        self.dateFormatter.dateFormat = dateFormat
    }
    
    //--------------------------------------------------------------------------
    public func transformArray() -> TransformOf<[Date], [String]>
    {
        return TransformOf<[Date], [String]>(
            fromJSON: { (values: [String]?) -> [Date]? in
                if let values = values {
                    var result: [Date] = []
                    for value in values {
                        if let date = self.dateFormatter.date(from: value) {
                            result.append(date)
                        }
                    }
                    return result
                }
                return nil
        },
            toJSON: { (values: [Date]?) -> [String]? in
                if let values = values {
                    var result: [String] = []
                    for date in values {
                        result.append(self.dateFormatter.string(from: date))
                    }
                    return result
                }
                return nil
        })
    }
}
