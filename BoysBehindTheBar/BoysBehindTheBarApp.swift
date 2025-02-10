//
//  BoysBehindTheBarApp.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import Firebase
import FirebaseAuth
import SwiftUI

@main
struct BoysBehindTheBarApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
        configureFirestore()

        // Preload FirebaseAuth on background thread before UI loads
        DispatchQueue.global(qos: .background).async {
            _ = Auth.auth().currentUser
        }
    }


    var body: some Scene {
        WindowGroup {
            if authManager.isLoading {
                SplashScreenView()
            } else {
                ContentView()
            }
        }
    }
}

func configureFirestore() {
    let settings = FirestoreSettings()
    settings.cacheSettings = PersistentCacheSettings()
    Firestore.firestore().settings = settings
}
