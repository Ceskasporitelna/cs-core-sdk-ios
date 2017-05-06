//
//  WebApiEntity.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


open class WebApiEntity : Mappable{
    public internal(set) var resource : Resource!;
    //Sadly, we have to store the pathSuffix of the Resource so that we can call methods within the CoreSDK with fully resolved path.
    internal             var pathSuffix  : String?;
    internal var parameters : [String:AnyObject]?;
    
    public init(){
        
    }
    
    required public init?(_ map: Map){
    }
    
    open func mapping(_ map: Map) {
    }
}
