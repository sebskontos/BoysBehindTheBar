//
//  AdminEventDetail.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//


import SwiftUI
import MapKit

struct EventDetail: View {
    var event: Event
    var isAdmin: Bool // Determines if the user is an admin
    
    @State private var responseMessage: String = ""
    @State private var status: String  // Local status update
    private let firestoreManager = FirestoreManager() // Firestore instance
    
    init(event: Event, isAdmin: Bool) {
        self.event = event
        self.isAdmin = isAdmin
        _status = State(initialValue: event.status) // Initialize state from event
    }

    var body: some View {
        VStack(spacing: 0) {
            // Map View
            MapView(event: event)
                .padding(.bottom, 8)

            // Booking Details Card
            VStack(alignment: .leading, spacing: 12) {
                Text("Booking Details")
                    .font(.title2.bold())

                HStack {
                    Text(event.name)
                        .font(.headline)

                    if isAdmin {
                        Link(destination: URL(string: "tel:\(event.phoneNumber)")!) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text(event.phoneNumber)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }

                Divider()

                Text("\(event.date, style: .date) at \(event.time, style: .time) • \(event.duration) hours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(event.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(event.guests) guests")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            .shadow(radius: 10)
            .padding(.horizontal)

            Spacer()

            // Accept & Deny Buttons (Admin Only)
            if isAdmin {
                HStack(spacing: 12) {
                    Button(action: { updateStatus(newStatus: "accepted") }) {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: { updateStatus(newStatus: "denied") }) {
                        Text("Deny")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Event Details")
    }
    
    func updateStatus(newStatus: String) {
        firestoreManager.updateBookingStatus(event: event, newStatus: newStatus, responseMessage: responseMessage) { error in
            if let error = error {
                print("❌ Error updating status: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    status = newStatus
                }
            }
        }
    }
}



#Preview {
    EventDetail(event: Event(name: "John Doe",
             phoneNumber: "0401033232",
             email: "john.doe@gmail.com",
             address: "The Pub",
             date: Date.now,
             time: Date.now,
             duration: "3",
             guests: 100,
             notes: "N/A",
             status: "pending"
    ), isAdmin: true)
}
