//
//  ClientBookingView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI

struct ClientBookingView: View {
    @State private var eventDate = Date()
    @State private var location = ""
    @State private var guestCount = ""
    @State private var specialRequests = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    DatePicker("Event Date", selection: $eventDate, displayedComponents: .date)
                    TextField("Event Location", text: $location)
                    TextField("Number of Guests", text: $guestCount)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Special Requests")) {
                    TextEditor(text: $specialRequests)
                        .frame(height: 100)
                }

                Button(action: submitBooking) {
                    Text("Submit Booking")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Bookings")
        }
    }

    func submitBooking() {
        // Logic to handle booking submission
        print("Booking submitted:")
        print("Date: \(eventDate)")
        print("Location: \(location)")
        print("Guests: \(guestCount)")
        print("Special Requests: \(specialRequests)")
    }
}
