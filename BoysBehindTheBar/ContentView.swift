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
                AdminEventList()
                    .tabItem {
                        Label("Admin", systemImage: "gear")
                    }
            }
            
            else if userRole == .customer {
                CustomerEventList()
                    .tabItem {
                        Label("My Bookings", systemImage: "person")
                    }
            }
        }
    }
}

#Preview {
    ContentView(userRole: .admin) // Change to .admin for admin view testing)
}

