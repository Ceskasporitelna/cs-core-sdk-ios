//
//  RequestSigner.swift
//  CoreSDKTestApp
//
//  Created by Vratislav Kalenda on 28.11.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation



class RequestSigner{
    fileprivate let webApiKey : String;
    fileprivate let privateKey : Data;
    var fixedNonce : String? = nil;
    
    init(webApiKey:String, privateKey:Data){
        self.webApiKey = webApiKey;
        self.privateKey = privateKey;
    }
    
    
    fileprivate func getNonce() -> String{
        if(fixedNonce != nil){
            return fixedNonce!;
        }
        return WebServiceUtils.generateUUID();
    }
    
    
    func stripServerFromPath(_ pathOrUrl:String) -> String{
        let urlObj = URL(string: pathOrUrl);
        if(urlObj != nil){
            return urlObj!.path
        }else{
            return pathOrUrl;
        }
    }
    
    
    //Use empty string if you want to sign request with empty body
    func generateSignatureForRequest(_ pathOrUrl:String,data:String,nonce:String) -> String{
        let resolvedPath : String = stripServerFromPath(pathOrUrl);
        let payload : String = "\(self.webApiKey)\(nonce)\(resolvedPath)\(data)"
        let str       = payload.cString(using: String.Encoding.utf8);
        let strLen    = Int(payload.lengthOfBytes(using: String.Encoding.utf8));
        let digestLen = CC_SHA1_DIGEST_LENGTH;
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(digestLen))
        CCHmac( CCHmacAlgorithm(kCCHmacAlgSHA1), (self.privateKey as NSData).bytes, self.privateKey.count, str!, strLen, result)
        let resultAsData = Data(bytes: UnsafePointer<UInt8>(result), count: Int(digestLen));
        result.deallocate(capacity: Int(digestLen));
        return resultAsData.base64EncodedString(options: NSData.Base64EncodingOptions());
    }
    
    func signRequest(_ request : NSMutableURLRequest){
        let nonce = getNonce()
        var payload : String;
        if let bodyData = request.httpBody{
            let json = String(data: bodyData, encoding: String.Encoding.utf8);
            payload = json!;
        }else{
            payload = "";
        }
        request.setValue(nonce, forHTTPHeaderField: "nonce");
        request.setValue(self.generateSignatureForRequest((request.url?.absoluteString)!, data: payload, nonce: nonce), forHTTPHeaderField: "signature");
    }
    
    
    
    
    
}
