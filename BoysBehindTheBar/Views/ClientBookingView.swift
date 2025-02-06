//
//  ClientBookingView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI
import MapKit

struct ClientBookingView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    
    @State private var eventDate = Date()
    @State private var location = ""
    @State private var occasion = "Birthday"
    @State private var guestCount = ""
    @State private var startTime = Date()
    @State private var numberOfHours = "3"
    @State private var drinksServed: [String] = []
    @State private var cocktails = ""
    @State private var additionalRequests = ""
    
    @State private var addressSuggestions: [(title: String, subtitle: String)] = []
    @StateObject private var addressSearchManager = AddressSearchManager()

    let occasions = ["Wedding", "Birthday", "Corporate Event", "Other"]
    let hoursOptions = ["3", "4", "5", "6+"]
    let drinkOptions = ["Cocktails", "Shots", "Standard Drinks", "Other"]
    
    @State private var isSubmitting = false
    @State private var isSuccess = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Details")) {
                    HStack {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                            .autocapitalization(.words)
                        TextField("Last Name", text: $lastName)
                            .textContentType(.familyName)
                            .autocapitalization(.words)
                    }

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)

                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Event Details")) {
                    DatePicker("Event Date", selection: $eventDate, in: Date.now..., displayedComponents: .date)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    Picker("Occasion", selection: $occasion) {
                        ForEach(occasions, id: \ .self) { occasion in
                            Text(occasion)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Event Address", text: $location)
                            .onChange(of: location){ _, newValue in
                                if newValue.isEmpty {
                                    addressSuggestions = []
                                } else {
                                    searchForAddresses(query: newValue)
                                }
                            }
                            .autocapitalization(.none)

                        if !addressSuggestions.isEmpty {
                            List(addressSuggestions, id: \.title) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                }
                                .onTapGesture {
                                    location = "\(suggestion.title), \(suggestion.subtitle)"
                                    addressSuggestions = [] // Hide suggestions after selection
                                }
                            }
                            .frame(maxHeight: 200) // Allows dynamic list height
                        }
                    }

                    TextField("Number of Guests", text: $guestCount)
                        .keyboardType(.numberPad)
                        .onChange(of: guestCount) {
                            guestCount = guestCount.filter { $0.isNumber }
                        }
                }

                Section(header: Text("How many hours would you like the boys for?")) {
                    Picker("Number of Hours", selection: $numberOfHours) {
                        ForEach(hoursOptions, id: \ .self) { hour in
                            Text(hour)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("What Will Be Served At Your Event?")) {
                    ForEach(drinkOptions, id: \ .self) { option in
                        Toggle(option, isOn: Binding(
                            get: { drinksServed.contains(option) },
                            set: { isSelected in
                                if isSelected {
                                    drinksServed.append(option)
                                } else {
                                    drinksServed.removeAll { $0 == option }
                                }
                            }
                        ))
                    }
                }

                if drinksServed.contains("Cocktails") {
                    Section(header: Text("What Cocktails Would You Like?")) {
                        TextField("Enter cocktails", text: $cocktails)
                    }
                }

                Section(header: Text("Anything Else For The Boys Behind The Bar?")) {
                    TextEditor(text: $additionalRequests)
                        .frame(height: 100)
                }

                Button(action: submitBooking) {
                    HStack {
                        if isSubmitting {
                            if isSuccess {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                ProgressView()
                            }
                        } else {
                            Text("Submit Booking")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
            }
            .navigationTitle("Bookings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func searchForAddresses(query: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Debounce effect
            addressSearchManager.search(query: query) { results in
                DispatchQueue.main.async {
                    addressSuggestions = results
                }
            }
        }
    }

    func submitBooking() {
        isSubmitting = true
        isSuccess = false
        
        let newEvent = Event(
            clientName: "\(firstName) \(lastName)",
            clientEmail: email,
            eventDate: eventDate,
            location: location,
            duration: numberOfHours,
            status: "pending",
            adminMessage: nil,
            userPhoneNumber: phoneNumber // Store phone number
        )

        print("Booking submitted: \(newEvent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            sendBooking(event: newEvent)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isSuccess = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isSubmitting = false
                }
            }
        }
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
        let dateString = dateFormatter.string(from: event.eventDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let timeString = timeFormatter.string(from: startTime)
        
        // Format Notes Section
        var notesArray: [String] = []
        
        // Add drinks served
        if !drinksServed.isEmpty {
            notesArray.append("Drinks: \(drinksServed.joined(separator: ", "))")
        }
        
        // Add cocktail types if applicable
        if drinksServed.contains("Cocktails"), !cocktails.isEmpty {
            notesArray.append("Cocktails: \(cocktails)")
        }
        
        // Add additional requests if present
        if !additionalRequests.isEmpty {
            notesArray.append("Requests: \(additionalRequests)")
        }
        
        let bookingData: [String: Any] = [
            "id": event.id.uuidString,
            "name": event.clientName,
            "phoneNumber": "'" + event.userPhoneNumber,
            "email": event.clientEmail,
            "address": event.location,
            "date": dateString,
            "time": timeString,
            "duration": event.duration,
            "guests": guestCount,
            "notes": notesArray.joined(separator: " | "),
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
}

class AddressSearchManager: ObservableObject {
    func search(query: String, completion: @escaping ([(title: String, subtitle: String)]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                completion([])
                return
            }

            let results = response?.mapItems.compactMap { item -> (title: String, subtitle: String)? in
                guard let title = item.placemark.name else { return nil }
                let subtitle = [
                    item.placemark.locality,
                    item.placemark.administrativeArea,
                    item.placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")
                return (title: title, subtitle: subtitle)
            } ?? []

            completion(results)
        }
    }
}

#Preview {
    ClientBookingView()
}
