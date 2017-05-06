//
//  CoreSDK+Logger.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 30.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

private var levelDict: [LogLevel:String] = [.all:           "All",
                                            .detailedDebug: "DetailedDebug",
                                            .debug:         "Debug",
                                            .info:          "Info",
                                            .warning:       "Warning",
                                            .error:         "Error",
                                            .fatal:         "Fatal"
                                           ]

//==============================================================================
extension CoreSDK
{
    //--------------------------------------------------------------------------
    public func log( _ moduleName: String?, activityName: String?, fileName: NSString?, functionName: NSString?, lineNumber: Int?, logLevel: LogLevel?, message: String )
    {
        self._loggerQueue.async(execute: {
            
            var logText: String!
            
            var moduleInfo: String!
            if let logModuleName = moduleName, let logActivityName = activityName {
                moduleInfo = "[\(logModuleName) \(logActivityName)]"
            }
            else {
                moduleInfo = ""
            }
            
            let shortFileName = ( fileName != nil ? fileName!.lastPathComponent : "" )
            let methodName    = ( functionName != nil ? functionName! : "" )
            let number        = ( lineNumber != nil ? String.init(format: "%lu", lineNumber! ) : "" )
            let level         = ( logLevel != nil ? logLevel! : LogLevel.all )
            
            if let prefix = self.loggerPrefix {
                logText = String.init( format:"%@ (%@) %@ %@::%@():%@ %@\n", prefix, levelDict [level]!, moduleInfo, shortFileName, methodName, number, message )
            }
            else {
                logText = String.init( format:"(%@) %@ %@::%@():%@ %@\n", levelDict [level]!, moduleInfo, shortFileName, methodName, number, message )
            }
            
            if let delegate = self.loggerDelegate {
                delegate.log( level, message: logText )
            }
            else {
                #if DEBUG
                    NSLog( "%@", logText )
                #endif
            }
        })
    }
    
}
