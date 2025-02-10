//
//  AdminEventList.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI

struct AdminEventList: View {
    @StateObject private var eventFetcher = EventFetcher()
    @State private var selectedStatus: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Picker("Booking Status", selection: $selectedStatus) {
                    Text("Show All").tag(nil as String?)  // ✅ Show All option
                    Text("Pending").tag("pending" as String?)
                    Text("Accepted").tag("accepted" as String?)
                    Text("Denied").tag("denied" as String?)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List(eventFetcher.events) { event in
                    NavigationLink(destination: EventDetail(event: event, isAdmin: true)) {
                        EventRow(event: event)
                    }
                }
                .navigationTitle(selectedStatus == nil ? "All Bookings" : "\(selectedStatus!.capitalized) Bookings")
                .onAppear {
                    eventFetcher.fetchEvents(status: selectedStatus)
                }
                .onChange(of: selectedStatus) { _, newStatus in
                    eventFetcher.fetchEvents(status: newStatus)
                }
            }
        }
    }
}
