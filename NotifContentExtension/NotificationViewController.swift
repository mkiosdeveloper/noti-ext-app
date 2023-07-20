//
//  NotificationViewController.swift
//  NotifContentExtension
//
//  Created by Warba on 19/07/2023.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!


    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }

    //MARK: - didRecieve()
    func didReceive(_ notification: UNNotification) {
        
        let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent
        guard let promoCode = content.userInfo["promocode"] as? String else {

            return
        }
        guard let merchant = content.userInfo["merchant"] as? String else {

            return
        }


        if let attachment = content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                let imageData = try? Data(contentsOf: attachment.url)
                if let imgData = imageData {
                    imageView.image = UIImage(data: imgData)
                }
                attachment.url.stopAccessingSecurityScopedResource()
            }
        }

        self.titleLabel.text = "From \(merchant)"
        self.subtitleLabel.text = "Code: \(promoCode)"



    }



}
