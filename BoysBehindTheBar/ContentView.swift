//
//  ContentView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI

enum UserRole {
    case customer
    case admin
}


struct ContentView: View {
    let userRole: UserRole
    
    var body: some View {
        TabView {
            ClientBookingView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }

            PaymentView()
                .tabItem {
                    Label("Payments", systemImage: "creditcard")
                }

            if userRole == .admin {
                AdminDashboardView()
                    .tabItem {
                        Label("Admin", systemImage: "gear")
                    }
            }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView(userRole: .customer) // Change to .admin for admin view testing)
}

