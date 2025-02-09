//
//  CustomerEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 29/1/2025.
//


import SwiftUI

struct CustomerEventList: View {
    
    var events: [Event] = []

    var body: some View {
        NavigationView {
            List(events) { event in
                NavigationLink(destination: EventDetail(event: event, isAdmin: false)) {
                    EventRow(event: event) // Reuse same row design
                }
            }
            .navigationTitle("My Bookings")
        }
    }
}

#Preview {
    CustomerEventList(events: [
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
        )
        ]
    )
}
