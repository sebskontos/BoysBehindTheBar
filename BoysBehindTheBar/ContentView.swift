//
//  ContentView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        if !authManager.isLoading {
            TabView {
                ClientBookingView()
                    .tabItem {
                        Label("Bookings", systemImage: "calendar")
                    }
                
                PaymentView()
                    .tabItem {
                        Label("Payments", systemImage: "creditcard")
                    }
                
                if authManager.userRole == .admin {
                    AdminEventList()
                        .tabItem {
                            Label("Admin", systemImage: "gear")
                        }
                } else {
                    CustomerEventList()
                        .tabItem {
                            Label("My Bookings", systemImage: "person")
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

