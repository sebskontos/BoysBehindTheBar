//
//  BoysBehindTheBarApp.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import Firebase
import SwiftUI

@main
struct BoysBehindTheBarApp: App {
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(userRole: .admin)
        }
    }
}
