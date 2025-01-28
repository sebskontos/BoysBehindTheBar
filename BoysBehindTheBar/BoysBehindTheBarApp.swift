//
//  BoysBehindTheBarApp.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct BoysBehindTheBarApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let userRole: UserRole = .admin
    
    var body: some Scene {
        WindowGroup {
            ContentView(userRole: userRole) // Change to .admin for admin view testing)
                .environmentObject(FirestoreManager())
        }
    }
}
