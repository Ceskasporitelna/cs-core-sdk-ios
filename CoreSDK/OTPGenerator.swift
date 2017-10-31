//
//  OTPGenerator.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 04.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation


class OTPGenerator{
    
    fileprivate let base64Otkp : String;
    fileprivate let clientId : String;
    fileprivate let fingerprint : String;
    fileprivate let otpAttributes : OTPAttributes;
    
    
    init(base64Otkp:String,clientId:String,fingerprint:String,otpAttributes: OTPAttributes){
        self.base64Otkp = base64Otkp;
        self.clientId = clientId;
        self.fingerprint = fingerprint;
        self.otpAttributes = otpAttributes;
    }
    
    
    func generateOneTimePassword(_ currentTimeStamp : TimeInterval) -> String?{
        let payload = constructPayload(currentTimeStamp);
        guard let keyData = Data(base64Encoded: self.base64Otkp, options: NSData.Base64DecodingOptions()) else{
            return nil;
        }
        let hmacData = payload.sha256(keyData);
        let code = exctractCodeFromHmac(hmacData);
        let formatter = NumberFormatter();
        formatter.minimumIntegerDigits = self.otpAttributes.OTP_LENGTH;
        return formatter.string( from: NSNumber(value: code as UInt32) );
    }
    
    
    func exctractCodeFromHmac(_ data:Data) -> UInt32{
        let offset = data.count - 4;
        let hmacBytes = data.byteBuffer;
        let bytes:[UInt8] = [hmacBytes[offset],hmacBytes[offset+1],hmacBytes[offset+2],hmacBytes[offset+3]];
        
        var code: UInt32 = 0
        memcpy(&code, bytes, bytes.count)
        
        code = code & 0x7FFFFFFF;
        code = code % UInt32( pow( Double(10), Double(self.otpAttributes.OTP_LENGTH) ) );
        return code;
    }
    

    func constructTimePartOfPayload(_ currentTimeStamp : TimeInterval) -> UInt64{
        let unixTimestamp = currentTimeStamp;//This is in seconds
        let otpStartTimestamp = unixTimestamp*1000 - TimeInterval(otpAttributes.OTP_START); //This is in miliseconds now
        let timeWindow = 1000.0*otpAttributes.OTP_INTERVAL; //Miliseconds also
        let otpStamp = UInt64(floor(otpStartTimestamp/timeWindow));
        return otpStamp;
    }
    
    
    func constructPayload(_ currentTimeStamp : TimeInterval) -> String{
        let otpStamp = constructTimePartOfPayload(currentTimeStamp);
        let message = "\(otpStamp)\(self.clientId)\(self.fingerprint)";
        return message;
    }
    
}
