//
//  Transform.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

/**
 Use instances of this class in conjuction with ResourceUtils to transform the response that came from WebApi.
*/
public class WebApiTransform<T:WebApiEntity> : TransformBase{
    
    var object : ApiCallResult<T>{
        return self.obj as! ApiCallResult<T>
    }
    
    fileprivate var f : ((_ obj:ApiCallResult<T>) -> CoreResult<T>)
    
    public init(_ f: @escaping (_ obj:ApiCallResult<T>) -> CoreResult<T>)
    {
        self.f = f
        super.init()
    }
    
    override func doTransform(_ obj: Any) -> Any {
        return self.f(object)
    }
    
}

//--------------------------
public class TransformBase{
    
    internal var obj : Any!
    
    func transform(_ obj:Any) -> Any{
        self.obj = obj
        return doTransform(obj: obj)
    }
    
    internal func doTransform(_ obj:Any) -> Any{
        return obj
    }
    
}
