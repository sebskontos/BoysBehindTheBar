//
//  AdminEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventList: View {
    @StateObject private var eventFetcher = EventFetcher()
    var events: [Event] = []

    var body: some View {
        NavigationView {
            List(eventFetcher.events) { event in
                NavigationLink(destination: EventDetail(event: event, isAdmin: true)) {
                    EventRow(event: event)
                }
            }
            .navigationTitle("Bookings")
            .refreshable {   // Pull-to-refresh feature
                eventFetcher.fetchEvents()
            }
        }
    }
}

#Preview {
    AdminEventList(events: [
        Event(name: "John Doe",
              phoneNumber: "0401033232",
              email: "john.doe@gmail.com",
              address: "The Pub",
              date: Date.now,
              time: Date.now,
              duration: "3",
              guests: 100,
              notes: "N/A",
              status: "pending"
        ),
    ]
    )
}
