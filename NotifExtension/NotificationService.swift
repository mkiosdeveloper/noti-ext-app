//
//  NotificationService.swift
//  NotifExtension
//
//  Created by Warba on 16/07/2023.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?


//MARK: - Functions
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else { return }
        // Modify the notification content here...
        bestAttemptContent.title = "\(bestAttemptContent.title)"
        // Save notification data to UserDefaults
        let data = bestAttemptContent.userInfo as NSDictionary
        let pref = UserDefaults.init(suiteName: "group.mkdevnotif.noti-ext-app")
        pref?.set(data, forKey: "NOTIF_DATA")
        pref?.synchronize()

        guard let attachmentURL = bestAttemptContent.userInfo["attachment-url"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }

        do {
            let imageData = try Data(contentsOf: URL(string: attachmentURL)!)
            guard let attachment = UNNotificationAttachment.download(imageFileIdentifier: "image.gif",
                                                                     data: imageData,
                                                                     options: nil) else {
                contentHandler(bestAttemptContent)
                return
            }
            bestAttemptContent.attachments = [attachment]
            contentHandler(bestAttemptContent.copy() as! UNNotificationContent)
        } catch {
            contentHandler(bestAttemptContent)
            print("Unable to load data: \(error)")
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

//MARK: - Extension
extension UNNotificationAttachment {
    static func download(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]?)
    -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.mkdevnotif.noti-ext-app") {
            do {
                let newDirectory = directory.appendingPathComponent("Images")
                if !fileManager.fileExists(atPath: newDirectory.path) {
                    try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                let fileURL = newDirectory.appendingPathComponent(imageFileIdentifier)
                do {
                    try data.write(to: fileURL, options: [])
                } catch {
                    print("Unable to load data: \(error)")
                }
                let pref = UserDefaults(suiteName: "group.mkdevnotif.noti-ext-app")
                pref?.set(data, forKey: "NOTIF_IMAGE")
                pref?.synchronize()
                let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier,
                                                                        url: fileURL,
                                                                        options: options)
                return imageAttachment
            } catch let error {
                print("Error: \(error)")
            }
        }
        return nil
    }
}
