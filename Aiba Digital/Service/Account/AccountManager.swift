//
//  UserManager.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/7/6.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import LineSDK



protocol AccountManaging: AnyObject {
    var currentMember: Member? { get }
    func sendSMS(phoneNumber: String) async throws
    func signInWithPhone(verificationCode: String) async -> Result<Member,Error>
    func signInWithGoogle() async -> Result<Member,Error>
    func signInWithApple() async -> Result<Member,Error>
    func signOut() throws
    func deleteAccount() async throws
    func debug()
}

class AccountManager: NSObject, AccountManaging {

    private(set) var currentMember: Member?
    
    // MARK: - Firebase Auth References
    private var authStateHandler: AuthStateDidChangeListenerHandle!
    private var appleSignInNonce: String?  // Unhashed nonce for apple sign-in
    private var appleSignInContinuation: CheckedContinuation<AuthCredential,Error>!
    var provider = OAuthProvider(providerID: "oidc.line")
    
    // MARK: - FireStore References
    private let db = Firestore.firestore()
    private lazy var userCollectionRef = db.collection("members")
    
    override init(){
        super.init()
        Auth.auth().useAppLanguage()
        authStateHandler = Auth.auth().addStateDidChangeListener{ [unowned self] auth, user in
            if let user = user {
                Task{
                    currentMember = try await getExistingMember(from: user, source: .default)
                }
            }else{
                currentMember = nil
            }
        }
    }
    
    deinit{
        print("AccountManager deinit")
    }
    
    func sendSMS(phoneNumber: String) async throws {
        try await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<Void, Error>) in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }else{
                    UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    continuation.resume()
                }
            }
        }
    }
    
    func signInWithPhone(verificationCode: String) async -> Result<Member,Error> {
        do{
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")!
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                    verificationCode: verificationCode)
            let member = try await signIn(with: credential)
            return .success(member)
        }catch{
            return .failure(error)
        }
    }
    
    func signInWithGoogle() async -> Result<Member,Error> {
        do{
            let credential = try await getGoogleSignInCredential()
            let member = try await signIn(with: credential)
            return .success(member)
        }catch{
            return .failure(error)
        }
    }

    func signInWithApple() async -> Result<Member,Error> {
        do{
            let credential = try await getAppleSignInCredential()
            let member = try await signIn(with: credential)
            return .success(member)
        }catch{
            return .failure(error)
        }
    }
    
    func signInWithLine() async -> Result<Member,Error> {
        do{
            let credential = try await getLineSignInCredential()
            let member = try await signIn(with: credential)
            return .success(member)
        }catch{
            return .failure(error)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        
    }
    
    func debug(){
        print("Hi")
        Task{
            let member = await signInWithLine()
            print(member)
        }
    }
    
    @MainActor
    private func getGoogleSignInCredential() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation{ continuation in
            let clientID = FirebaseApp.app()!.options.clientID!
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            let rootVC = UIApplication.shared.windows.first!.rootViewController!
            GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let idToken = result?.user.idToken?.tokenString,
                    let accessToken = result?.user.accessToken.tokenString {
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: accessToken)
                    continuation.resume(returning: credential)
                }else{
                    continuation.resume(throwing: AccountManagerError.loginError)
                }
            }
        }
    }
    
    private func getAppleSignInCredential() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation{ continuation in
            appleSignInContinuation = continuation
            appleSignInNonce = randomNonceString()
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(appleSignInNonce!)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    @MainActor
    private func getLineSignInCredential() async throws -> AuthCredential{
       
        try await withCheckedThrowingContinuation{ continuation in
            let rootVC = UIApplication.shared.windows.first!.rootViewController!
            LoginManager.shared.login(permissions: [.openID], in: rootVC){ result in
                do{
                    
                    let r = try result.get()
                    let accessToken = try result.get().accessToken.value
                    let idToken = try result.get().accessToken.IDToken
                    
                    let nonce = try result.get().IDTokenNonce
                    //print(idToken)
                    let credential = OAuthProvider.credential(withProviderID: "oidc.line",accessToken: accessToken)
                    continuation.resume(returning: credential)
                }catch{
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    private func signIn(with credential: AuthCredential) async throws -> Member {
        let result = try await signInWithFirebase(credential: credential)
        let user = result.user
    
        if let existingMember = try? await getExistingMember(from: user, source: .server){
            return existingMember
        }else{
            let newMember = try await createNewMember(from: user)
            return newMember
        }
    }
    
    private func signInWithFirebase(credential: AuthCredential) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation{ continuation in
            Auth.auth().signIn(with: credential){ authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(returning: authResult!)
                }
            }
        }
    }
    
    private func createNewMember(from user: FirebaseAuth.User) async throws -> Member {
        try await withCheckedThrowingContinuation{ continuation in
            // Create new member
            let newMember = Member(id: user.uid, displayName: user.displayName, phoneNumber: user.phoneNumber, email: user.email, photoURL: user.photoURL)
            // Get new write batch
            let batch = db.batch()
            do{
                try batch.setData(from: newMember, forDocument: userCollectionRef.document(newMember.id))
            }catch{
                print("Unable to encode Memeber to Firestore Data")
                continuation.resume(throwing: error)
            }
            // Commit the batch
            batch.commit(){ error in
                if let error = error{
                    print("Error writing batch \(error)")
                    continuation.resume(throwing: AccountManagerError.cannotCreateMember)
                }else{
                    print("Batch write succeeded")
                    continuation.resume(returning: newMember)
                }
            }
        }
    }
   
    private func getExistingMember(from user: FirebaseAuth.User, source: FirestoreSource) async throws -> Member {
        try await withCheckedThrowingContinuation{ continuation in
            userCollectionRef.document(user.uid).getDocument(source: source) { document, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let document = document, document.exists else {
                    continuation.resume(throwing: AccountManagerError.memberNotFound)
                    return
                }
                
                continuation.resume(with: Result{ try document.data(as: Member.self) })
            }
        }
    }
    
}


extension AccountManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleSignInContinuation.resume(throwing: AccountManagerError.loginError)
            return
        }
        
        guard let nonce = appleSignInNonce else {
            appleSignInContinuation.resume(throwing: AccountManagerError.loginError)
            return
        }
          
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleSignInContinuation.resume(throwing: AccountManagerError.loginError)
            return
        }
    
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        appleSignInContinuation.resume(returning: credential)
    }
    
}

extension AccountManager{
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
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {String(format: "%02x", $0)}.joined()
        return hashString
    }
    
}


extension AccountManager{
    
    enum AccountManagerError: Error {
        case loginError
        case memberNotFound
        case cannotCreateMember
    }
    
}
