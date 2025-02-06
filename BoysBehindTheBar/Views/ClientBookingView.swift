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

                    Picker("Occasion", selection: $occasion) {
                        ForEach(occasions, id: \ .self) { occasion in
                            Text(occasion)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Event Address", text: $location)
                            .onChange(of: location) {
                                addressSearchManager.search(query: location) { results in
                                    addressSuggestions = results
                                }
                            }
                            .autocapitalization(.none)

                        if !addressSuggestions.isEmpty {
                            List(addressSuggestions, id: \ .title) { suggestion in
                                VStack(alignment: .leading) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                }
                                .onTapGesture {
                                    location = "\(suggestion.title), \(suggestion.subtitle)"
                                    addressSuggestions = []
                                }
                            }
                            .frame(height: 20)
                        }
                    }

                    TextField("Number of Guests", text: $guestCount)
                        .keyboardType(.numberPad)
                        .onChange(of: guestCount) {
                            guestCount = guestCount.filter { $0.isNumber }
                        }
                }

                Section(header: Text("Service Timing")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    Picker("Number of Hours", selection: $numberOfHours) {
                        ForEach(hoursOptions, id: \ .self) { hour in
                            Text(hour)
                        }
                    }
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
                    Text("Submit Booking")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderless)
            }
            .navigationTitle("Bookings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func submitBooking() {
        
        let newEvent = Event(
            clientName: "\(firstName) \(lastName)",
            eventDate: eventDate,
            location: location,
            duration: Int(numberOfHours) ?? 3,
            status: "pending",
            adminMessage: nil,
            userPhoneNumber: phoneNumber // Store phone number
        )

        print("Booking submitted: \(newEvent)")
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
