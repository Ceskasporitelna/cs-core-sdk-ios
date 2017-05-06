//
//  Signer.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 20/04/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation

/**
 * Signer log activities.
 */
//==============================================================================
internal enum SignerActivities: String {
    case GetSigningInfo              = "GetSigningInfo"
    case SigningWithTAC              = "SigningWithTAC"
    case SigningWithNoAuthorization  = "SigningWithNoAuthorization"
}


/**
 Signer can be used to sign orders by TAC or NO_AUTHORIZATION methods 
 */
public class Signer
{
    fileprivate static let ModuleName      = "Signer"
    
    let signUrl : String
    let signId : String
    let client : WebApiClient
    
    /**
     Instantiates the Signer using the necesarry information for signing particular order
     
     - parameter signUrl: Signing url WITHOUT the `/sign/{id}` part - URL where the order can be signed.
     - parameter signId: Signing id for this order
     - parameter client: `WebApiClient` used to do the signing
     */
    init(signUrl : String, signId : String, client : WebApiClient){
        self.signUrl = signUrl
        self.client = client
        self.signId = signId
    }
    
    
    /**
     Instantiates the Signer using the necesarry information for signing particular order
     
     - parameter signable: A Signable object from which to extract signUrl and signId
     - parameter client: `WebApiClient` used to do the signing
     */
    init?(signable : Signable, client : WebApiClient){
        self.client = client
        self.signUrl = signable.signUrl
        if let signId = signable.signing?.signId{
            self.signId = signId
        }else{
            return nil
        }
    }
    
    /**
     Obtains current signing info with full details from the API.
     
     - parameter callback: called with `FilledSigningObject` returned from API
     
    */
    public func getSigningInfo(_ callback:@escaping (_ result:CoreResult<FilledSigningObject>)->Void)
    {
        self.client.callApi(composeSignUrl(self.signUrl, signId: signId), method: Method.GET, headers: nil) { ( originalResult : ApiCallResult<FilledSignInfoDTO>) -> Void in
            let result = self.defaultTransform(originalResult)
            switch result {
            case .success(let filledInfoDto, _):
                if let filledSigningObject = self.signInfoFromDto(filledInfoDto){
                    clog(Signer.ModuleName, activityName: SignerActivities.GetSigningInfo.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Getting signing info successfull." );
                    callback(CoreResult<FilledSigningObject>.success(filledSigningObject))
                }
                else {
                    let error = SigningError.errorOfKind(SigningErrorKind.unsignableEntity)
                    clog(Signer.ModuleName, activityName: SignerActivities.GetSigningInfo.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Getting signing info error: ", error.localizedDescription );
                    callback(CoreResult<FilledSigningObject>.failure(error))
                    return
                }
                break
                
            case .failure(let error, _):
                clog(Signer.ModuleName, activityName: SignerActivities.GetSigningInfo.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Getting signing info error: ", error.localizedDescription );
                callback(CoreResult<FilledSigningObject>.failure(error))
            }
        }
    }
    
    
    /**
     Starts signing process with TAC (that usually means signing using OneTimePassword from SMS)
     
     This method will inform the API that the client will sign using TAC.
     
     - parameter callback: called with `TACSigningProcess` that can be used to finish the signing or `SigningError` if the call fails
     
     */
    public func startSigningWithTAC( _ callback:@escaping (_ result:CoreResult<TACSigningProcess>)->Void)
    {
        let request = InitializeSigningRequest()
        request.authorizationType = AuthorizationType.TAC.rawValue
        self.client.callApi(composeSignUrl(self.signUrl, signId: signId), method: Method.POST, payload:request, headers: nil) { ( originalResult : ApiCallResult<FilledSignInfoDTO>) -> Void in
            let result = self.defaultTransform(originalResult)
            switch result  {
                case .success(let filledInfoDto, _):
                if let signInfo = self.basicSignInfoFromDto(filledInfoDto){
                    let tacProcess = TACSigningProcess(signingInfo: signInfo)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Start signing with TAC successfull." );
                    callback(CoreResult<TACSigningProcess>.success(tacProcess))
                }
                else {
                    let error = SigningError.errorOfKind(SigningErrorKind.unsignableEntity)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Start signing with TAC error: ", error.localizedDescription );
                    callback(CoreResult<TACSigningProcess>.failure(error))
                    return
                }
                
            case .failure(let error, _):
                clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Start signing with TAC error: ", error.localizedDescription );
                callback(CoreResult<TACSigningProcess>.failure(error))
            }
        }
    }
    
    
    /**
     Finishes signing process with TAC (that usually means signing using OneTimePassword from SMS)
     
     It takes the `oneTimePassword` from the client and sends it to API to finish the TAC signing.
     
    You can call this method only if you successfully called `startSigningWithTAC` before.
     
     - parameter oneTimePassword: One time password obtained from SMS or other means
     - parameter callback: called with `SigningObject` returned from API. Its state will be DONE if the order was signed, the state will be public if more signing is required or `SigningError` if the call fails
     
     */
    public func finishSigningWithTAC(_ oneTimePassword : String, callback:@escaping (_ result:CoreResult<SigningObject>)->Void)
    {
        let request = FinalizeTACSigningRequest()
        request.authorizationType = AuthorizationType.TAC.rawValue
        request.oneTimePassword = oneTimePassword
        self.client.callApi(composeSignUrl(self.signUrl, signId: signId), method: Method.PUT, payload:request, headers: nil) { ( originalResult : ApiCallResult<FilledSignInfoDTO>) -> Void in
            let result = self.defaultTransform(originalResult)
            switch result {
            case .success(let filledInfoDto, _):
                if let signInfo = self.basicSignInfoFromDto(filledInfoDto){
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Finishing signing with TAC successfull." )
                    callback(CoreResult<SigningObject>.success(signInfo))
                }
                else {
                    let error = SigningError.errorOfKind(SigningErrorKind.unsignableEntity)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Finishing signing with TAC error: ", error.localizedDescription )
                    callback(CoreResult<SigningObject>.failure(error))
                    return
                }
                
            case .failure(let error, _):
                clog(Signer.ModuleName, activityName: SignerActivities.SigningWithTAC.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Finishing signing with TAC error: ", error.localizedDescription )
                callback(CoreResult<SigningObject>.failure(error))
            }
        }
    }
    
    
    /**
     Starts signing process with NO_AUTHORIZATION (that usually means signing the order just by clicking some button in UI)
     
     This method signalizes the intent to the API that this order will be signed using NO_AUTHORIZATION method
     
     - parameter callback: called with `NoAuthorizationSigningProcess` that can be used to finish the signing or `SigningError` if the call fails
     
     */
    public func startSigningWithNoAuthorization(_ callback:@escaping (_ result:CoreResult<NoAuthorizationSigningProcess>) -> Void)
    {
        let request = InitializeSigningRequest()
        request.authorizationType = AuthorizationType.NoAuthorization.rawValue
        self.client.callApi(composeSignUrl(self.signUrl, signId: signId), method: Method.POST, payload:request, headers: nil) { ( originalResult : ApiCallResult<FilledSignInfoDTO>) -> Void in
            let result = self.defaultTransform(originalResult)
            switch result {
            case .success(let filledInfoDto, _):
                if let signInfo = self.basicSignInfoFromDto(filledInfoDto){
                    let noAutProcess = NoAuthorizationSigningProcess(signingInfo: signInfo)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Start signing with no authorization successfull." )
                    callback(CoreResult<NoAuthorizationSigningProcess>.success(noAutProcess))
                }
                else {
                    let error = SigningError.errorOfKind(SigningErrorKind.unsignableEntity)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Start signing with no authorization error: ", error.localizedDescription )
                    callback(CoreResult<NoAuthorizationSigningProcess>.failure(error))
                    return
                }
                
            case .failure(let error, _):
                clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Start signing with no authorization error: ", error.localizedDescription )
                callback(CoreResult<NoAuthorizationSigningProcess>.failure(error))
            }
        }
    }
    
    
    /**
     Finishes signing process using NO_AUTHORIZATION method
     
     This method signalizes the API that the user confirmed signing the order by consent (usually by clicking some button in the UI).
     
     You can call this method only if you successfully called `startSigningWithNoAuthorization` before.
     
     - parameter callback: called with `SigningObject` returned from API. Its state will be DONE if the order was signed, the state will be public if more signing is required or `SigningError` if the call fails
     
     */
    public func finishSigningWithNoAuthorization(_ callback:@escaping (_ result:CoreResult<SigningObject>)->Void)
    {
        let request = InitializeSigningRequest()
        request.authorizationType = AuthorizationType.NoAuthorization.rawValue
        self.client.callApi(composeSignUrl(self.signUrl, signId: signId), method: Method.PUT, payload:request, headers: nil) { ( originalResult : ApiCallResult<FilledSignInfoDTO>) -> Void in
            let result = self.defaultTransform(originalResult)
            switch result {
            case .success(let filledInfoDto, _):
                if let signInfo = self.basicSignInfoFromDto(filledInfoDto){
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.info, format: "Finishing signing with no authorization successfull." )
                    callback(CoreResult<SigningObject>.success(signInfo))
                }
                else {
                    let error = SigningError.errorOfKind(SigningErrorKind.unsignableEntity)
                    clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Finishing signing with no authorization error: ", error.localizedDescription )
                    callback(CoreResult<SigningObject>.failure(error))
                    return
                }
            case .failure(let error, _):
                clog(Signer.ModuleName, activityName: SignerActivities.SigningWithNoAuthorization.rawValue, fileName: #file, functionName: #function, lineNumber: #line, logLevel: LogLevel.error, format: "Finishing signing with no authorization error: ", error.localizedDescription )
                callback(CoreResult<SigningObject>.failure(error))
            }
        }
    }
    
    
    fileprivate func signInfoFromDto(_ dto : FilledSignInfoDTO) -> FilledSigningObject?
    {
        guard let state = dto.stateEnum else{
            return nil
        }
        let filledSigningObject = FilledSigningObject(signId : dto.signId, state:state, authorizationType : dto.authorizationTypeEnum, signer: self)
        filledSigningObject.scenarios = dto.scenariosEnums
        return filledSigningObject
    }
    
    fileprivate func basicSignInfoFromDto(_ dto : FilledSignInfoDTO) -> SigningObject?
    {
        guard let state = dto.stateEnum else{
            return nil
        }
        return SigningObject(signId: self.signId, state: state, signer: self)
    }
    
    fileprivate func composeSignUrl(_ baseUrl : String, signId : String) -> String
    {
        var url : String = baseUrl
        if(!baseUrl.hasSuffix("/sign")){
            url = "\(baseUrl)/sign"
        }
        return "\(url)/\(signId)"
    }
    
    //--------------------------------------------------------------------------
    fileprivate func defaultTransform<TResponse:WebApiEntity>(_ result:ApiCallResult<TResponse>) -> ApiCallResult<TResponse>
    {
        switch result {
        case .failure(let (error,response)):
            if let responseData = response.data {
                if let _ = responseData.count {
                    let coreError = CoreSDKError.errorWithCode(error.code, underlyingError: error)!
                    
                    if let responseArray = responseData as? [String:AnyObject] {
                        if let serverErrorDescription = CSErrorBase.serverErrorDescriptor(responseData: responseData) {
                            let signingError = SigningError.fromServer(description: serverErrorDescription)
                            if ( signingError.kind == .other ) {
                                signingError.serverErrorInfo = responseArray
                            }
                            return ApiCallResult.failure(signingError, response)
                        }
                        
                        coreError.serverErrorInfo = (responseData as! [String:AnyObject])
                        return ApiCallResult.failure(SigningError.fromOtherError(coreError), response)
                    }
                    else if ( responseData is [AnyObject] ) {
                        coreError.serverErrorInfo = ["root":responseData as! [AnyObject] as AnyObject]
                        return ApiCallResult.failure(SigningError.fromOtherError(coreError), response)
                    }
                    else {
                        if let errorString = String(data: responseData as! Data, encoding: String.Encoding.utf8) {
                            coreError.serverErrorInfo = ["error":errorString as AnyObject]
                            return ApiCallResult.failure(SigningError.fromOtherError(coreError), response)
                        }
                    }
                }
            }
            else {
                return ApiCallResult.failure(SigningError.fromOtherError(error), response)
            }
            
        default:
            break
        }
        
        return result
    }
    
}
