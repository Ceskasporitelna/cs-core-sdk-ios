//
//  DataRequestType.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 29/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


enum RequestType{
    case jsonPayload(URLRequest)
    case dataUpload(URLRequest, Data)
    case dataDownload(URLRequest)
    case fileDownload(URLRequest)
}
