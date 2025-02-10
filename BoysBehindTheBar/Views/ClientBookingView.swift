//
//  ClientBookingView.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 26/1/2025.
//

import SwiftUI
import MapKit


extension View {
    func addDoneButton() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


let firestoreManager = FirestoreManager()

struct ClientBookingView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    
    @State private var eventDate = Date()
    @State private var location = ""
    @State private var occasion = "Birthday"
    @State private var guestCount = ""
    
    @State private var startTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
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
            .addDoneButton()
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
        
        let newEvent = Event(
            name: "\(firstName) \(lastName)",
            phoneNumber: phoneNumber,
            email: email,
            address: location,
            date: eventDate,
            time: startTime,
            duration: numberOfHours,
            guests: Int(guestCount) ?? 0,
            notes: notesArray.joined(separator: "|"),
            status: "pending",
            adminMessage: nil
        )

        print("Booking submitted: \(newEvent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            firestoreManager.addBooking(event: newEvent) { error in
                if let error = error {
                    print("❌ Error adding booking: \(error)")
                } else {
                    print("✅ Booking added successfully!")
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isSuccess = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isSubmitting = false
                }
            }
        }
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
