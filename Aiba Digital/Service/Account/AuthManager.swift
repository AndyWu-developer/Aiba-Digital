//
//  AuthManager.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/16.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit


protocol AuthManaging {
    func isUserLoggedIn() -> Bool
    func sendVerificationCode(phoneNumber: String) -> AnyPublisher<Bool,AuthError>
    func signInWithPhone(verificationCode: String) -> AnyPublisher<Bool,AuthError>
    func signInWithApple() -> AnyPublisher<Bool,AuthError>
    func signInWithGoogle() -> AnyPublisher<Bool,AuthError>
    func signOut() -> AnyPublisher<Void,AuthError>
}


class AuthManager: NSObject, AuthManaging {
    
    private(set) var user: User?
    
    private var subscriptions = Set<AnyCancellable>()
    private var currentNonce: String?  // Unhashed nonce for apple sign-in
    private var appleLoginSuccessPublisher: PassthroughSubject<Bool,AuthError>?
    
    override init(){
        super.init()
        Auth.auth().languageCode = "zh_tw"
        print("FirebaseAuthManager init")
        AuthStateChangePublisher().sink { [unowned self] user in
            self.user = user
        }.store(in: &subscriptions)
    }
    
    func isUserLoggedIn() -> Bool{
        return user != nil
    }

    func sendVerificationCode(phoneNumber: String) -> AnyPublisher<Bool,AuthError>{
        Future<Bool,AuthError>{ promise in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                  if let error = error {
                      promise(.failure(AuthError(error)))
                  }else{
                      UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                      promise(.success(true))
                  }
            }
        }.eraseToAnyPublisher()
    }
  
    func signInWithPhone(verificationCode: String) -> AnyPublisher<Bool,AuthError> {
        Future<Bool,AuthError> { promise in
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")!
            let credential = PhoneAuthProvider.provider().credential(
              withVerificationID: verificationID,
              verificationCode: verificationCode
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    promise(.failure(AuthError(error)))
                }else{
                    promise(.success(true))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signInWithGoogle() -> AnyPublisher<Bool,AuthError> {
        Future<Bool,AuthError> { promise in
//            // Create Google Sign In configuration object
            let clientID = FirebaseApp.app()!.options.clientID!
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            let rootVC = UIApplication.shared.windows.first!.rootViewController!
            
            
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [unowned self] result, error in
                guard error == nil else {
                    promise(.failure(AuthError(error!)))
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                   promise(.failure(AuthError(error!)))
                   return // ...
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                Auth.auth().signIn(with: credential){ authResult, error in
                    if let error = error {
                        promise(.failure(AuthError(error)))
                    }else{
                        promise(.success(true))
                    }
                }
            }
              // ...
//            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
//                if let error = error {
//                    promise(.failure(AuthError(error)))
//                    return
//                }
//                let credential = GoogleAuthProvider.credential(withIDToken: user!.authentication.idToken!, accessToken: user!.authentication.accessToken)
//                Auth.auth().signIn(with: credential){ authResult, error in
//                    if let error = error {
//                        promise(.failure(AuthError(error)))
//                    }else{
//                        promise(.success(true))
//                    }
//                }
//            }
        }.eraseToAnyPublisher()
    }
    
    @available(iOS 13, *)
    func signInWithApple() -> AnyPublisher<Bool,AuthError> {
        currentNonce = randomNonceString()
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
      
        appleLoginSuccessPublisher = PassthroughSubject<Bool,AuthError>()
        return appleLoginSuccessPublisher!.eraseToAnyPublisher()
    }
    
    //For every sign-in request, generate a random string—a "nonce"—which you will use to make sure the ID token you get was granted specifically in response to your app's authentication request. This step is important to prevent replay attacks.
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {String(format: "%02x", $0)}.joined()
        return hashString
    }
    
    func signOut() -> AnyPublisher<Void, AuthError> {
        Future<Void,AuthError>{ promise in
            do{
                try Auth.auth().signOut()
                promise(.success(()))
            }catch{
             //  print("Error signing out: %@", signOutError)
                promise(.failure(error as! AuthError))
            }
        }.eraseToAnyPublisher()
    }
    
    deinit{
        print("FirebaseAuthManager deinit")
    }
}

@available(iOS 13.0, *)

extension AuthManager: ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            appleLoginSuccessPublisher?.send(completion: .failure(AuthError.appleSignInError("Unable to fetch identity token")))
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleLoginSuccessPublisher?.send(completion: .failure(AuthError.appleSignInError("Unable to serialize token string from data: \(appleIDToken.debugDescription)")))
            return
        }
      
        let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                //If error.code == .MissingOrInvalidNonce, make sure you're sending the SHA256-hashed nonce as a hex string with your request to Apple.
                self.appleLoginSuccessPublisher?.send(completion: .failure(AuthError(error)))
            }else{
                self.appleLoginSuccessPublisher?.send(true)
            }
        }
      }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleLoginSuccessPublisher?.send(completion: .failure(AuthError(error)))
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
}
