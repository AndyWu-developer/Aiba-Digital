//
//  AppDelegate.swift
//  Aiba Digital
//
//  Created by Andy on 2023/2/13.
//

import UIKit
import FirebaseCore
import GoogleSignIn

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
            
        FirebaseApp.configure()
        
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
        
        var handled: Bool = false
        if url.absoluteString.contains("fb"){ // fb sign in
           
        }else{ //google sign in
            handled = GIDSignIn.sharedInstance.handle(url)
        }
        return handled
    }

   
}

