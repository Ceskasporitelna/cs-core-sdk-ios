//
//  SigningError.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 21/05/16.
//  Copyright © 2016 Applifting. All rights reserved.
//

import Foundation


public enum SigningErrorKind : Int
{
    /**
     This entity cannot be signed due to missing valid sign info
     */
    case unsignableEntity                         = 11000
    
    /**
     Signing was attempted by unsupported authorization type
     */
    case invalidAuthorizationType                 = 11001
    
    /**
     * The provided signId doesn't exist.
     */
    case idNotFound                               = 11002
    
    /**
     * The requested resource is in a state that can not be signed (either not 
     * yet ready, or already signed).
     */
    case notSignable                              = 11003
    
    /**
     * This resource can not be signed using selected authorization method 
     * right now as the (daily/transaction) limit for this method has been already reached.
     */
    case authLimitExceeded                        = 11004
    
    /**
     * There is no authorization method available for this order.
     */
    case noAuthAvailable                          = 11005
    
    /**
     * There is already one sign process in progress.
     */
    case czSignInProgress                         = 11006
    
    /**
     * OTP could not be provided due to local technical issues.
     */
    case otpNotProvided                           = 11007
    
    /**
     * Request for new OTP is not allowed, because previous generated OTP is 
     * still valid and there is restricted time slot before generation of the next OTP.
     */
    case otpRequestNotAllowed                     = 11008
    
    /**
     * Authorization method is locked due to all user allowed attempts to enter 
     * valid OTP failed. User can start signing again and select other authorization method.
     */
    case authMethodLocked                         = 11009
    
    /**
     * The provided OTP is not valid for the given signId.
     */
    case otpInvalid                               = 11010
    
    /**
     * The provided OTP has already expired for the given signId.
     */
    case otpExpired                               = 11011
    
    /**
     * The previous OTPs were wrong, only one attempt remains. 
     * This code will be provided in addition to otpInvalid
     */
    case oneAttemptLeft                           = 11012
    
    /**
     * All allowed attempts failed. User is now blocked. This code will be provided 
     * in addition to tacInvalid.
     */
    case userLocked                               = 11013
    
    /**
     * Offline mobile authorization method is locked due to all user allowed 
     * attempts to enter valid OTP failed. User can start signing again and 
     * select other authorization method. This code will be provided 
     * in addition to otpInvalid.
     */
    case authMethodOfflineLocked                  = 11014
    
    /**
     * Signing process was successful but BE system refused to process order 
     * (validation error or something).
     */
    case czOrderRefused                           = 11015
    
    /**
     * Signing process was successful but BE haven't responded in time thus we 
     * do not know whether order was processed or not.
     */
    case czOrderDeliverationUncertain             = 11016
    
    /**
     * Amount to be transferred is higher than current disposable balance on the account.
     */
    case czInsuficcientBalance                    = 11017
    
    /**
     * Phone number is blocked.
     */
    case czPhoneNumberBlocked                     = 11018
    
    /**
     * Wrong interface.
     */
    case czThirdPartyError                        = 11019
    
    /**
     * Decline due to other reasons.
     */
    case czThirdPartyUnavailable                  = 11020
    
    /**
     * Mismatch of invoice and phone number.
     */
    case czInvoicePhoneNumberMismatch             = 11021
    
    /**
     * Daily limit reached.
     */
    case limitExceeded                            = 11022
    
    /**
     * Monthly limit reached.
     */
    case czMonthlyLimitExceeded                   = 11023
    
    /**
     * The provided hash no longer fits to the content of the resource.
     */
    case hashMismatch                             = 11024
    
    /**
     * Invalid field.
     */
    case fieldInvalid                             = 11025
    
    /**
     Signing failed from other reasons (Network, etc...)
     */
    case other                                    = 11999
}

/**
 Error class for errors that can happen during the signing
 */
public class SigningError : CSErrorBase
{
    override class public var ERROR_DOMAIN : String {
        return "cz.csas.signing"
    }
    
    public var kind : SigningErrorKind {
        if let kind = SigningErrorKind(rawValue: self.code){
            return kind
        }
        return SigningErrorKind.other
    }
    
    /*
     * Can contain dictionary with server error info
     */
    public var serverErrorInfo: [String:AnyObject]?
    
    override class public var locatizationDictionary : [Int:String] {
        return _errorDictionary
    }
    
    fileprivate static let _errorDictionary: [Int:String] = [
        SigningErrorKind.other.rawValue:                         CoreSDK.localized( "err-other" ),
        SigningErrorKind.unsignableEntity.rawValue:              "This entity cannot be signed due to missing valid sign info.",
        SigningErrorKind.invalidAuthorizationType.rawValue:      "Signing was attempted by unsupported authorization type.",
        SigningErrorKind.idNotFound.rawValue:                    "The provided signId doesn't exist.",
        SigningErrorKind.notSignable.rawValue:                   "The requested resource is in a state that can not be signed (either not yet ready, or already signed).",
        SigningErrorKind.authLimitExceeded.rawValue:             "This resource can not be signed using selected authorization method right now as the (daily/transaction) limit for this method has been already reached.",
        SigningErrorKind.noAuthAvailable.rawValue:               "There is no authorization method available for this order.",
        SigningErrorKind.czSignInProgress.rawValue:              "There is already one sign process in progress.",
        SigningErrorKind.otpNotProvided.rawValue:                "OTP could not be provided due to local technical issues.",
        SigningErrorKind.otpRequestNotAllowed.rawValue:          "Request for new OTP is not allowed, because previous generated OTP is still valid and there is restricted time slot before generation of the next OTP.",
        SigningErrorKind.authMethodLocked.rawValue:              "Authorization method is locked due to all user allowed attempts to enter valid OTP failed. User can start signing again and select other authorization method.",
        SigningErrorKind.otpInvalid.rawValue:                    "The provided OTP is not valid for the given signId.",
        SigningErrorKind.otpExpired.rawValue:                    "The provided OTP has already expired for the given signId.",
        SigningErrorKind.oneAttemptLeft.rawValue:                "The previous OTPs were wrong, only one attempt remains. This code will be provided in addition to otpInvalid.",
        SigningErrorKind.userLocked.rawValue:                    "All allowed attempts failed. User is now blocked. This code will be provided in addition to tacInvalid.",
        SigningErrorKind.authMethodOfflineLocked.rawValue:       "Offline mobile authorization method is locked due to all user allowed attempts to enter valid OTP failed. User can start signing again and select other authorization method. This code will be provided in addition to otpInvalid.",
        SigningErrorKind.czOrderRefused.rawValue:                "Signing process was successful but BE system refused to process order (validation error or something).",
        SigningErrorKind.czOrderDeliverationUncertain.rawValue:  "Signing process was successful but BE haven't responded in time thus we do not know whether order was processed or not.",
        SigningErrorKind.czInsuficcientBalance.rawValue:         "Amount to be transferred is higher than current disposable balance on the account.",
        SigningErrorKind.czPhoneNumberBlocked.rawValue:          "Phone number is blocked.",
        SigningErrorKind.czThirdPartyError.rawValue:             "Wrong interface.",
        SigningErrorKind.czThirdPartyUnavailable.rawValue:       "Decline due to other reasons.",
        SigningErrorKind.czInvoicePhoneNumberMismatch.rawValue:  "Mismatch of invoice and phone number.",
        SigningErrorKind.limitExceeded.rawValue:                 "Daily limit reached.",
        SigningErrorKind.czMonthlyLimitExceeded.rawValue:        "Monthly limit reached.",
        SigningErrorKind.hashMismatch.rawValue:                  "The provided hash no longer fits to the content of the resource.",
        SigningErrorKind.fieldInvalid.rawValue:                  "Invalid field."
    ]
    
    //--------------------------------------------------------------------------
    public class func isError( _ error: NSError, ofKind kind: SigningErrorKind ) -> Bool
    {
        return ( error is SigningError && ( error as! SigningError ).kind == kind )
    }
    
    //--------------------------------------------------------------------------
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder )
    }
    
    public override init(domain errorDomain: String, code errorCode: Int, userInfo dict: [AnyHashable: Any]?)
    {
        super.init( domain:errorDomain, code:errorCode, userInfo:dict as [NSObject : AnyObject]? )
    }
    
    
    //--------------------------------------------------------------------------
    class public func errorOfKind( _ kind: SigningErrorKind ) -> SigningError
    {
        return SigningError(domain: CoreSDKError.ERROR_DOMAIN, code: kind.rawValue, userInfo: nil)
    }
    
    //--------------------------------------------------------------------------
    class func fromOtherError(_ error : NSError) -> SigningError
    {
        return SigningError(domain: SigningError.ERROR_DOMAIN, code: SigningErrorKind.other.rawValue, userInfo: error.userInfo)
    }
    
    //--------------------------------------------------------------------------
    class public func fromServer( description: String ) -> SigningError
    {
        switch description {
        case "ID_NOT_FOUND":
            return errorOfKind(.idNotFound)
        case "NOT_SIGNABLE":
            return errorOfKind(.notSignable)
        case "AUTH_LIMIT_EXCEEDED":
            return errorOfKind(.authLimitExceeded)
        case "NO_AUTH_AVAILABLE":
            return errorOfKind(.noAuthAvailable)
        case "CZ-SIGN_IN_PROGRESS":
            return errorOfKind(.czSignInProgress)
        case "OTP_NOT_PROVIDED":
            return errorOfKind(.otpNotProvided)
        case "OTP_REQUEST_NOT_ALLOWED":
            return errorOfKind(.otpRequestNotAllowed)
        case "AUTH_METHOD_LOCKED":
            return errorOfKind(.authMethodLocked)
        case "OTP_INVALID":
            return errorOfKind(.otpInvalid)
        case "OTP_EXPIRED":
            return errorOfKind(.otpExpired)
        case "ONE_ATTEMPT_LEFT":
            return errorOfKind(.oneAttemptLeft)
        case "USER_LOCKED":
            return errorOfKind(.userLocked)
        case "AUTH_METHOD_OFFLINE_LOCKED":
            return errorOfKind(.authMethodOfflineLocked)
        case "CZ-ORDER_REFUSED":
            return errorOfKind(.czOrderRefused)
        case "CZ-ORDER_DELIVERATION_UNCERTAIN":
            return errorOfKind(.czOrderDeliverationUncertain)
        case "CZ-INSUFFICIENT_BALANCE":
            return errorOfKind(.czInsuficcientBalance)
        case "CZ-PHONE_NUMBER_BLOCKED":
            return errorOfKind(.czPhoneNumberBlocked)
        case "CZ-THIRD_PARTY_ERROR":
            return errorOfKind(.czThirdPartyError)
        case "CZ-THIRD_PARTY_UNAVAILABLE":
            return errorOfKind(.czThirdPartyUnavailable)
        case "CZ-INVOICE_PHONE_NUMBER_MISMATCH":
            return errorOfKind(.czInvoicePhoneNumberMismatch)
        case "LIMIT_EXCEEDED":
            return errorOfKind(.limitExceeded)
        case "CZ-MONTHLY_LIMIT_EXCEEDED":
            return errorOfKind(.czMonthlyLimitExceeded)
        case "CZ-THIRD_PARTY_ERROR":
            return errorOfKind(.czThirdPartyError)
        case "HASH_MISMATCH":
            return errorOfKind(.hashMismatch)
        case "FIELD_INVALID":
            return errorOfKind(.fieldInvalid)
        default:
            return errorOfKind(.other)
        }
    }
    
    
}
