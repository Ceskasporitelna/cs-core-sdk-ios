//
//  Utils.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 23.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit


public var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

public var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
}

public var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
}

public var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
}

public var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
}

//==============================================================================
extension Data
{
    var byteBuffer : UnsafeBufferPointer<UInt8> { get { return UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(mutating: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)), count: self.count) }}
    var toJSON: AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
        }
        catch let myJSONError {
            clog(WebApiClient.ModuleName, activityName: WebApiClientActivities.JSONSerialization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error creating JSON from NSData: \(myJSONError)." )
        }
        return nil
    }
}

//==============================================================================
public extension UIApplication
{
    //--------------------------------------------------------------------------
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController {
            return topViewController( nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

