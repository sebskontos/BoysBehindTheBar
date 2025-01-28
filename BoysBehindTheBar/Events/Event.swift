//
//  Event.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 28/1/2025.
//

import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    @DocumentID var id: String? // Firestore auto-generates the document ID
    var clientName: String
    var eventDate: Date
    var location: String
    var duration: Int
    var status: String // Example values: "pending", "accepted", "denied"
    var adminMessage: String? // Optional message for admin decisions
}

enum EventStatus {
    case pending
    case accepted(String) // Admin can send a message
    case denied(String)   // Admin can send a rejection reason
}
