//
//  MapView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 10/2/2025.
//

import MapKit
import SwiftUI

struct MapView: View {
    var event: Event
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $mapPosition) {
            Marker(event.name, coordinate: getCoordinates())
        }
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
}

#Preview {
    MapView(event: Event(name: "TEST", phoneNumber: "0401033232", email: "john.doe@gmail.com", address: "14 Irene Street, Abbotsford NSW 2046", date: Date.now, time: Date.now, duration: "4", guests: 100, notes: "N/A", status: "pending"))
}
