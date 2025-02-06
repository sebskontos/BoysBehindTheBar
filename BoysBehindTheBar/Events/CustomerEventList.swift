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
    CustomerEventList()
}
