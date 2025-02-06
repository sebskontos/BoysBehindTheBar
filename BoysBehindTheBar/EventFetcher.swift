//
//  EventFetcher.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 7/2/2025.
//


import Foundation

class EventFetcher: ObservableObject {
    @Published var events: [Event] = []
    
    init() {
        fetchEvents()
    }
    
    func getAPIURL() -> String? {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict["API_URL"] as? String
        }
        return nil
    }
    
    func sendBooking(event: Event) {
        guard let apiURL = getAPIURL(), let url = URL(string: apiURL) else {
            print("Error: API URL not found")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert Dates to String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: event.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let timeString = timeFormatter.string(from: event.time)
        
        let bookingData: [String: Any] = [
            "id": event.id.uuidString,
            "name": event.name,
            "phoneNumber": "'" + event.phoneNumber,
            "email": event.email,
            "address": event.address,
            "date": dateString,
            "time": timeString,
            "duration": event.duration,
            "guests": event.guests,
            "notes": event.notes,
            "status": event.status
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bookingData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending booking: \(error)")
            } else {
                print("Booking sent successfully!")
            }
        }.resume()
    }
    
    func fetchEvents() {
        guard let apiURL = getAPIURL(), let url = URL(string: apiURL) else {
            print("Error: API URL not found")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }

            do {
                let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
                DispatchQueue.main.async {
                    self.events = decodedEvents
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

}
