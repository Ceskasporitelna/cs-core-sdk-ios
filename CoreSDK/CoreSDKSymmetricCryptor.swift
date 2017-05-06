//
//  SymmetricCryptor renamad to CoreSDKSymmetricCryptor
//  CommonCryptoInSwift
//
//  Created by Ignacio Nieto Carvajal on 9/8/15.
//  Copyright © 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kSymmetricCryptorRandomStringGeneratorCharset: [Character] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters.map({$0});

enum CoreSDKSymmetricCryptorAlgorithm {
    case des        // DES standard, 64 bits key
    case des40      // DES, 40 bits key
    case tripledes  // 3DES, 192 bits key
    case rc4_40     // RC4, 40 bits key
    case rc4_128    // RC4, 128 bits key
    case rc2_40     // RC2, 40 bits key
    case rc2_128    // RC2, 128 bits key
    case aes_128    // AES, 128 bits key
    case aes_256    // AES, 256 bits key
    
    // returns the CCAlgorithm associated with this SymmetricCryptorAlgorithm
    func ccAlgorithm() -> CCAlgorithm {
        switch (self) {
        case .des: return CCAlgorithm(kCCAlgorithmDES)
        case .des40: return CCAlgorithm(kCCAlgorithmDES)
        case .tripledes: return CCAlgorithm(kCCAlgorithm3DES)
        case .rc4_40: return CCAlgorithm(kCCAlgorithmRC4)
        case .rc4_128: return CCAlgorithm(kCCAlgorithmRC4)
        case .rc2_40: return CCAlgorithm(kCCAlgorithmRC2)
        case .rc2_128: return CCAlgorithm(kCCAlgorithmRC2)
        case .aes_128: return CCAlgorithm(kCCAlgorithmAES)
        case .aes_256: return CCAlgorithm(kCCAlgorithmAES)
        }
    }
    
    // Returns the needed size for the IV to be used in the algorithm (0 if no IV is needed).
    func requiredIVSize(_ options: CCOptions) -> Int {
        // if kCCOptionECBMode is specified, no IV is needed.
        if options & CCOptions(kCCOptionECBMode) != 0 { return 0 }
        // else depends on algorithm
        switch (self) {
        case .des: return kCCBlockSizeDES
        case .des40: return kCCBlockSizeDES
        case .tripledes: return kCCBlockSize3DES
        case .rc4_40: return 0
        case .rc4_128: return 0
        case .rc2_40: return kCCBlockSizeRC2
        case .rc2_128: return kCCBlockSizeRC2
        case .aes_128: return kCCBlockSizeAES128
        case .aes_256: return kCCBlockSizeAES128 // AES256 still requires 256 bits IV
        }
    }
    
    func requiredKeySize() -> Int {
        switch (self) {
        case .des: return kCCKeySizeDES
        case .des40: return 5 // 40 bits = 5x8
        case .tripledes: return kCCKeySize3DES
        case .rc4_40: return 5
        case .rc4_128: return 16 // RC4 128 bits = 16 bytes
        case .rc2_40: return 5
        case .rc2_128: return kCCKeySizeMaxRC2 // 128 bits
        case .aes_128: return kCCKeySizeAES128
        case .aes_256: return kCCKeySizeAES256
        }
    }
    
    func requiredBlockSize() -> Int {
        switch (self) {
        case .des: return kCCBlockSizeDES
        case .des40: return kCCBlockSizeDES
        case .tripledes: return kCCBlockSize3DES
        case .rc4_40: return 0
        case .rc4_128: return 0
        case .rc2_40: return kCCBlockSizeRC2
        case .rc2_128: return kCCBlockSizeRC2
        case .aes_128: return kCCBlockSizeAES128
        case .aes_256: return kCCBlockSizeAES128 // AES256 still requires 128 bits IV
        }
    }
}

enum CoreSDKSymmetricCryptorError: Error {
    case missingIV
    case cryptOperationFailed
    case wrongInputData
    case unknownError
}

var cypherIV: Data?

//------------------------------------------------------------------------------
func setIV( _ cypher: CoreSDKSymmetricCryptor )
{
    if cypherIV == nil {
        cypher.setRandomIV();
        cypherIV = cypher.iv;
    }
    else {
        cypher.iv = cypherIV!
    }
}

//--------------------------------------------------------------------------
public func encryptDataAES( _ rawData: Data!, password: Data!, useIV: Bool ) -> CoreResult<Data>
{
    if ( password == nil || password.count == 0 ) {
        return CoreResult.failure( CoreSDKError(kind: .emptyPassword ) );
    }
    
    var options : Int = kCCOptionPKCS7Padding;
    if ( !useIV ) {
        options |= kCCOptionECBMode;
    }
    
    var encryptedData: Data?
    var result: CoreResult<Data>?
    
    let cypher = CoreSDKSymmetricCryptor(algorithm: .aes_256, options: options);
    do {
        if ( useIV ) {
            setIV( cypher );
        }
        encryptedData = try cypher.crypt( data: rawData, key: password );
        result        = CoreResult.success(encryptedData!);
    }
    catch let error {
        clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataEncryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Encrypt error: \(error)" );
        result = CoreResult.failure( CoreSDKError(kind: .enryptFailed ) );
    }
    
    return result!;
}

//------------------------------------------------------------------------------
public func encryptStringAES( _ rawString: String!, password: Data!, useIV: Bool ) -> CoreResult<Data>
{
    return encryptDataAES( rawString.data(using: String.Encoding.ascii), password: password, useIV: useIV );
}

//------------------------------------------------------------------------------
public func decryptDataAES( _ encryptedData: Data!, password: Data, useIV: Bool ) -> CoreResult<Data>
{
    if ( encryptedData == nil ) {
        return CoreResult.failure( CoreSDKError(kind: .emptyData ) );
    }
    
    var options : Int = kCCOptionPKCS7Padding;
    if ( !useIV ) {
        options |= kCCOptionECBMode;
    }
    
    var decryptedData: Data?
    var result: CoreResult<Data>?
    
    let cypher = CoreSDKSymmetricCryptor(algorithm: .aes_256, options: options);
    do {
        if ( useIV ) {
            setIV( cypher );
        }
        decryptedData = try cypher.decrypt( encryptedData, key: password );
        result        = CoreResult.success(decryptedData!);
    }
    catch let error {
        clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataDecryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Decrypt error: \(error)" );
        result = CoreResult.failure( CoreSDKError(kind: .enryptFailed ) );
    }
    
    return result!;
}

//------------------------------------------------------------------------------
public func decryptStringAES( _ encryptedData: Data!, password: Data!, useIV: Bool ) -> CoreResult<String>
{
    let decrypted = decryptDataAES( encryptedData, password: password, useIV: useIV );
    switch ( decrypted ) {
    case .success( let decryptedData ):
        return CoreResult.success( NSString(data: decryptedData, encoding: String.Encoding.ascii.rawValue )! as String );
    case .failure( let error ):
        return CoreResult.failure( error );
    }
}


//==============================================================================
class CoreSDKSymmetricCryptor: NSObject
{
    // properties
    var algorithm: CoreSDKSymmetricCryptorAlgorithm // Algorithm
    var options: CCOptions                          // Options (i.e: kCCOptionECBMode + kCCOptionPKCS7Padding)
    var iv: Data?                                 // Initialization Vector

    //--------------------------------------------------------------------------
    init(algorithm: CoreSDKSymmetricCryptorAlgorithm, options: Int)
    {
        self.algorithm = algorithm
        self.options = CCOptions(options)
    }
    
    //--------------------------------------------------------------------------
    convenience init(algorithm: CoreSDKSymmetricCryptorAlgorithm, options: Int, iv: String, encoding: UInt = String.Encoding.utf8.rawValue)
    {
        self.init(algorithm: algorithm, options: options)
        self.iv = iv.data(using: String.Encoding(rawValue: encoding))
    }
    
    //--------------------------------------------------------------------------
    func crypt(string: String, key: Data) throws -> Data
    {
        do {
            if let data = string.data(using: String.Encoding.utf8) {
                return try self.cryptoOperation(data, key: key, operation: CCOperation(kCCEncrypt))
            }
            else { throw CoreSDKSymmetricCryptorError.wrongInputData }
        }
        catch {
            throw(error)
        }
    }
    
    //--------------------------------------------------------------------------
    func crypt(data: Data, key: Data) throws -> Data
    {
        do {
            return try self.cryptoOperation(data, key: key, operation: CCOperation(kCCEncrypt))
        }
        catch {
            throw(error)
        }
    }
    
    //--------------------------------------------------------------------------
    func decrypt(_ data: Data, key: Data) throws -> Data
    {
        do {
            return try self.cryptoOperation(data, key: key, operation: CCOperation(kCCDecrypt))
        }
        catch {
            throw(error)
        }
    }
    
    //--------------------------------------------------------------------------
    internal func cryptoOperation(_ inputData: Data, key: Data, operation: CCOperation) throws -> Data
    {
        // Validation checks.
        if ( iv == nil && (self.options & CCOptions(kCCOptionECBMode) == 0) ) {
            throw( CoreSDKSymmetricCryptorError.missingIV )
        }
        
        // Prepare data parameters
        //let keyData: NSData! = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let keyBytes         = (key as NSData).bytes.bindMemory(to: Void.self, capacity: key.count)
        let keyLength        = size_t(algorithm.requiredKeySize())
        let dataLength       = Int(inputData.count)
        let dataBytes        = (inputData as NSData).bytes.bindMemory(to: Void.self, capacity: inputData.count)
        let bufferData       = NSMutableData(length: Int(dataLength) + algorithm.requiredBlockSize())!
        let bufferPointer    = bufferData.mutableBytes
        let bufferLength     = size_t(bufferData.length)
        
        var ivBuffer: UnsafeRawPointer? = nil
        if let ivData: Data = self.iv {
            ivBuffer = ivData.withUnsafeBytes {$0.pointee}
        }
        
        var bytesDecrypted   = Int(0)
        // Perform operation
        let cryptStatus = CCCrypt(
            operation,                  // Operation
            algorithm.ccAlgorithm(),    // Algorithm
            options,                    // Options
            keyBytes,                   // key data
            keyLength,                  // key length
            ivBuffer,                   // IV buffer
            dataBytes,                  // input data
            dataLength,                 // input length
            bufferPointer,              // output buffer
            bufferLength,               // output buffer length
            &bytesDecrypted)            // output bytes decrypted real length
        
        if Int32(cryptStatus) == Int32(kCCSuccess) {
            bufferData.length = bytesDecrypted // Adjust buffer size to real bytes
            return bufferData as Data
        }
        else {
            clog(CoreSDK.ModuleName, activityName: CoreSDKActivities.DataEncryption.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error in crypto operation: \(cryptStatus)" );
            throw( CoreSDKSymmetricCryptorError.cryptOperationFailed )
        }
    }
    
    // MARK: - Random methods
    //--------------------------------------------------------------------------
    class func randomDataOfLength(_ length: Int) -> Data?
    {
        let mutableData = Data(capacity: length)
        let bytes = UnsafeMutablePointer<UInt8>(mutating: mutableData.withUnsafeBytes {$0.pointee})
        let status = SecRandomCopyBytes(kSecRandomDefault, length, bytes)
        return status == 0 ? mutableData as Data : nil
    }
    
    //--------------------------------------------------------------------------
    class func randomStringOfLength(_ length:Int) -> String
    {
        var string = ""
        for _ in (1...length) {
            string.append(kSymmetricCryptorRandomStringGeneratorCharset[Int(arc4random_uniform(UInt32(kSymmetricCryptorRandomStringGeneratorCharset.count) - 1))])
        }
        return string
    }
    
    //--------------------------------------------------------------------------
    func setRandomIV()
    {
        let length = self.algorithm.requiredIVSize(self.options);
        self.iv    = CoreSDKSymmetricCryptor.randomDataOfLength(length);
    }
}

//==============================================================================
public enum HMACAlgorithm {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .md5:
            result = kCCHmacAlgMD5
        case .sha1:
            result = kCCHmacAlgSHA1
        case .sha224:
            result = kCCHmacAlgSHA224
        case .sha256:
            result = kCCHmacAlgSHA256
        case .sha384:
            result = kCCHmacAlgSHA384
        case .sha512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .md5:
            result = CC_MD5_DIGEST_LENGTH
        case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
        case .sha224:
            result = CC_SHA224_DIGEST_LENGTH
        case .sha256:
            result = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            result = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}


//==============================================================================
public extension String
{
    
    //--------------------------------------------------------------------------
    func toBase64() -> String
    {
        let data = self.data(using: String.Encoding.utf8);
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
    }
    
    //--------------------------------------------------------------------------
    func sha1() -> String
    {
        let data     = self.data(using: String.Encoding.utf8)!
        var digest   = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH));
        
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest);
        let hexBytes = digest.map { String(format: "%02hhx", $0) };
        
        return hexBytes.joined(separator: "")
    }
    
    //--------------------------------------------------------------------------
    func sha256(_ key: String) -> String
    {
        let inputData: Data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let keyData: Data   = key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        let algorithm         = HMACAlgorithm.sha256;
        let digestLen         = algorithm.digestLength();
        let result            = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CCHmac(algorithm.toCCHmacAlgorithm(), (keyData as NSData).bytes, Int(keyData.count), (inputData as NSData).bytes, Int(inputData.count), result);
        let data              = Data(bytes: UnsafePointer<UInt8>(result), count: digestLen);
        
        result.deinitialize();
        
        return data.base64EncodedString(options: []);
    }
    
    //NSData in, NSData out. No nonsense about encoding transformations.
    func sha256(_ key: Data) -> Data
    {
        let inputData: Data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let keyData: Data   = key;
        
        let algorithm         = HMACAlgorithm.sha256;
        let digestLen         = algorithm.digestLength();
        let result            = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        
        CCHmac(algorithm.toCCHmacAlgorithm(), (keyData as NSData).bytes, Int(keyData.count), (inputData as NSData).bytes, Int(inputData.count), result);
        let data              = Data(bytes: UnsafePointer<UInt8>(result), count: digestLen);
        
        result.deinitialize();
        
        return data;
    }
    
    //--------------------------------------------------------------------------
    func sha256() -> String
    {
        let inputData: Data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        var hash            = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        
        inputData.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(inputData.count), &hash)
        }
        
        return Data(bytes: hash).base64EncodedString(options: [])
    }
    
    
    //--------------------------------------------------------------------------
    func decodeBase64() -> String?
    {
        if let decodedData = Data(base64Encoded: self, options:NSData.Base64DecodingOptions([])) {
            return String(data: decodedData, encoding: String.Encoding.ascii )!
        }
        else {
            return nil;
        }
    }
    
    //--------------------------------------------------------------------------
    func subStringFromStartIndex(_ startIndex: Int, length: Int) -> String
    {
        //let range = Range(start: self.startIndex.advancedBy(startIndex), end: self.startIndex.advancedBy(startIndex + length));
        let range = Range( self.characters.index(self.startIndex, offsetBy: startIndex)..<self.characters.index(self.startIndex, offsetBy: startIndex + length) )
        return self.substring(with: range);
    }
    
    //--------------------------------------------------------------------------
    func hmac(_ algorithm: HMACAlgorithm, key: String) -> String
    {
        let str       = self.cString(using: String.Encoding.utf8);
        let strLen    = Int(self.lengthOfBytes(using: String.Encoding.utf8));
        let digestLen = algorithm.digestLength();
        
        let result    = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        let keyStr    = key.cString(using: String.Encoding.utf8)
        let keyLen    = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac( algorithm.toCCHmacAlgorithm(), keyStr!, keyLen, str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i]);
        }
        let digest = String(hash);
        
        result.deallocate(capacity: digestLen);
        
        return digest;
    }
    
    
}

