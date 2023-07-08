//
//  AppDelegate.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/13.
//

import UIKit
import AVFoundation
import FirebaseCore
import GoogleSignIn
import LineSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         //CONFIGURE PUSH NOTIFICATION
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]

            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })

            UNUserNotificationCenter.current().delegate = self
            application.registerForRemoteNotifications() // here your alert with Permission will appear
            
        LoginManager.shared.setup(channelID: "2000076716", universalLinkURL: nil)
        FirebaseApp.configure()
        let link = "https://aiba-digital.firebaseapp.com/__/auth/handler"
      
        
//        let sess = AVAudioSession.sharedInstance()
//        try? sess.setCategory(.ambient, mode:.default)
//        try? sess.setActive(true)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     //   Messaging.messaging().apnsToken = deviceToken
    }
   
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Here")
        var handled: Bool = false
        return LoginManager.shared.application(app, open: url, options: options)
        if url.absoluteString.contains("google") { // fb sign in
            handled = GIDSignIn.sharedInstance.handle(url)
        }
        
//        if url.absoluteString.contains("aiba") { //google sign in
//            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//                  let host = components.host,
//               let deeplink = DeepLink(rawValue: host){
//                  print(deeplink)
//            }
//        }else{
//
//        }
        return handled
    }

   
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        return LoginManager.shared.application(application, open: userActivity.webpageURL)
    }
}

