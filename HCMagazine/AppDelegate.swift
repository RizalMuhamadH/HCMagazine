//
//  AppDelegate.swift
//  HCMagazine
//
//  3rd party plugin: Github by hackiftekhar/IQKeyboardManager, Google Firebase
//
//  Created by ayobandung on 4/12/17.
//  Last Modified on 10/20/17
//  Copyright © 2017 HC Bank BJB. All rights reserved.
//

import UIKit
import Foundation
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import UserNotificationsUI //framework to customize the notification

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{//, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    // Access UserDefaults
    let defaults = UserDefaults.standard
    
    let requestIdentifier = "localNotification" //identifier is to cancel the notification request
    let gcmMessageIDKey = "gcm.message_id"
    let data = "inbox"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //adapt the storyboard if the device is an iPad or a iPhone
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)//self.adaptStoryboard()
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        
        // MARK: Init Notification
        registerForPushNotifications(application: application)
        
        /* Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        */
        
        if let token = Messaging.messaging().fcmToken {
            print("FCM TOKEN: \(token)")
            connectToFcm()
        }
        
        let unread = UIApplication.shared.applicationIconBadgeNumber
        if(unread>0){
            defaults.set(unread, forKey: "unread")
            defaults.synchronize()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if isKeyPresentInUserDefaults(key: "editionUnread"){
            defaults.removeObject(forKey: "editionUnread")
        }
        
        //Enable IQ Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
                
        // Background fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        //log.info("Application: DidEnterBackground")
        
        print("background")
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("foreground")
        let unread = UIApplication.shared.applicationIconBadgeNumber
        if(unread>0){
            defaults.set(unread, forKey: "unread")
            defaults.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        if isKeyPresentInUserDefaults(key: "newsIdUnread"){
            let newsId = defaults.integer(forKey: "newsIdUnread")
            let rubricId = defaults.integer(forKey: "rubricIdUnread")
            let editionId = defaults.integer(forKey: "editionUnread")
            defaults.removeObject(forKey: "newsIdUnread")
            defaults.removeObject(forKey: "rubricIdUnread")
            defaults.removeObject(forKey: "editionUnread")
            openArticleVC(edition:editionId, news: newsId,rubric: rubricId)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ///log.info("Application: DidBecomeActive")
        //connectToFcm()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminate")
        
        defaults.set(trackIdList, forKey: "idList")
        defaults.set(trackList, forKey: "trackList")
        defaults.synchronize()
        
        if isKeyPresentInUserDefaults(key: "unread"){
            defaults.removeObject(forKey: "unread")
        }
        if isKeyPresentInUserDefaults(key: "changepass"){
            defaults.removeObject(forKey: "changepass")
        }
        if isKeyPresentInUserDefaults(key: "currentEd"){
            defaults.removeObject(forKey: "currentEd")
        }
        if isKeyPresentInUserDefaults(key: "edNum"){
            defaults.removeObject(forKey: "edNum")
        }
        if isKeyPresentInUserDefaults(key: "url"){
            defaults.removeObject(forKey: "url")
        }
        if isKeyPresentInUserDefaults(key: "newsIdUnread"){
            defaults.removeObject(forKey: "newsIdUnread")
        }
        if isKeyPresentInUserDefaults(key: "rubricIdUnread"){
            defaults.removeObject(forKey: "rubricIdUnread")
        }
        if isKeyPresentInUserDefaults(key: "editionUnread"){
            defaults.removeObject(forKey: "editionUnread")
        }
    }
    
    // Check existed user defaults
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // Enable play video on lanscape
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if window == self.window {
            return .portrait
        } else {
            return .allButUpsideDown
        }
    }
    
    // Support for background fetch
    @available(iOS 10.0, *)
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping () -> Void) {
        // get unread news
        let unreadNews = DataProgressed.instance.getUnreadNews()
        let content = UNMutableNotificationContent()
        content.title = "Sudahkah Anda Membaca ?"
        content.subtitle = unreadNews.newsTitle
        content.body = "Edisi ke-\(unreadNews.editionId)"
        content.sound = UNNotificationSound.default()
        
        defaults.set(unreadNews.newsId, forKey: "newsIdUnread")
        defaults.set(unreadNews.rubricId, forKey: "rubricIdUnread")
        defaults.set(unreadNews.editionId, forKey: "editionUnread")
        defaults.synchronize()
  
        // Deliver the notification in three seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3.0, repeats: false)
        let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
    }
 
    
    // Open Article from Local Notification
    func openArticleVC(edition:Int, news:Int,rubric:Int){
        let topVC = topMostController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcToPresent = storyboard.instantiateViewController(withIdentifier: "ArticleNotifVC") as! ArticleNotifViewController
        vcToPresent.id = news
        vcToPresent.rubId = rubric
        vcToPresent.barTitle = "Edisi ke-\(edition)"
        topVC.present(vcToPresent, animated: true, completion: nil)

    }
    
    // Get the top controller
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
}

extension AppDelegate {
    /**
     Register for push notification.
     
     Parameter application: Application instance.
     */
    func registerForPushNotifications(application: UIApplication) {
        print(#function)
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //Messaging.messaging().remoteMessageDelegate = self
            //log.info("Notification: registration for iOS >= 10 using UNUserNotificationCenter")
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            //log.info("Notification: registration for iOS < 10 using Basic Notification Center")
        }
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        print(#function)
        if let refreshedToken = InstanceID.instanceID().token() {
            //log.info("Notification: refresh token from FCM -> \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard Messaging.messaging().fcmToken != nil else {
            //log.error("FCM: Token does not exist.")
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().shouldEstablishDirectChannel = false
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                //log.error("FCM: Unable to connect with FCM. \(error.debugDescription)")
            } else {
                //log.info("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken()")
        
        Messaging.messaging().apnsToken = deviceToken
        
        //Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        //Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
        //Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("APNS Access Token: \(token)")
        //log.info("Notification: APNs token: \((deviceToken as! NSData))")
        //log.info("Notification: APNs token retrieved: \(token)")
        // With swizzling disabled you must set the APNs token here.
        /*FIRInstanceID
         .instanceID()
         .setAPNSToken(deviceToken,
         type: FIRInstanceIDAPNSTokenType.sandbox)*/
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        //log.info("Notification: basic delegate")
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        if isKeyPresentInUserDefaults(key: "unread"){
            defaults.removeObject(forKey: "unread")
        }
        if let messageData = userInfo[data]  as? String {
            print("Message data 2: \(messageData)")
            if(messageData == "true"){
                defaults.set(true, forKey: "unread")
                defaults.synchronize()
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        //analyse(notification: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //log.info("Notification: basic delegate (background fetch)")
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // Print message ID.
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        if isKeyPresentInUserDefaults(key: "unread"){
            defaults.removeObject(forKey: "unread")
        }
        if let messageData = userInfo[data]  as? String {
            print("Message data 2: \(messageData)")
            if(messageData == "true"){
                defaults.set(true, forKey: "unread")
                defaults.synchronize()
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //analyse(notification: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        //log.info("Notification: iOS 10 delegate(willPresent notification)")
        let userInfo = notification.request.content.userInfo
        print("masuk 3")
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        if isKeyPresentInUserDefaults(key: "unread"){
            defaults.removeObject(forKey: "unread")
        }
        if let messageData = userInfo[data]  as? String {
            print("Message data 2: \(messageData)")
            if(messageData == "true"){
                defaults.set(true, forKey: "unread")
                defaults.synchronize()
            }
        }
        if notification.request.identifier == requestIdentifier{
            
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //analyse(notification: userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        //log.info("Notification: iOS 10 delegate(didReceive response)")
        print("masuk 4")
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID 1: \(messageID)")
        }
        if isKeyPresentInUserDefaults(key: "unread"){
            defaults.removeObject(forKey: "unread")
        }
        if let messageData = userInfo[data]  as? String {
            print("Message data 2: \(messageData)")
            if(messageData == "true"){
                defaults.set(true, forKey: "unread")
                defaults.synchronize()
            }
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Print full message.
        //analyse(notification: userInfo)
        completionHandler()
    }
}


extension AppDelegate: MessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

