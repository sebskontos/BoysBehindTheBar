//
//  FirestoreManager.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 9/2/2025.
//

import FirebaseAuth
import FirebaseFirestore

class FirestoreManager {
    private let db = Firestore.firestore()

    func addBooking(event: Event, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ Error: No authenticated user.")
            return
        }
        
        let bookingRef = db.collection("bookings").document()
        
        // Convert Dates to String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: event.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: event.time)

        let bookingData: [String: Any] = [
            "id": bookingRef.documentID,
            "userID": userID,
            "name": event.name,
            "email": event.email,
            "phoneNumber": event.phoneNumber,
            "address": event.address,
            "date": dateString,
            "time": timeString,
            "duration": event.duration,
            "guests": event.guests,
            "status": event.status,
            "notes": event.notes
        ]
        
        bookingRef.setData(bookingData) { error in
            completion(error)
        }
        
    }
    
    func updateBookingStatus(event: Event, newStatus: String, responseMessage: String?, completion: @escaping (Error?) -> Void) {
        guard let docID = event.firestoreID else {
            print("❌ Error: Missing Firestore document ID.")
            return
        }

        let bookingRef = db.collection("bookings").document(docID)

        var updateData: [String: Any] = ["status": newStatus]
        if let message = responseMessage {
            updateData["adminMessage"] = message
        }

        bookingRef.updateData(updateData) { error in
            completion(error)
        }
    }
    
}
