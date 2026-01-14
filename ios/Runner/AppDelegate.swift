// import Flutter
// import UIKit

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import UIKit
import Flutter
import Firebase
import GoogleSignIn
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Pastikan ini dipanggil pertama kali
    GeneratedPluginRegistrant.register(with: self)
    
    // Inisialisasi Firebase dengan error handling
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Setup untuk Remote Notifications (APNS)
    setupRemoteNotifications(application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Remote Notifications Setup
  private func setupRemoteNotifications(_ application: UIApplication) {
    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self
    
    // Request user permission untuk notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("❌ Error requesting notification authorization: \(error.localizedDescription)")
      }
      
      if granted {
        print("✅ Notification permission granted")
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      } else {
        print("⚠️ Notification permission denied by user")
      }
    }
  }
  
  // Called when APNS token is successfully registered
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNS token registered successfully: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }
  
  // Called when APNS registration fails
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  // Handle notification when app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Tampilkan notification bahkan saat app di foreground
    let userInfo = notification.request.content.userInfo
    print("💬 Notification received while app in foreground: \(userInfo)")
    
    // Show banner, sound, and badge
    completionHandler([.banner, .sound, .badge])
  }
  
  // Handle notification tap
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 User tapped notification: \(userInfo)")
    
    completionHandler()
  }

  // Untuk Google Sign In
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}
