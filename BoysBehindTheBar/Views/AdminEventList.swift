//
//  AdminEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventList: View {
    @StateObject private var eventFetcher = EventFetcher()

    var body: some View {
        NavigationView {
            List(eventFetcher.events) { event in
                NavigationLink(destination: EventDetail(event: event, isAdmin: true)) {
                    EventRow(event: event)
                }
            }
            .navigationTitle("Bookings")
            .onAppear {
                eventFetcher.fetchEvents()
            }
        }
    }
}
