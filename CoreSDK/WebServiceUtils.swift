//
//  WebServiceUtils.swift
//  CoreSDKTestApp
//
//  Created by František Kratochvíl on 28.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import UIKit

import Security



//==============================================================================
class WebServiceUtils: NSObject {
    
    static let keyTag = "cz.applifting";
    
    //--------------------------------------------------------------------------
    static fileprivate func base64Encode(_ data: Data) -> String
    {
        return data.base64EncodedString(options: []);
    }

    //--------------------------------------------------------------------------
    static fileprivate func base64Decode(_ strBase64: String) -> Data
    {
        let data = Data(base64Encoded: strBase64, options: []);
        return data!
    }

    //--------------------------------------------------------------------------
    static func randomKeyOfLength(_ length: Int) -> [UInt8]
    {
        var result = [UInt8]();
        
        while ( result.count < length ) {
            var randomNum: UInt8 = 0;
            arc4random_buf(&randomNum, MemoryLayout<UInt8>.size);
            if ( randomNum >= 48 && randomNum <= 90 ) {
                result.append(randomNum);
            }
        }
        return result
    }

    //--------------------------------------------------------------------------
    static func generateSEK() -> (asString: String, asData: Data)
    {
        let key          = randomKeyOfLength(kCCKeySizeAES256)
        let passwordData = Data.init(bytes: UnsafePointer<UInt8>(key), count: kCCKeySizeAES256)        // Password key as data
        let passwordStr  = String.init(bytes: key, encoding: String.Encoding.ascii) // Password key as string
        
        return (passwordStr!, passwordData)
    }
    

    //--------------------------------------------------------------------------
    static func encryptSessionKey(_ key: Data, publicRSAKey: String) -> String
    {
        let sekBase64Data:Data         = base64Encode(key).data(using: String.Encoding.ascii)!
        
        let sekEncryptedData:Data      = RSAUtils.encryptWithRSAPublicKey( sekBase64Data, pubkeyBase64: publicRSAKey, keychainTag: keyTag)!
        let sekEncryptedBase64Str:String = sekEncryptedData.base64EncodedString(options: []);
        
        return sekEncryptedBase64Str;
    }
    
    //--------------------------------------------------------------------------
    static func encryptObjectData(_ object: ApiDTO, key: Data) -> String?
    {
        let json      = object.toJSONData();
        let encrypted = encryptDataAES(json, password: key, useIV: false );
        
        switch ( encrypted ) {
        case .success(let encryptedJSON ):
            return self.base64Encode(encryptedJSON);
            
        case .failure( let error ):
            clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataEncryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Encrypt error: \(error)" );
            return nil;
        }
    }
    
    //--------------------------------------------------------------------------
    static func decryptObjectData<T:Mappable>(_ data: String, key: Data) -> T?
    {
        let dataEncrypted       = base64Decode(data)
        let decrypted           = decryptDataAES(dataEncrypted, password: key, useIV: false );
        
        switch ( decrypted ) {
        case .success( let jsonData ):
            let jsonOpt = jsonData.toJSON
            clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataDecryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Decrypted JSON: \(String(describing: jsonOpt))" );
            if let jsonDict = jsonOpt as? [String:AnyObject] {
                let resultObject:T? = Mapper<T>().map(jsonDict);
                return resultObject
            }
            else {
                clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataDecryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.detailedDebug, format: "Decrypted JSON: \(String(describing: jsonOpt)) was not mapped sucessfully." );
                return nil;
            }
            
        case .failure( let error ):
            clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataDecryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Decrypt error: \(error)" );
            return nil;
        }
    }
    
    //--------------------------------------------------------------------------
    static func encodeRequestObject(_ object: ApiDTO?, key: Data, publicRSAKey: String) -> DataRequestDTO
    {
        // Encrypt SEK
        let sekEncryptedBase64  = WebServiceUtils.encryptSessionKey(key, publicRSAKey: publicRSAKey)
        
        // Encrypt data
        let jsonEncryptedBase64 = ( object != nil ? WebServiceUtils.encryptObjectData(object!, key: key) : "" );
        
        return DataRequestDTO(session: sekEncryptedBase64, data: jsonEncryptedBase64!);
    }
    
    //--------------------------------------------------------------------------
    static func decodeResponseObject<T:Mappable>(_ object: DataResponseDTO, sek: Data) -> T?
    {
        if let data = object.data {
            let result:T? = WebServiceUtils.decryptObjectData( data, key: sek);
            return result;
        }
        else {
            return nil;
        }
    }

    //--------------------------------------------------------------------------
    static func generateUUID() -> String
    {
        return UUID().uuidString;
    }
    
    
    
}
