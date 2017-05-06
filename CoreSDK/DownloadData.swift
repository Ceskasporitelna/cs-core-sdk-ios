//
//  DownloadData.swift
//  CSCoreSDK
//
//  Created by Vladimír Nevyhoštěný on 03/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

//==============================================================================
internal class DataRequest: Request
{
    //--------------------------------------------------------------------------
    override init(session: URLSession, task: URLSessionTask)
    {
        super.init( session: session, task: task)
        self.delegate = DataTaskDelegate(task: task) // Download to NSData ...
    }
}

//==============================================================================
extension Manager
{
    
    //--------------------------------------------------------------------------
    internal func downloadData(_ URLRequest: URLRequestConvertible ) -> Request
    {
        return downloadDataWithUrlRequest(URLRequest)
    }
    
    //--------------------------------------------------------------------------
    fileprivate func downloadDataWithUrlRequest(_ urlRequest: URLRequestConvertible) -> Request
    {
        
        var downloadTask: URLSessionDataTask!
        queue.sync {
            downloadTask = self.session.dataTask(with: urlRequest.URLRequest as URLRequest)
        }
        
        let request = DataRequest(session: session, task: downloadTask)
        
        delegate[request.delegate.task] = request.delegate
        
        if startRequestsImmediately {
            request.resume()
        }
        
        return request
    }

}
