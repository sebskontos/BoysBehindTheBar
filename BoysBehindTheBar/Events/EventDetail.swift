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

    var body: some View {
        VStack(alignment: .leading) {
            // Map View
            Map(position: $mapPosition) {
                Marker(event.clientName, coordinate: getCoordinates())
            }
            .frame(height: 200) // Adjust height as needed
            .cornerRadius(10)
            .padding(.bottom)
            
            Text("Client: \(event.clientName)")
                .font(.headline)
            Text("Location: \(event.location)")
                .font(.subheadline)
            Text("Date: \(event.eventDate, style: .date)")
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
                    Button(action: { }) {
                        Text("Accept")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { }) {
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
        geocoder.geocodeAddressString(event.location) { placemarks, error in
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
}



#Preview {
    EventDetail(event: Event(
        clientName: "John Doe",
        clientEmail: "john.doe@gmail.com", eventDate: Date.now,
        location: "The pub",
        duration: "3",
        status: "pending",
        userPhoneNumber: "0401033232"
    ), isAdmin: true)
}
