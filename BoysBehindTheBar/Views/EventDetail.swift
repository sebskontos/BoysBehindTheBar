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
    @State private var mapPosition: MapCameraPosition = .automatic
    
    @State private var status: String  // Local status update
    private let firestoreManager = FirestoreManager() // Firestore instance
    
    init(event: Event, isAdmin: Bool) {
        self.event = event
        self.isAdmin = isAdmin
        _status = State(initialValue: event.status) // Initialize state from event
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Map View
            Map(position: $mapPosition) {
                Marker(event.name, coordinate: getCoordinates())
            }
            .frame(height: 200) // Adjust height as needed
            .cornerRadius(10)
            .padding(.bottom)
            
            Text("Client: \(event.name)")
                .font(.headline)
            Text("Location: \(event.address)")
                .font(.subheadline)
            Text("Date: \(event.date, style: .date)")
            Text("Duration: \(event.duration) hours")
            
            // Admin-Only Response Message Field
            if isAdmin {
                Text("Response Message:")
                    .font(.headline)
                    .padding(.top)
                TextEditor(text: $responseMessage)
                    .frame(height: 100)
                    .border(Color.gray)
            }

            // Admin-Only Buttons
            if isAdmin {
                HStack {
                    Button(action: { updateStatus(newStatus: "accepted") }) {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { updateStatus(newStatus: "denied") }) {
                        Text("Deny")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .navigationTitle("Event Details")
        .onAppear {
                geocodeEventLocation()
            }
    }
    
    // Function to get default coordinates (prevents nil errors)
    func getCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 0, longitude: 0) // Default placeholder, updated after geocoding
    }
    
    // Geocode the event address into coordinates for the map
    func geocodeEventLocation() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(event.address) { placemarks, error in
            if let error = error {
                print("Failed to geocode address: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first,
               let location = placemark.location {
                let newCoordinate = CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Update map position
                DispatchQueue.main.async {
                    mapPosition = .region(MKCoordinateRegion(
                        center: newCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    ))
                }
            }
        }
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
