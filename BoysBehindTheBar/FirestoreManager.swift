//
//  FirestoreManager.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//

import FirebaseFirestore
import Combine

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var events: [Event] = []

    // Fetch bookings from Firestore
    func fetchEvents() {
        db.collection("events").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching events: \(error)")
                return
            }

            self.events = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Event.self) // Decode Firestore data into `Event`
            } ?? []
        }
    }

    // Add a new booking to Firestore
    func addEvent(_ event: Event) {
        do {
            _ = try db.collection("events").addDocument(from: event)
        } catch {
            print("Error adding event: \(error)")
        }
    }

    // Update the status of a booking (accept/deny)
    func updateEventStatus(eventID: String, status: String, adminMessage: String?) {
        db.collection("events").document(eventID).updateData([
            "status": status,
            "adminMessage": adminMessage ?? ""
        ]) { error in
            if let error = error {
                print("Error updating event: \(error)")
            } else {
                print("Event updated successfully!")
            }
        }
    }
}
