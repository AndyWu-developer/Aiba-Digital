//
//  AuthError.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/27.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import AuthenticationServices

enum AuthError: Error, LocalizedError, Equatable{

    case phoneSignInError(String)
    case googleSignInError(String)
    case appleSignInError(String)
    case firebaseError(String)
    case userCanceledSignIn
    case signOutError(String)

    init(_ errorMesssage: String){
        self = .googleSignInError(errorMesssage)
    }
    
    init(_ error: Error) {
        if let googleError = error as? GIDSignInError{
            //https://developers.google.com/identity/sign-in/ios/reference/Enums/GIDSignInErrorCode
            switch googleError.code {
            case .canceled:
                self = .userCanceledSignIn
            default:
                self = .googleSignInError(googleError.localizedDescription)
            }
        }else if let appleError = error as? ASAuthorizationError{
            //https://developer.apple.com/documentation/authenticationservices/asauthorizationerror/code
            switch appleError.code {
            case .canceled:
                self = .userCanceledSignIn
            default:
                self = .appleSignInError("Other apple error")
            }
        }else if let firebaseErrorCode = AuthErrorCode.Code(rawValue: error._code){
            print("Firebase Error")
            if let e = (error as NSError) as? AuthErrorCode{
                print(e.userInfo["NSLocalizedDescription"])
                print(e.userInfo["FIRAuthErrorUserInfoNameKey"])
               
            }
            switch firebaseErrorCode {

            case .invalidPhoneNumber:
                self = .phoneSignInError("無效的手機號碼")
            case .invalidVerificationCode:
                self = .phoneSignInError("驗證碼錯誤")
            case .networkError:
                self = .phoneSignInError("網路發生問題\n請確認網路連線後再試一次")
            case .sessionExpired:
                self = .phoneSignInError("手機號碼或驗證碼不正確")
            case .tooManyRequests:
                self = .phoneSignInError("系統繁忙，請稍候再試")
            case .quotaExceeded:
                self = .phoneSignInError("驗證次數已達上限\n請於明天再試一次")
            default:
                self = .phoneSignInError("系統未知錯誤，請聯繫客服\n04-23272366")
            }
        }
        
        else{
            print("the login error could not be matched with a firebase code")
            self = .googleSignInError("Unknown error")
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case let .phoneSignInError(message):
            return NSLocalizedString(message, comment: "googleSignInError")
        case let .googleSignInError(message):
            return NSLocalizedString(message, comment: "My error")
        case let .appleSignInError(message):
            return NSLocalizedString(message, comment: "My error")
        case let .signOutError(message):
            return NSLocalizedString(message, comment: "My error")
        case .userCanceledSignIn :
            return NSLocalizedString("User canceled sign-in", comment: "My error")
        case let .firebaseError(message):
            return NSLocalizedString(message, comment: "My error")
        }
    }
    
}

