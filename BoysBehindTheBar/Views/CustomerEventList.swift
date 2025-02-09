//
//  CustomerEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 29/1/2025.
//


import SwiftUI

struct CustomerEventList: View {
    
    @StateObject private var eventFetcher = EventFetcher()
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if let userID = authManager.userID {
                    List(eventFetcher.events) { event in
                        NavigationLink(destination: EventDetail(event: event, isAdmin: false)) {
                            EventRow(event: event)
                        }
                    }
                    .navigationTitle("My Bookings")
                    .onAppear {
                        eventFetcher.fetchEventsForUser(userID: userID)  // ✅ Fetch user-specific bookings
                    }
                } else {
                    Text("Authenticating...")
                        .onAppear {
                            authManager.checkAuthStatus()
                        }
                }
            }
        }
    }
}
