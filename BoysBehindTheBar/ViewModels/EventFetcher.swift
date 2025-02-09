//
//  EventFetcher.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 7/2/2025.
//


import FirebaseFirestore

class EventFetcher: ObservableObject {
    @Published var events: [Event] = []
    private let db = Firestore.firestore()

    func fetchEvents() {
        db.collection("bookings").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("❌ Error fetching events: \(String(describing: error))")
                return
            }

            self.events = documents.compactMap { doc in
                do {
                    var event = try doc.data(as: Event.self)
                    event.firestoreID = doc.documentID
                    return event
                } catch {
                    print("❌ Error decoding event: \(error)")
                    return nil
                }
            }
        }
    }
}

