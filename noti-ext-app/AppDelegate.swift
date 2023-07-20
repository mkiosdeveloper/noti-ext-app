//
//  AppDelegate.swift
//  noti-ext-app
//
//  Created by Warba on 13/07/2023.
//

import UIKit
import OSLog
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let logger = Logger(subsystem: "mkdevnotif.noti-ext-app.NotifExtension", category: "AppDelegate")

    func setCaregories() {
        let copyAction = UNNotificationAction(identifier: "copyaction",
                                              title: "Copy promo code",
                                              options: [],
                                              icon: .init(systemImageName: "doc.on.doc"))
        let promoCategory = UNNotificationCategory(identifier: "PROMO",
                                                   actions: [copyAction],
                                                   intentIdentifiers: [],
                                                   options: [.customDismissAction])
        let eidCategory = UNNotificationCategory(identifier: "EID",
                                                 actions: [],
                                                 intentIdentifiers: [])

        UNUserNotificationCenter.current().setNotificationCategories([promoCategory, eidCategory])
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        setCaregories()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        return true
    }

    //MARK: - Notifications Functions
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        logger.info("Success register to notifs!")
        logger.trace("Device Token:\n \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logger.error("Failed to register for notif:\n \(error.localizedDescription)")
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {

    //notif while in foregound
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let action = response.actionIdentifier
        let request = response.notification.request

        if action == "copyaction" {


            var promocode = request.content.userInfo["promocode"] as! String
            UIPasteboard.general.string = promocode
            logger.notice("copy action was tapped")
        }

        // You must call the completion handler when you're done
        completionHandler()
    }
}

