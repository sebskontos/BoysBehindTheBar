//
//  AdminEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventList: View {
    
    var events: [Event] = []

    var body: some View {
        NavigationView {
            List(events) { event in
                NavigationLink(destination: EventDetail(event: event, isAdmin: true)) {
                    EventRow(event: event)
                }
            }
            .navigationTitle("Bookings")
        }
    }
}

#Preview {
    AdminEventList()
}
