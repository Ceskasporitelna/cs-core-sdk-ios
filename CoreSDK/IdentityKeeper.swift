//
//  KeychainManager.swift
//  CoreSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 28.10.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation

import Security


let CoreSDKKeychainService               = "cs.CSCoreSDK.Locker"
let kCoreSDKDataDk                       = "coresdk.data.dk"
let kCoreSDKDataEk                       = "coresdk.data.ek"
let SerialQueueName                      = "coresdk.keychainmanager.serialqueue"
let PropertyQueueName                    = "coresdk.keychainmanager.propertyqueue"
let kVendorIdentifierKey                 = "coresdk.vendoridentifier"
let kLockerInitializationUserDefaultsKey = "coresdk.locker.inited"
let kLockerEnvironmentUserDefaultsKey    = "coresdk.locker.environment"

public class IdentityKeeper: NSObject
{
    
    public var protectedDataAvailable: Bool {
        return UIApplication.shared.isProtectedDataAvailable
    }
    
    public var clientId: String? {
        get {
            var result: String!
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.clientId
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.clientId = newValue
            })
        }
    }
    
    public var aesEncryptionKey: String? {
        get {
            var result: String?
            self.propertyQueue.sync(execute: {
                result = self._aesEncryptionKey
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._aesEncryptionKey = newValue
            })
        }
    }
    
    public var isUserRegistered: Bool {
        return Int( self.lockStatus.rawValue ) > Int( LockStatus.unregistered.rawValue )
    }
    
    public var deviceFingerprint: String? {
        get {
            var result: String?
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = ( self.fixedDeviceFingerprint != nil ? self.fixedDeviceFingerprint : self._keychainDkDTO?.deviceFingerprint )
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.deviceFingerprint = newValue
            })
        }
    }
    
    public var oneTimePasswordKey: String? {
        get {
            var result: String!
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.oneTimePasswordKey
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.oneTimePasswordKey = newValue
            })
        }
    }
    
    public var lockType: LockType {
        get {
            var result: LockType!
            self.propertyQueue.sync(execute: {

                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.lockType
            })
            
            if result == nil {
                result = LockType.noLock
            }
            
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.lockType = newValue
            })
        }
    }
    
    public var accessToken: String? {
        get {
            var result: String!
            let encryptionKey = self.aesEncryptionKey
            self.propertyQueue.sync(execute: {

                if self._keychainEkDTOReadPending && UIApplication.shared.isProtectedDataAvailable {
                    self.loadEkDataSync(encryptionKey)
                }
                
                result = self._keychainEkDTO?.accessToken
            })
            
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainEkDTO?.accessToken = newValue
            })
        }
    }
    
    public var accessTokenExpiration: UInt64? {
        get {
            var result: UInt64!
            let encryptionKey = self.aesEncryptionKey
            self.propertyQueue.sync(execute: {
                if self._keychainEkDTOReadPending && UIApplication.shared.isProtectedDataAvailable {
                    self.loadEkDataSync(encryptionKey)
                }
                result = self._keychainEkDTO?.accessTokenExpiration?.uint64Value
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                if let val = newValue{
                    self._keychainEkDTO?.accessTokenExpiration = NSNumber(value: val as UInt64)
                }else{
                    self._keychainEkDTO?.accessTokenExpiration = nil
                }
            })
        }
    }
    
    public var touchIdToken: String? {
        get {
            var result: String!
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.touchIdToken
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.touchIdToken = newValue
            })
        }
    }
    
    public var lockStatus: LockStatus {
        if (self.clientId == nil || self.deviceFingerprint == nil) {
            return LockStatus.unregistered
        } else if (self.aesEncryptionKey == nil) {
            return LockStatus.locked
        } else {
            return LockStatus.unlocked
        }
    }
    
    public var refreshToken: String? {
        get {
            var result: String!
            let encryptionKey = self.aesEncryptionKey
            self.propertyQueue.sync(execute: {
                if self._keychainEkDTOReadPending && UIApplication.shared.isProtectedDataAvailable {
                    self.loadEkDataSync(encryptionKey)
                }
                result = self._keychainEkDTO?.refreshToken
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainEkDTO?.refreshToken = newValue
            })
        }
    }
    
    public var oauth2Code: String? {
        get {
            var result: String!
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.oauth2Code
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.oauth2Code = newValue
            })
        }
    }
    
    
    public var noAuthTypePassword: String? {
        get {
            var result: String!
            self.propertyQueue.sync(execute: {
                if self._keychainDkDTOReadPending && self.protectedDataAvailable {
                    self.loadDkDataSync()
                }
                result = self._keychainDkDTO?.noAuthTypePassword
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainDkDTO?.noAuthTypePassword = newValue
            })
        }
    }
    
    public var tokenType: String? {
        get {
            var result: String!
            let encryptionKey = self.aesEncryptionKey
            self.propertyQueue.sync(execute: {
                if self._keychainEkDTOReadPending && UIApplication.shared.isProtectedDataAvailable {
                    self.loadEkDataSync(encryptionKey)
                }
                result = self._keychainEkDTO?.tokenType
            })
            return result
        }
        set {
            self.propertyQueue.sync(execute: {
                self._keychainEkDTO?.tokenType = newValue
            })
        }
    }
    
    //--------------------------------------------------------------------------
    public var isRunningInTestMode: Bool {
        return self.fixedSessionSecretData != nil && self.fixedDeviceFingerprint != nil
    }
    
    fileprivate var keychainPassword: String {
        return self.keychainPasswordKey()
    }
    
    fileprivate let syncQueue:            DispatchQueue!
    fileprivate let propertyQueue:        DispatchQueue!
    fileprivate var _keychainDkDTO:       KeychainDkDTO?
    fileprivate var _keychainEkDTO:       KeychainEkDTO?
    fileprivate var _aesEncryptionKey:    String?

    // MARK: Indicate the requirements for reading data from KeyChain on the locked device
    
    fileprivate var _keychainDkDTOReadPending = false
    fileprivate var _keychainEkDTOReadPending = false
    
    // MARK: Private properties for testing ...
    
    public  var fixedSessionSecretData: Data? = nil   // returned with generateSecretData(), if set
    public  var fixedDeviceFingerprint: String? = nil   // returned with deviceFingerprint, if set
    
    fileprivate var freshInstallWipeCheckPerformed = false
    fileprivate var environmentChangedWipeCheckPerformed = false
    
    
    override init()
    {
        self.syncQueue     = DispatchQueue( label: SerialQueueName )
        self.propertyQueue = DispatchQueue( label: PropertyQueueName)
        
        super.init()
        self.loadDkDataSync()
    }
    
    //--------------------------------------------------------------------------
    public func attemptToAccessKeychainData() throws
    {
        let dataAvailable = self.protectedDataAvailable
        
        if self._keychainDkDTOReadPending && dataAvailable {
            self.loadDkDataSync()
        }
        
        if self._keychainEkDTOReadPending && dataAvailable {
            self.loadEkDataSync(self.aesEncryptionKey)
        }
        
        if self._keychainDkDTOReadPending || self._keychainEkDTOReadPending {
            throw LockerError(kind: .protectedDataNotAvailable)
        }
    }
    
    //--------------------------------------------------------------------------
    fileprivate func loadApiDTOWithKeychain<T: ApiDTO>( _ keychain: Keychain, forKey: String, passwordData: Data ) throws -> T?
    {
        if !UIApplication.shared.isProtectedDataAvailable {
            throw LockerError.errorOfKind(.protectedDataNotAvailable)
        }
        
        var result: T?
        
        do {
            if let keychainData = try keychain.getData( forKey ) {
                let decrypted = decryptDataAES( keychainData, password: passwordData, useIV: false )
                switch  ( decrypted ) {
                case .success( let decryptedData ):
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject( with: decryptedData, options: [] )
                        result             = ApiDTO.fromJSON(jsonDictionary as! [String : AnyObject])
                    }
                    catch ( let error as NSError ) {
                        clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainReading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error while parsing keychain data: \(error)" )
                    }
                    
                case .failure( let error ):
                    clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainReading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error while decrypting keychain data: \(error)" )
                }
            }
        }
        catch ( let error as NSError ) {
            clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainReading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error while loading keychain data: \(error)" )
        }
        
        return result
    }
    
    //--------------------------------------------------------------------------
    fileprivate func saveApiDTOWithKeychain( _ keychain: Keychain, apiDTO: ApiDTO, forKey: String, passwordData: Data ) -> CoreResult<Bool>
    {
        var result: CoreResult<Bool>!
        let rawData = apiDTO.toJSONData()
        
        do {
            let encryptResult = encryptDataAES(rawData, password: passwordData, useIV: false )
            switch encryptResult {
            case .success( let data ):
                try keychain.set(data, key: forKey )
                result = CoreResult.success(true)
                
            case .failure( let error ):
                result = CoreResult.failure( error )
            }
        }
        catch (let error as NSError) {
            result = CoreResult.failure( error )
        }
        return result
    }
    
    func wipeKeychainIfJustInstalled(){
        //We can make this check only in the foreground otherwise, the NSUserDefaults could be corrupted. 
        //See: http://stackoverflow.com/questions/20269116/nsuserdefaults-loosing-its-keys-values-when-phone-is-rebooted-but-not-unlocked
        //We skip the check if we cannot get to the data and check it on the sensitive data access everytime, until we can perform the check
        if self.freshInstallWipeCheckPerformed == false && UIApplication.shared.isProtectedDataAvailable {
            self.freshInstallWipeCheckPerformed = true
            if UserDefaults.standard.bool(forKey: kLockerInitializationUserDefaultsKey) == false{
                 UserDefaults.standard.set(true, forKey: kLockerInitializationUserDefaultsKey)
                 UserDefaults.standard.synchronize()
                //This will wipe keychain
                syncQueue.sync {
                    self.wipeKeychainDataSyncAndReinitEmptyDTOs()
                }
            }
        }
    }
    
    func wipeKeychainIfEnvironmentChanged(_ oAuthClientId:String,oAuthClientSecret:String){
        //We can make this check only in the foreground otherwise, the NSUserDefaults could be corrupted.
        //See: http://stackoverflow.com/questions/20269116/nsuserdefaults-loosing-its-keys-values-when-phone-is-rebooted-but-not-unlocked
        //We skip the check if we cannot get to the data for now
        if self.environmentChangedWipeCheckPerformed == false && UIApplication.shared.isProtectedDataAvailable{
            self.environmentChangedWipeCheckPerformed = true
            //Compute sha1 of clientId and clientSecert
            let sha1 = "\(oAuthClientId):\(oAuthClientSecret)".sha1()
            //Compare it to the value stored in user defaults
            let storedSha1 = UserDefaults.standard.string(forKey: kLockerEnvironmentUserDefaultsKey)
            if storedSha1 != nil && sha1 != storedSha1!{
                //This will wipe keychain
                syncQueue.sync {
                    self.wipeKeychainDataSyncAndReinitEmptyDTOs()
                }
            }
            if storedSha1 == nil || sha1 != storedSha1{
                //Store new envrionmen checksum
                UserDefaults.standard.setValue(sha1,forKey: kLockerEnvironmentUserDefaultsKey)
                UserDefaults.standard.synchronize()
            }
            
        }
    }
    
    func loadDkDataSync()
    {
        let keychain = Keychain( service: CoreSDKKeychainService )
        do {
            self._keychainDkDTO            = try self.loadApiDTOWithKeychain( keychain, forKey: kCoreSDKDataDk, passwordData: self.keychainPassword.data(using: String.Encoding.ascii)! )
            self._keychainDkDTOReadPending = false
        }
        catch let error {
            self._keychainDkDTO = nil
            if (error as? LockerError)?.kind == LockerErrorKind.protectedDataNotAvailable {
                self._keychainDkDTOReadPending = true
            }
            else {
                assert(false, "Unhandled error when reading keychain data: \(error.localizedDescription)")
            }
        }
        
        if self.lastNotificationState == nil {
            self.lastNotificationState = self.lockStatus
        }
        
        if self._keychainDkDTO == nil {
            self._keychainDkDTO = KeychainDkDTO()
        }
    }
    
    public func initEkData(){
        self._keychainEkDTO = KeychainEkDTO()
    }
    
    func saveSelfDkDataSync(){
        self.saveDkDataSync(KeychainDkDTO(source:self._keychainDkDTO))
    }
    
    func saveDkDataSync(_ dkData : KeychainDkDTO)
    {
        // Save KeychainDkDTO ...
        let keychain = Keychain( service: CoreSDKKeychainService )
        
        let saveResult = self.saveApiDTOWithKeychain( keychain, apiDTO: dkData, forKey: kCoreSDKDataDk, passwordData: self.keychainPassword.data(using: String.Encoding.ascii)!)
        switch saveResult {
        case .success(_):
            break
        case .failure( let error ):
            clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWriting.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error while saving keychain DK data: %@", error )
        }
    }
    
    func saveEkDataSync(_ aesEncryptionKey : String?, ekData : KeychainEkDTO){
        // Save KeychainEkDTO ...
        if let password = aesEncryptionKey {
            let passwordData = password.sha1().data(using: String.Encoding.ascii)!
            if  self._keychainEkDTO == nil  {
                self._keychainEkDTO = KeychainEkDTO()
            }
            let keychain = Keychain( service: CoreSDKKeychainService )

            let saveResult   = self.saveApiDTOWithKeychain( keychain, apiDTO: ekData, forKey: kCoreSDKDataEk, passwordData: passwordData)
            switch saveResult {
            case .success(_):
                break
            case .failure( let error ):
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWriting.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error while saving keychain EK data: %@", error )
            }
        }
    }
    
    func loadEkDataSync(_ aesEncryptionKey : String?)
    {
        let keychain   = Keychain( service: CoreSDKKeychainService )
        
        do {
            // Load KeychainEkDTO ...
            if let password = aesEncryptionKey {
                self._keychainEkDTO            = try self.loadApiDTOWithKeychain( keychain, forKey: kCoreSDKDataEk, passwordData: password.sha1().data(using: String.Encoding.ascii)! )
                self._keychainEkDTOReadPending = false
            }
            else {
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainReading.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Missing AES Encryption Key." )
            }
        }
        catch let error {
            self._keychainEkDTO = nil
            
            if (error as? LockerError)?.kind == LockerErrorKind.protectedDataNotAvailable {
                self._keychainEkDTOReadPending = true
            }
            else {
                assert(false, "Unhandled error when reading keychain data: \(error.localizedDescription)")
            }
        }
        
        if ( self._keychainEkDTO == nil) {
            self._keychainEkDTO = KeychainEkDTO()
        }
    }
    
    fileprivate func wipeKeychainDataSyncAndReinitEmptyDTOs(){
        self.wipeKeychainDataSync()
        self._aesEncryptionKey = nil
        self._keychainEkDTO = KeychainEkDTO()
        self._keychainDkDTO = KeychainDkDTO()
    }
    
    
    
    func wipeKeychainDataSync(){
        let keychain = Keychain( service: CoreSDKKeychainService )
        var errorOccured = false
        do{
            
            do{
                try keychain.remove(kCoreSDKDataDk)
            } catch ( let error as NSError ) {
                errorOccured = true
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWiping.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error when wiping DkData: \(error)" )
            }
            do{
                try keychain.remove(kCoreSDKDataEk)
            } catch ( let error as NSError ) {
                errorOccured = true
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWiping.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error when wiping EkData: \(error)" )
            }
            do{
                try keychain.remove(kVendorIdentifierKey)
            } catch ( let error as NSError ) {
                errorOccured = true
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWiping.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error when wiping vendor identifier: \(error)" )
            }
            
            if ( errorOccured ) {
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWiping.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Locker keychain wiped with error(s)." )
            }
            else {
                clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.KeychainWiping.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Locker keychain successfully wiped." )
            }
        }

    }
    
    func saveKeychainData(_ encryptionKey : String?)
    {
        let ekData = KeychainEkDTO(source: self._keychainEkDTO)
        let dkData = KeychainDkDTO(source: self._keychainDkDTO)
        
        self.syncQueue.async(execute: {
            self.saveEkDataSync(encryptionKey, ekData: ekData)
            self.saveDkDataSync(dkData)
        })
    }
    
    func saveKeychainDataSync(_ encryptionKey : String?)
    {
        let ekData = KeychainEkDTO(source: self._keychainEkDTO)
        let dkData = KeychainDkDTO(source: self._keychainDkDTO)
        self.syncQueue.sync(execute: {
            self.saveEkDataSync(encryptionKey,ekData: ekData)
            self.saveDkDataSync(dkData)
        })
    }
    
    func lockUser()
    {
        self.aesEncryptionKey = nil
        self._keychainEkDTO = nil
        fireStatusChangeNotificationIfNeeded()
    }
    
    func unlockUser(_ aesEncryptionKey : String){
        self.aesEncryptionKey = aesEncryptionKey
        self.loadEkDataSync(aesEncryptionKey)
    }
    
    //--------------------------------------------------------------------------
    func vendorIdentifier() -> String
    {
        var result: String?
        let keychain = Keychain( service: CoreSDKKeychainService )
        
        self.propertyQueue.sync(execute: {
            do {
                result = try keychain.getString(kVendorIdentifierKey)
            }
            catch {}
            if ( result == nil ) {
                result = UIDevice.current.identifierForVendor!.uuidString
                do {
                    try keychain.set(result!, key: kVendorIdentifierKey)
                }
                catch ( let error as NSError ) {
                    clog( CoreSDK.ModuleName, activityName: CoreSDKActivities.VendorInfo.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Error when storing vendor identifier: \(error)" )
                }
            }
        })
        
        if let identifier = result {
            return identifier
        }
        else {
            assert( false, "Fatal error when vendor identifier form keychain." )
            return "emptyVendorIdentifier"
        }

    }

    //--------------------------------------------------------------------------
    func keychainPasswordKey() -> String
    {
        return self.vendorIdentifier().sha1()
    }

    func unregisterUser()
    {
        syncQueue.sync { 
            self.wipeKeychainDataSyncAndReinitEmptyDTOs()
        }
        fireStatusChangeNotificationIfNeeded()
    }
    

    
    func generateSecretData() -> Data
    {
        if self.fixedSessionSecretData != nil {
            return self.fixedSessionSecretData!
        } else {
            let (_, secData) = WebServiceUtils.generateSEK()
            return secData as Data
        }
    }
    
    fileprivate var lastNotificationState : LockStatus? = nil
    
    func fireStatusChangeNotificationIfNeeded()
    {
        if self.lastNotificationState != self.lockStatus && self.lastNotificationState != nil {
            clog(Locker.ModuleName, activityName: self.lockStatus.toActivityName(), fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Locker state changed from %@ to %@.", self.lastNotificationState!.toActivityName(), self.lockStatus.toActivityName() );
            NotificationCenter.default.post( name: Notification.Name(rawValue: Locker.UserStateChangedNotification), object: nil )
        }
        self.lastNotificationState = self.lockStatus
    }
    
}
